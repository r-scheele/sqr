package cache

import (
	"fmt"
	"strings"

	"github.com/r-scheele/sqr/internal/util"
)

func NewCache(config util.Config) (Cache, error) {

	if !config.CacheEnabled {
		return NewNoOpCache(), nil
	}

	switch strings.ToLower(config.CacheType) {
	case "redis":
		return NewRedisCache(config)
	case "memory":
		return NewMemoryCache(config), nil
	case "noop", "disabled":
		return NewNoOpCache(), nil
	default:
		return nil, fmt.Errorf("unsupported cache type: %s", config.CacheType)
	}
}

func NewCacheManager(config util.Config) (CacheManager, error) {
	cache, err := NewCache(config)
	if err != nil {
		return nil, err
	}
	return NewManager(cache), nil
}
