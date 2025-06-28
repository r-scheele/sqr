// internal/cache/memory.go
package cache

import (
	"context"
	"sync"
	"time"

	"github.com/r-scheele/sqr/internal/util"
)

type memoryItem struct {
	value     []byte
	expiresAt time.Time
}

type MemoryCache struct {
	items   map[string]*memoryItem
	mutex   sync.RWMutex
	maxSize int
	ttl     time.Duration
	ticker  *time.Ticker
	done    chan bool
}

func NewMemoryCache(config util.Config) *MemoryCache {
	cache := &MemoryCache{
		items:   make(map[string]*memoryItem),
		maxSize: config.MemoryCacheSize,
		ttl:     config.MemoryCacheTTL,
		done:    make(chan bool),
	}

	// Start cleanup goroutine
	cache.ticker = time.NewTicker(config.MemoryCacheCleanUpInterval)
	go cache.cleanup()

	return cache
}

func (m *MemoryCache) cleanup() {
	for {
		select {
		case <-m.ticker.C:
			m.evictExpired()
		case <-m.done:
			return
		}
	}
}

func (m *MemoryCache) evictExpired() {
	m.mutex.Lock()
	defer m.mutex.Unlock()

	now := time.Now()
	for key, item := range m.items {
		if now.After(item.expiresAt) {
			delete(m.items, key)
		}
	}
}

func (m *MemoryCache) evictOldest() {
	if len(m.items) == 0 {
		return
	}

	var oldestKey string
	var oldestTime time.Time

	for key, item := range m.items {
		if oldestKey == "" || item.expiresAt.Before(oldestTime) {
			oldestKey = key
			oldestTime = item.expiresAt
		}
	}

	if oldestKey != "" {
		delete(m.items, oldestKey)
	}
}

func (m *MemoryCache) Get(ctx context.Context, key string) ([]byte, error) {
	m.mutex.RLock()
	defer m.mutex.RUnlock()

	item, exists := m.items[key]
	if !exists {
		return nil, ErrCacheNotFound
	}

	if time.Now().After(item.expiresAt) {
		return nil, ErrCacheNotFound
	}

	return item.value, nil
}

func (m *MemoryCache) Set(ctx context.Context, key string, value []byte, ttl time.Duration) error {
	m.mutex.Lock()
	defer m.mutex.Unlock()

	// Use provided TTL or default
	if ttl == 0 {
		ttl = m.ttl
	}

	// Evict if at capacity
	if len(m.items) >= m.maxSize {
		m.evictOldest()
	}

	m.items[key] = &memoryItem{
		value:     make([]byte, len(value)),
		expiresAt: time.Now().Add(ttl),
	}
	copy(m.items[key].value, value)

	return nil
}

func (m *MemoryCache) Delete(ctx context.Context, key string) error {
	m.mutex.Lock()
	defer m.mutex.Unlock()

	delete(m.items, key)
	return nil
}

func (m *MemoryCache) DeletePattern(ctx context.Context, pattern string) error {
	// Simple pattern matching - could be enhanced with regex
	m.mutex.Lock()
	defer m.mutex.Unlock()

	for key := range m.items {
		// Simple wildcard matching
		if matchesPattern(key, pattern) {
			delete(m.items, key)
		}
	}

	return nil
}

func (m *MemoryCache) Exists(ctx context.Context, key string) (bool, error) {
	m.mutex.RLock()
	defer m.mutex.RUnlock()

	item, exists := m.items[key]
	if !exists {
		return false, nil
	}

	return time.Now().Before(item.expiresAt), nil
}

// Hash operations - simplified implementation
func (m *MemoryCache) HGet(ctx context.Context, key, field string) ([]byte, error) {
	return m.Get(ctx, key+":"+field)
}

func (m *MemoryCache) HSet(ctx context.Context, key, field string, value []byte, ttl time.Duration) error {
	return m.Set(ctx, key+":"+field, value, ttl)
}

func (m *MemoryCache) HDelete(ctx context.Context, key string, fields ...string) error {
	for _, field := range fields {
		m.Delete(ctx, key+":"+field)
	}
	return nil
}

// List operations - simplified
func (m *MemoryCache) LPush(ctx context.Context, key string, values ...[]byte) error {
	// Simplified implementation
	return nil
}

func (m *MemoryCache) LRange(ctx context.Context, key string, start, stop int64) ([][]byte, error) {
	return nil, nil
}

// Set operations - simplified
func (m *MemoryCache) SAdd(ctx context.Context, key string, members ...[]byte) error {
	return nil
}

func (m *MemoryCache) SMembers(ctx context.Context, key string) ([][]byte, error) {
	return nil, nil
}

func (m *MemoryCache) FlushAll(ctx context.Context) error {
	m.mutex.Lock()
	defer m.mutex.Unlock()

	m.items = make(map[string]*memoryItem)
	return nil
}

func (m *MemoryCache) Close() error {
	m.ticker.Stop()
	m.done <- true
	return nil
}

func matchesPattern(key, pattern string) bool {
	// Simple wildcard implementation
	if pattern == "*" {
		return true
	}
	// Could be enhanced with proper pattern matching
	return key == pattern
}
