-- Create property search cache
-- name: CreatePropertySearchCache :one
INSERT INTO property_search_cache (
  search_hash, search_params, property_ids, result_count, expires_at
) VALUES (
  $1, $2, $3, $4, $5
) RETURNING *;

-- Get property search cache by ID
-- name: GetPropertySearchCacheByID :one
SELECT * FROM property_search_cache 
WHERE id = $1 LIMIT 1;

-- Get cache by search hash
-- name: GetCacheBySearchHash :one
SELECT * FROM property_search_cache 
WHERE search_hash = $1 AND expires_at > NOW()
LIMIT 1;

-- Update search cache
-- name: UpdateSearchCache :one
UPDATE property_search_cache 
SET property_ids = $2, result_count = $3, expires_at = $4
WHERE search_hash = $1 
RETURNING *;

-- Extend cache expiry
-- name: ExtendCacheExpiry :one
UPDATE property_search_cache 
SET expires_at = $2
WHERE search_hash = $1 
RETURNING *;

-- Get active cache entries
-- name: GetActiveCacheEntries :many
SELECT * FROM property_search_cache 
WHERE expires_at > NOW()
ORDER BY created_at DESC
LIMIT $1 OFFSET $2;

-- Get expired cache entries
-- name: GetExpiredCacheEntries :many
SELECT * FROM property_search_cache 
WHERE expires_at <= NOW()
ORDER BY expires_at ASC
LIMIT $1 OFFSET $2;

-- Get cache entries by result count
-- name: GetCacheEntriesByResultCount :many
SELECT * FROM property_search_cache 
WHERE result_count >= $1 AND expires_at > NOW()
ORDER BY result_count DESC, created_at DESC
LIMIT $2 OFFSET $3;

-- Get popular search caches
-- name: GetPopularSearchCaches :many
SELECT search_hash, search_params, result_count, COUNT(*) as access_count
FROM property_search_cache 
WHERE created_at >= $1
GROUP BY search_hash, search_params, result_count
ORDER BY access_count DESC, result_count DESC
LIMIT $2 OFFSET $3;

-- Search cache entries
-- name: SearchCacheEntries :many
SELECT * FROM property_search_cache 
WHERE search_params ILIKE '%' || $1 || '%'
ORDER BY created_at DESC
LIMIT $2 OFFSET $3;

-- Count active cache entries
-- name: CountActiveCacheEntries :one
SELECT COUNT(*) FROM property_search_cache 
WHERE expires_at > NOW();

-- Count expired cache entries
-- name: CountExpiredCacheEntries :one
SELECT COUNT(*) FROM property_search_cache 
WHERE expires_at <= NOW();

-- Count total cache entries
-- name: CountTotalCacheEntries :one
SELECT COUNT(*) FROM property_search_cache;

-- Get cache statistics
-- name: GetCacheStatistics :one
SELECT 
  COUNT(*) as total_entries,
  COUNT(CASE WHEN expires_at > NOW() THEN 1 END) as active_entries,
  COUNT(CASE WHEN expires_at <= NOW() THEN 1 END) as expired_entries,
  AVG(result_count) as average_result_count,
  MAX(result_count) as max_result_count,
  MIN(result_count) as min_result_count
FROM property_search_cache;

-- Get cache hit statistics
-- name: GetCacheHitStatistics :one
SELECT 
  COUNT(DISTINCT search_hash) as unique_searches,
  COUNT(*) as total_cache_entries,
  AVG(result_count) as average_results,
  SUM(CASE WHEN expires_at > NOW() THEN 1 ELSE 0 END) as active_caches
FROM property_search_cache 
WHERE created_at >= $1;

-- Get most cached searches
-- name: GetMostCachedSearches :many
SELECT 
  search_params,
  COUNT(*) as cache_count,
  AVG(result_count) as avg_results,
  MAX(created_at) as last_cached
FROM property_search_cache 
WHERE created_at >= $1
GROUP BY search_params
ORDER BY cache_count DESC, avg_results DESC
LIMIT $2 OFFSET $3;

-- Check if search is cached
-- name: CheckSearchCached :one
SELECT EXISTS(
  SELECT 1 FROM property_search_cache 
  WHERE search_hash = $1 AND expires_at > NOW()
);

-- Clean up expired cache entries
-- name: CleanupExpiredCache :exec
DELETE FROM property_search_cache 
WHERE expires_at <= NOW();

-- Clean up old cache entries
-- name: CleanupOldCache :exec
DELETE FROM property_search_cache 
WHERE created_at < $1;

-- Delete cache by search hash
-- name: DeleteCacheBySearchHash :exec
DELETE FROM property_search_cache 
WHERE search_hash = $1;

-- Delete property search cache
-- name: DeletePropertySearchCache :exec
DELETE FROM property_search_cache 
WHERE id = $1;
