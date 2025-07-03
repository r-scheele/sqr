package storage

import (
	"context"
	"fmt"
	"time"

	"github.com/r-scheele/sqr/internal/cache"
)

type MediaCache struct {
	redis cache.Manager
}

func NewMediaCache(redis cache.Manager) *MediaCache {
	return &MediaCache{
		redis: redis,
	}
}

func (c *MediaCache) GetMediaURL(ctx context.Context, mediaUUID string, variant string) (string, error) {
	cacheKey := fmt.Sprintf("media:url:%s:%s", mediaUUID, variant)

	// Try cache first
	urlBytes, err := c.redis.Get(ctx, cacheKey)
	if err == nil {
		return string(urlBytes), nil
	}

	// TODO: Generate URL from storage provider
	generatedURL := fmt.Sprintf("https://example.com/media/%s/%s", mediaUUID, variant)

	// Cache for 1 hour
	c.redis.Set(ctx, cacheKey, []byte(generatedURL), time.Hour)

	return generatedURL, nil
}

func (c *MediaCache) InvalidateMedia(ctx context.Context, mediaUUID string) error {
	pattern := fmt.Sprintf("media:url:%s:*", mediaUUID)
	return c.redis.DeletePattern(ctx, pattern)
}
