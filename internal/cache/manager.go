// internal/cache/manager.go
package cache

import (
	"context"
	"encoding/json"
	"time"

	"github.com/rs/zerolog/log"
)

type Manager struct {
	cache Cache
	tags  map[string][]string // tag -> keys mapping
}

func NewManager(cache Cache) *Manager {
	return &Manager{
		cache: cache,
		tags:  make(map[string][]string),
	}
}

func (m *Manager) Get(ctx context.Context, key string) ([]byte, error) {
	return m.cache.Get(ctx, key)
}

func (m *Manager) Set(ctx context.Context, key string, value []byte, ttl time.Duration) error {
	return m.cache.Set(ctx, key, value, ttl)
}

func (m *Manager) Delete(ctx context.Context, key string) error {
	return m.cache.Delete(ctx, key)
}

func (m *Manager) DeletePattern(ctx context.Context, pattern string) error {
	return m.cache.DeletePattern(ctx, pattern)
}

func (m *Manager) Exists(ctx context.Context, key string) (bool, error) {
	return m.cache.Exists(ctx, key)
}

func (m *Manager) HGet(ctx context.Context, key, field string) ([]byte, error) {
	return m.cache.HGet(ctx, key, field)
}

func (m *Manager) HSet(ctx context.Context, key, field string, value []byte, ttl time.Duration) error {
	return m.cache.HSet(ctx, key, field, value, ttl)
}

func (m *Manager) HDelete(ctx context.Context, key string, fields ...string) error {
	return m.cache.HDelete(ctx, key, fields...)
}

func (m *Manager) LPush(ctx context.Context, key string, values ...[]byte) error {
	return m.cache.LPush(ctx, key, values...)
}

func (m *Manager) LRange(ctx context.Context, key string, start, stop int64) ([][]byte, error) {
	return m.cache.LRange(ctx, key, start, stop)
}

func (m *Manager) SAdd(ctx context.Context, key string, members ...[]byte) error {
	return m.cache.SAdd(ctx, key, members...)
}

func (m *Manager) SMembers(ctx context.Context, key string) ([][]byte, error) {
	return m.cache.SMembers(ctx, key)
}

func (m *Manager) FlushAll(ctx context.Context) error {
	return m.cache.FlushAll(ctx)
}

func (m *Manager) Close() error {
	return m.cache.Close()
}

// GetOrSet implements cache-aside pattern
func (m *Manager) GetOrSet(ctx context.Context, key string, ttl time.Duration, fetcher func() ([]byte, error)) ([]byte, error) {
	// Try to get from cache
	if data, err := m.cache.Get(ctx, key); err == nil {
		log.Debug().Str("key", key).Msg("cache hit")
		return data, nil
	}

	log.Debug().Str("key", key).Msg("cache miss")

	// Fetch from source
	data, err := fetcher()
	if err != nil {
		return nil, err
	}

	// Store in cache (don't fail if cache set fails)
	if err := m.cache.Set(ctx, key, data, ttl); err != nil {
		log.Error().Err(err).Str("key", key).Msg("failed to set cache")
	}

	return data, nil
}

// InvalidateByTags removes all keys associated with given tags
func (m *Manager) InvalidateByTags(ctx context.Context, tags ...string) error {
	for _, tag := range tags {
		if keys, exists := m.tags[tag]; exists {
			for _, key := range keys {
				if err := m.cache.Delete(ctx, key); err != nil {
					log.Error().Err(err).Str("key", key).Str("tag", tag).Msg("failed to invalidate cache key")
				}
			}
			delete(m.tags, tag)
		}
	}
	return nil
}

// Warmup preloads cache with given keys
func (m *Manager) Warmup(ctx context.Context, keys []string) error {
	// Implementation depends on your data sources
	return nil
}

// SetWithTags sets a cache value and associates it with tags
func (m *Manager) SetWithTags(ctx context.Context, key string, value []byte, ttl time.Duration, tags ...string) error {
	if err := m.cache.Set(ctx, key, value, ttl); err != nil {
		return err
	}

	// Associate key with tags
	for _, tag := range tags {
		m.tags[tag] = append(m.tags[tag], key)
	}

	return nil
}

// Helper methods for common data types
func (m *Manager) GetJSON(ctx context.Context, key string, v interface{}) error {
	data, err := m.cache.Get(ctx, key)
	if err != nil {
		return err
	}
	return json.Unmarshal(data, v)
}

func (m *Manager) SetJSON(ctx context.Context, key string, v interface{}, ttl time.Duration) error {
	data, err := json.Marshal(v)
	if err != nil {
		return err
	}
	return m.cache.Set(ctx, key, data, ttl)
}
