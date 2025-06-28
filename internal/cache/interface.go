package cache

import (
	"context"
	"errors"
	"time"
)

var (
	ErrCacheNotFound = errors.New("cache: key not found")
	ErrCacheMiss     = errors.New("cache: miss")
)

type Cache interface {
	Get(ctx context.Context, key string) ([]byte, error)
	Set(ctx context.Context, key string, value []byte, ttl time.Duration) error
	Delete(ctx context.Context, key string) error
	DeletePattern(ctx context.Context, pattern string) error
	Exists(ctx context.Context, key string) (bool, error)

	// Hash operations for complex data
	HGet(ctx context.Context, key, field string) ([]byte, error)
	HSet(ctx context.Context, key, field string, value []byte, ttl time.Duration) error
	HDelete(ctx context.Context, key string, fields ...string) error

	// List operations
	LPush(ctx context.Context, key string, values ...[]byte) error
	LRange(ctx context.Context, key string, start, stop int64) ([][]byte, error)

	// Set operations
	SAdd(ctx context.Context, key string, members ...[]byte) error
	SMembers(ctx context.Context, key string) ([][]byte, error)

	// Utility
	FlushAll(ctx context.Context) error
	Close() error
}

type CacheManager interface {
	Cache

	// Advanced operations
	GetOrSet(ctx context.Context, key string, ttl time.Duration, fetcher func() ([]byte, error)) ([]byte, error)
	InvalidateByTags(ctx context.Context, tags ...string) error
	Warmup(ctx context.Context, keys []string) error

	// JSON helpers
	GetJSON(ctx context.Context, key string, v interface{}) error
	SetJSON(ctx context.Context, key string, v interface{}, ttl time.Duration) error
}
