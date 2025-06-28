// internal/cache/noop.go
package cache

import (
	"context"
	"time"
)

type NoOpCache struct{}

func NewNoOpCache() *NoOpCache {
	return &NoOpCache{}
}

func (n *NoOpCache) Get(ctx context.Context, key string) ([]byte, error) {
	return nil, ErrCacheNotFound
}

func (n *NoOpCache) Set(ctx context.Context, key string, value []byte, ttl time.Duration) error {
	return nil
}

func (n *NoOpCache) Delete(ctx context.Context, key string) error {
	return nil
}

func (n *NoOpCache) DeletePattern(ctx context.Context, pattern string) error {
	return nil
}

func (n *NoOpCache) Exists(ctx context.Context, key string) (bool, error) {
	return false, nil
}

func (n *NoOpCache) HGet(ctx context.Context, key, field string) ([]byte, error) {
	return nil, ErrCacheNotFound
}

func (n *NoOpCache) HSet(ctx context.Context, key, field string, value []byte, ttl time.Duration) error {
	return nil
}

func (n *NoOpCache) HDelete(ctx context.Context, key string, fields ...string) error {
	return nil
}

func (n *NoOpCache) LPush(ctx context.Context, key string, values ...[]byte) error {
	return nil
}

func (n *NoOpCache) LRange(ctx context.Context, key string, start, stop int64) ([][]byte, error) {
	return nil, nil
}

func (n *NoOpCache) SAdd(ctx context.Context, key string, members ...[]byte) error {
	return nil
}

func (n *NoOpCache) SMembers(ctx context.Context, key string) ([][]byte, error) {
	return nil, nil
}

func (n *NoOpCache) FlushAll(ctx context.Context) error {
	return nil
}

func (n *NoOpCache) Close() error {
	return nil
}
