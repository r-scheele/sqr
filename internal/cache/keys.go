// internal/cache/keys.go
package cache

import (
	"fmt"
	"time"
)

const (
	// TTL Constants
	UserCacheTTL         = 15 * time.Minute
	PropertyCacheTTL     = 30 * time.Minute
	SearchCacheTTL       = 5 * time.Minute
	SessionCacheTTL      = 24 * time.Hour
	VerificationCacheTTL = 1 * time.Hour
	StatsCacheTTL        = 10 * time.Minute
)

// Cache key builders
func UserKey(userID int64) string {
	return fmt.Sprintf("user:id:%d", userID)
}

func UserByEmailKey(email string) string {
	return fmt.Sprintf("user:email:%s", email)
}

func PropertyKey(propertyID int64) string {
	return fmt.Sprintf("property:id:%d", propertyID)
}

func PropertySearchKey(query string, filters map[string]interface{}) string {
	return fmt.Sprintf("search:properties:%s", hashParams(query, filters))
}

func UserSessionKey(sessionID string) string {
	return fmt.Sprintf("session:%s", sessionID)
}

func VerificationKey(userID int64, verificationType string) string {
	return fmt.Sprintf("verification:%d:%s", userID, verificationType)
}

func StatsKey(statsType string, period string) string {
	return fmt.Sprintf("stats:%s:%s", statsType, period)
}

func TenantProfileKey(userID int64) string {
	return fmt.Sprintf("tenant_profile:user:%d", userID)
}

// Tags for cache invalidation
const (
	UserTag          = "user"
	PropertyTag      = "property"
	SearchTag        = "search"
	SessionTag       = "session"
	VerificationTag  = "verification"
	StatsTag         = "stats"
	TenantProfileTag = "tenant_profile"
)

func hashParams(query string, filters map[string]interface{}) string {
	return fmt.Sprintf("%d", hash(query+fmt.Sprintf("%v", filters)))
}

func hash(s string) uint32 {
	h := uint32(0)
	for _, c := range s {
		h = h*31 + uint32(c)
	}
	return h
}
