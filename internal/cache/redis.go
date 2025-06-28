// internal/cache/redis.go
package cache

import (
	"context"
	"fmt"
	"time"

	"github.com/r-scheele/sqr/internal/util"
	"github.com/redis/go-redis/v9"
	"github.com/rs/zerolog/log"
)

type RedisCache struct {
	client *redis.Client
	prefix string
}

func NewRedisCache(config util.Config) (*RedisCache, error) {

	client := redis.NewClient(&redis.Options{
		Addr:         config.RedisAddress,
		Password:     config.RedisPassword,
		DB:           config.RedisDB,
		MaxRetries:   config.RedisMaxRetries,
		PoolSize:     config.RedisPoolSize,
		DialTimeout:  config.RedisDialTimeout,
		ReadTimeout:  config.RedisReadTimeout,
		WriteTimeout: config.RedisWriteTimeout,
	})

	// Test connection
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := client.Ping(ctx).Err(); err != nil {
		return nil, fmt.Errorf("failed to connect to redis: %w", err)
	}

	log.Info().Str("address", config.RedisAddress).Msg("connected to redis cache")

	return &RedisCache{
		client: client,
		prefix: config.CachePrefix,
	}, nil
}

func (r *RedisCache) key(key string) string {
	return r.prefix + key
}

func (r *RedisCache) Get(ctx context.Context, key string) ([]byte, error) {
	val, err := r.client.Get(ctx, r.key(key)).Bytes()
	if err == redis.Nil {
		return nil, ErrCacheNotFound
	}
	return val, err
}

func (r *RedisCache) Set(ctx context.Context, key string, value []byte, ttl time.Duration) error {
	return r.client.Set(ctx, r.key(key), value, ttl).Err()
}

func (r *RedisCache) Delete(ctx context.Context, key string) error {
	return r.client.Del(ctx, r.key(key)).Err()
}

func (r *RedisCache) DeletePattern(ctx context.Context, pattern string) error {
	keys, err := r.client.Keys(ctx, r.key(pattern)).Result()
	if err != nil {
		return err
	}

	if len(keys) == 0 {
		return nil
	}

	return r.client.Del(ctx, keys...).Err()
}

func (r *RedisCache) Exists(ctx context.Context, key string) (bool, error) {
	count, err := r.client.Exists(ctx, r.key(key)).Result()
	return count > 0, err
}

func (r *RedisCache) HGet(ctx context.Context, key, field string) ([]byte, error) {
	val, err := r.client.HGet(ctx, r.key(key), field).Bytes()
	if err == redis.Nil {
		return nil, ErrCacheNotFound
	}
	return val, err
}

func (r *RedisCache) HSet(ctx context.Context, key, field string, value []byte, ttl time.Duration) error {
	pipe := r.client.Pipeline()
	pipe.HSet(ctx, r.key(key), field, value)
	if ttl > 0 {
		pipe.Expire(ctx, r.key(key), ttl)
	}
	_, err := pipe.Exec(ctx)
	return err
}

func (r *RedisCache) HDelete(ctx context.Context, key string, fields ...string) error {
	return r.client.HDel(ctx, r.key(key), fields...).Err()
}

func (r *RedisCache) LPush(ctx context.Context, key string, values ...[]byte) error {
	args := make([]interface{}, len(values))
	for i, v := range values {
		args[i] = v
	}
	return r.client.LPush(ctx, r.key(key), args...).Err()
}

func (r *RedisCache) LRange(ctx context.Context, key string, start, stop int64) ([][]byte, error) {
	vals, err := r.client.LRange(ctx, r.key(key), start, stop).Result()
	if err != nil {
		return nil, err
	}

	result := make([][]byte, len(vals))
	for i, v := range vals {
		result[i] = []byte(v)
	}
	return result, nil
}

func (r *RedisCache) SAdd(ctx context.Context, key string, members ...[]byte) error {
	args := make([]interface{}, len(members))
	for i, m := range members {
		args[i] = m
	}
	return r.client.SAdd(ctx, r.key(key), args...).Err()
}

func (r *RedisCache) SMembers(ctx context.Context, key string) ([][]byte, error) {
	vals, err := r.client.SMembers(ctx, r.key(key)).Result()
	if err != nil {
		return nil, err
	}

	result := make([][]byte, len(vals))
	for i, v := range vals {
		result[i] = []byte(v)
	}
	return result, nil
}

func (r *RedisCache) FlushAll(ctx context.Context) error {
	return r.client.FlushAll(ctx).Err()
}

func (r *RedisCache) Close() error {
	return r.client.Close()
}
