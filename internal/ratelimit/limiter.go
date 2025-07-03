package ratelimit

import (
	"context"
	"fmt"
	"math/rand"
	"strconv"
	"time"

	"github.com/r-scheele/sqr/internal/util"
	"github.com/redis/go-redis/v9"
)

type RedisLimiter struct {
	client        *redis.Client
	prefix        string
	defaultLimit  int64
	defaultWindow time.Duration
}

func NewRedisLimiter(client *redis.Client, prefix string, config util.Config) *RedisLimiter {
	return &RedisLimiter{
		client:        client,
		prefix:        prefix,
		defaultLimit:  config.RateLimitDefaultLimit, // 100 requests per window
		defaultWindow: time.Minute,                  // 1 minute window
	}
}

// Allow implements the Limiter interface using default limits
func (r *RedisLimiter) Allow(ctx context.Context, key string) (*Result, error) {
	return r.AllowWithLimits(ctx, key, r.defaultLimit, r.defaultWindow)
}

// Reset implements the Limiter interface
func (r *RedisLimiter) Reset(ctx context.Context, key string) error {
	fullKey := r.prefix + key
	return r.client.Del(ctx, fullKey).Err()
}

// AllowWithLimits allows custom limits for specific use cases
func (r *RedisLimiter) AllowWithLimits(ctx context.Context, key string, limit int64, window time.Duration) (*Result, error) {
	fullKey := r.prefix + key
	now := time.Now()
	windowStart := now.Add(-window)

	pipe := r.client.Pipeline()

	pipe.ZRemRangeByScore(ctx, fullKey, "0", strconv.FormatInt(windowStart.UnixNano(), 10))

	pipe.ZCard(ctx, fullKey)

	pipe.ZAdd(ctx, fullKey, redis.Z{
		Score:  float64(now.UnixNano()),
		Member: fmt.Sprintf("%d-%d", now.UnixNano(), rand.Int63()),
	})

	pipe.Expire(ctx, fullKey, window+time.Second)

	results, err := pipe.Exec(ctx)
	if err != nil {
		return nil, err
	}

	count := results[1].(*redis.IntCmd).Val()

	allowed := count < limit
	remaining := limit - count
	if remaining < 0 {
		remaining = 0
	}

	var retryAfter time.Duration
	if !allowed {

		oldest, err := r.client.ZRange(ctx, fullKey, 0, 0).Result()
		if err == nil && len(oldest) > 0 {
			oldestTime, _ := strconv.ParseInt(oldest[0][:19], 10, 64)
			retryAfter = time.Duration(oldestTime + window.Nanoseconds() - now.UnixNano())
		}
	}

	return &Result{
		Allowed:    allowed,
		Remaining:  remaining,
		ResetTime:  now.Add(window),
		RetryAfter: retryAfter,
	}, nil
}
