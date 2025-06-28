-- Create user rating
-- name: CreateUserRating :one
INSERT INTO user_ratings (
  rater_id, rated_user_id, rating_type, related_entity_type, related_entity_id,
  rating, review_text
) VALUES (
  $1, $2, $3, $4, $5, $6, $7
) RETURNING *;

-- Get user rating by ID
-- name: GetUserRatingByID :one
SELECT * FROM user_ratings 
WHERE id = $1 LIMIT 1;

-- Get rating with details
-- name: GetUserRatingWithDetails :one
SELECT ur.*, 
       rater.first_name as rater_first_name, rater.last_name as rater_last_name,
       rated.first_name as rated_first_name, rated.last_name as rated_last_name
FROM user_ratings ur
JOIN users rater ON ur.rater_id = rater.id
JOIN users rated ON ur.rated_user_id = rated.id
WHERE ur.id = $1 LIMIT 1;

-- Update user rating
-- name: UpdateUserRating :one
UPDATE user_ratings 
SET rating = $2, review_text = $3, updated_at = NOW()
WHERE id = $1 
RETURNING *;

-- Add response to rating
-- name: AddResponseToRating :one
UPDATE user_ratings 
SET response_text = $2, updated_at = NOW()
WHERE id = $1 
RETURNING *;

-- Verify rating
-- name: VerifyRating :exec
UPDATE user_ratings 
SET is_verified = true, updated_at = NOW()
WHERE id = $1;

-- Get ratings for user
-- name: GetRatingsForUser :many
SELECT ur.*, 
       rater.first_name as rater_first_name, rater.last_name as rater_last_name,
       rater.profile_picture_url as rater_profile_picture
FROM user_ratings ur
JOIN users rater ON ur.rater_id = rater.id
WHERE ur.rated_user_id = $1
ORDER BY ur.created_at DESC
LIMIT $2 OFFSET $3;

-- Get ratings by user
-- name: GetRatingsByUser :many
SELECT ur.*, 
       rated.first_name as rated_first_name, rated.last_name as rated_last_name,
       rated.profile_picture_url as rated_profile_picture
FROM user_ratings ur
JOIN users rated ON ur.rated_user_id = rated.id
WHERE ur.rater_id = $1
ORDER BY ur.created_at DESC
LIMIT $2 OFFSET $3;

-- Get ratings by type for user
-- name: GetRatingsByTypeForUser :many
SELECT ur.*, 
       rater.first_name as rater_first_name, rater.last_name as rater_last_name
FROM user_ratings ur
JOIN users rater ON ur.rater_id = rater.id
WHERE ur.rated_user_id = $1 AND ur.rating_type = $2
ORDER BY ur.created_at DESC
LIMIT $3 OFFSET $4;

-- Get verified ratings for user
-- name: GetVerifiedRatingsForUser :many
SELECT ur.*, 
       rater.first_name as rater_first_name, rater.last_name as rater_last_name
FROM user_ratings ur
JOIN users rater ON ur.rater_id = rater.id
WHERE ur.rated_user_id = $1 AND ur.is_verified = true
ORDER BY ur.created_at DESC
LIMIT $2 OFFSET $3;

-- Get rating for entity
-- name: GetRatingForEntity :one
SELECT ur.*, 
       rater.first_name as rater_first_name, rater.last_name as rater_last_name,
       rated.first_name as rated_first_name, rated.last_name as rated_last_name
FROM user_ratings ur
JOIN users rater ON ur.rater_id = rater.id
JOIN users rated ON ur.rated_user_id = rated.id
WHERE ur.rater_id = $1 AND ur.rated_user_id = $2 
  AND ur.related_entity_type = $3 AND ur.related_entity_id = $4
LIMIT 1;

-- Check if rating exists
-- name: CheckRatingExists :one
SELECT EXISTS(
  SELECT 1 FROM user_ratings 
  WHERE rater_id = $1 AND rated_user_id = $2 
    AND related_entity_type = $3 AND related_entity_id = $4
);

-- Get user rating statistics
-- name: GetUserRatingStatistics :one
SELECT 
  COUNT(*) as total_ratings,
  AVG(rating) as average_rating,
  COUNT(CASE WHEN rating = 5 THEN 1 END) as five_star_count,
  COUNT(CASE WHEN rating = 4 THEN 1 END) as four_star_count,
  COUNT(CASE WHEN rating = 3 THEN 1 END) as three_star_count,
  COUNT(CASE WHEN rating = 2 THEN 1 END) as two_star_count,
  COUNT(CASE WHEN rating = 1 THEN 1 END) as one_star_count
FROM user_ratings 
WHERE rated_user_id = $1 AND is_verified = true;

-- Get landlord ratings
-- name: GetLandlordRatings :many
SELECT ur.*, 
       rater.first_name as rater_first_name, rater.last_name as rater_last_name
FROM user_ratings ur
JOIN users rater ON ur.rater_id = rater.id
JOIN users rated ON ur.rated_user_id = rated.id
WHERE rated.user_type = 'landlord' AND ur.rating_type = 'tenant_to_landlord'
ORDER BY ur.created_at DESC
LIMIT $1 OFFSET $2;

-- Get tenant ratings
-- name: GetTenantRatings :many
SELECT ur.*, 
       rater.first_name as rater_first_name, rater.last_name as rater_last_name
FROM user_ratings ur
JOIN users rater ON ur.rater_id = rater.id
JOIN users rated ON ur.rated_user_id = rated.id
WHERE rated.user_type = 'tenant' AND ur.rating_type = 'landlord_to_tenant'
ORDER BY ur.created_at DESC
LIMIT $1 OFFSET $2;

-- Get agent ratings
-- name: GetAgentRatings :many
SELECT ur.*, 
       rater.first_name as rater_first_name, rater.last_name as rater_last_name
FROM user_ratings ur
JOIN users rater ON ur.rater_id = rater.id
JOIN users rated ON ur.rated_user_id = rated.id
WHERE rated.user_type = 'inspection_agent' AND ur.rating_type = 'tenant_to_agent'
ORDER BY ur.created_at DESC
LIMIT $1 OFFSET $2;

-- Count ratings for user
-- name: CountRatingsForUser :one
SELECT COUNT(*) FROM user_ratings 
WHERE rated_user_id = $1;

-- Count verified ratings for user
-- name: CountVerifiedRatingsForUser :one
SELECT COUNT(*) FROM user_ratings 
WHERE rated_user_id = $1 AND is_verified = true;

-- Get recent ratings
-- name: GetRecentRatings :many
SELECT ur.*, 
       rater.first_name as rater_first_name, rater.last_name as rater_last_name,
       rated.first_name as rated_first_name, rated.last_name as rated_last_name
FROM user_ratings ur
JOIN users rater ON ur.rater_id = rater.id
JOIN users rated ON ur.rated_user_id = rated.id
ORDER BY ur.created_at DESC
LIMIT $1 OFFSET $2;

-- Delete user rating
-- name: DeleteUserRating :exec
DELETE FROM user_ratings 
WHERE id = $1;
