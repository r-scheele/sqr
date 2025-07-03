package db

import (
	"context"
	"fmt"

	"github.com/r-scheele/sqr/internal/cache"
)

type CachedStore struct {
	*SQLStore
	cache cache.CacheManager
}

func NewCachedStore(store *SQLStore, cache cache.CacheManager) *CachedStore {
	return &CachedStore{
		SQLStore: store,
		cache:    cache,
	}
}

// Cached user operations
func (s *CachedStore) GetUserByID(ctx context.Context, id int64) (User, error) {
	cacheKey := cache.UserKey(id)

	var user User
	if err := s.cache.GetJSON(ctx, cacheKey, &user); err == nil {
		return user, nil
	}

	// Cache miss - get from database
	user, err := s.SQLStore.GetUserByID(ctx, id)
	if err != nil {
		return user, err
	}

	// Cache the result
	s.cache.SetJSON(ctx, cacheKey, user, cache.UserCacheTTL)

	return user, nil
}

func (s *CachedStore) GetUserByEmail(ctx context.Context, email string) (User, error) {
	cacheKey := cache.UserByEmailKey(email)

	var user User
	if err := s.cache.GetJSON(ctx, cacheKey, &user); err == nil {
		return user, nil
	}

	user, err := s.SQLStore.GetUserByEmail(ctx, email)
	if err != nil {
		return user, err
	}

	// Cache the result with both keys
	s.cache.SetJSON(ctx, cacheKey, user, cache.UserCacheTTL)
	s.cache.SetJSON(ctx, cache.UserKey(user.ID), user, cache.UserCacheTTL)

	return user, nil
}

func (s *CachedStore) UpdateUser(ctx context.Context, arg UpdateUserParams) (User, error) {
	user, err := s.SQLStore.UpdateUser(ctx, arg)
	if err != nil {
		return user, err
	}

	// Invalidate cache
	s.cache.Delete(ctx, cache.UserKey(user.ID))
	s.cache.Delete(ctx, cache.UserByEmailKey(user.Email))

	return user, nil
}

// Cached property operations
func (s *CachedStore) GetPropertyByID(ctx context.Context, id int64) (Property, error) {
	cacheKey := cache.PropertyKey(id)

	var property Property
	if err := s.cache.GetJSON(ctx, cacheKey, &property); err == nil {
		return property, nil
	}

	property, err := s.SQLStore.GetPropertyByID(ctx, id)
	if err != nil {
		return property, err
	}

	s.cache.SetJSON(ctx, cacheKey, property, cache.PropertyCacheTTL)

	return property, nil
}

func (s *CachedStore) ListProperties(ctx context.Context, arg ListPropertiesParams) ([]Property, error) {
	// Create cache key from search parameters
	searchKey := cache.PropertySearchKey("list", map[string]interface{}{
		"limit":  arg.Limit,
		"offset": arg.Offset,
	})

	var properties []Property
	if err := s.cache.GetJSON(ctx, searchKey, &properties); err == nil {
		return properties, nil
	}

	properties, err := s.SQLStore.ListProperties(ctx, arg)
	if err != nil {
		return properties, err
	}

	s.cache.SetJSON(ctx, searchKey, properties, cache.SearchCacheTTL)

	return properties, nil
}

// Session caching
func (s *CachedStore) GetUserSessionByID(ctx context.Context, id int64) (UserSession, error) {
	cacheKey := cache.UserSessionKey(fmt.Sprintf("%d", id))

	var session UserSession
	if err := s.cache.GetJSON(ctx, cacheKey, &session); err == nil {
		return session, nil
	}

	session, err := s.SQLStore.GetUserSessionByID(ctx, id)
	if err != nil {
		return session, err
	}

	s.cache.SetJSON(ctx, cacheKey, session, cache.SessionCacheTTL)

	return session, nil
}

func (s *CachedStore) GetUserSessionByToken(ctx context.Context, sessionToken string) (UserSession, error) {
	cacheKey := cache.UserSessionKey(sessionToken)

	var session UserSession
	if err := s.cache.GetJSON(ctx, cacheKey, &session); err == nil {
		return session, nil
	}

	session, err := s.SQLStore.GetUserSessionByToken(ctx, sessionToken)
	if err != nil {
		return session, err
	}

	s.cache.SetJSON(ctx, cacheKey, session, cache.SessionCacheTTL)

	return session, nil
}

func (s *CachedStore) CreateUserSession(ctx context.Context, arg CreateUserSessionParams) (UserSession, error) {
	session, err := s.SQLStore.CreateUserSession(ctx, arg)
	if err != nil {
		return session, err
	}

	// Cache the new session with both ID and token keys
	s.cache.SetJSON(ctx, cache.UserSessionKey(fmt.Sprintf("%d", session.ID)), session, cache.SessionCacheTTL)
	s.cache.SetJSON(ctx, cache.UserSessionKey(session.SessionToken), session, cache.SessionCacheTTL)

	return session, nil
}

func (s *CachedStore) GetTenantProfileByUserID(ctx context.Context, userID int64) (TenantProfile, error) {
	cacheKey := cache.TenantProfileKey(userID)

	var profile TenantProfile
	if err := s.cache.GetJSON(ctx, cacheKey, &profile); err == nil {
		return profile, nil
	}

	profile, err := s.SQLStore.GetTenantProfileByUserID(ctx, userID)
	if err != nil {
		return profile, err
	}

	s.cache.SetJSON(ctx, cacheKey, profile, cache.UserCacheTTL)

	return profile, nil
}

func (s *CachedStore) UpdateTenantProfile(ctx context.Context, arg UpdateTenantProfileParams) (TenantProfile, error) {
	profile, err := s.SQLStore.UpdateTenantProfile(ctx, arg)
	if err != nil {
		return profile, err
	}

	// Invalidate cache
	s.cache.Delete(ctx, cache.TenantProfileKey(profile.UserID))

	return profile, nil
}

// Session management with cache invalidation
func (s *CachedStore) DeactivateSession(ctx context.Context, sessionToken string) error {
	// First, get the session info before deactivating (for cache invalidation)
	session, sessionErr := s.SQLStore.GetUserSessionByToken(ctx, sessionToken)

	// Deactivate the session
	err := s.SQLStore.DeactivateSession(ctx, sessionToken)
	if err != nil {
		return err
	}

	// Invalidate cache entries for this session
	sessionTokenKey := cache.UserSessionKey(sessionToken)
	s.cache.Delete(ctx, sessionTokenKey)

	// If we successfully got the session info, also invalidate the ID-based cache
	if sessionErr == nil {
		sessionIDKey := cache.UserSessionKey(fmt.Sprintf("%d", session.ID))
		s.cache.Delete(ctx, sessionIDKey)
	}

	return nil
}

func (s *CachedStore) DeactivateUserSessions(ctx context.Context, userID int64) error {
	err := s.SQLStore.DeactivateUserSessions(ctx, userID)
	if err != nil {
		return err
	}

	// Note: For bulk operations like this, we could implement cache pattern matching
	// or use cache tags, but for now we'll rely on TTL expiration
	// Individual session invalidation would require knowing all session tokens for a user

	return nil
}

// Cache management methods
func (s *CachedStore) InvalidateUserCache(ctx context.Context, userID int64) {
	// Invalidate user-related caches
	s.cache.Delete(ctx, cache.UserKey(userID))
	s.cache.Delete(ctx, cache.TenantProfileKey(userID))
	// Note: We could add more user-related cache invalidations here
}
