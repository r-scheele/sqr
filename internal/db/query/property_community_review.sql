-- Create property community review
-- name: CreatePropertyCommunityReview :one
INSERT INTO property_community_reviews (
  property_id, user_id, electricity_rating, water_rating, security_rating,
  noise_level, road_condition, flooding_risk, internet_connectivity,
  proximity_to_amenities, comment
) VALUES (
  $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11
) RETURNING *;

-- Get property community review by ID
-- name: GetPropertyCommunityReviewByID :one
SELECT * FROM property_community_reviews 
WHERE id = $1 LIMIT 1;

-- Get reviews for property
-- name: GetPropertyCommunityReviews :many
SELECT pcr.*, u.first_name, u.last_name
FROM property_community_reviews pcr
JOIN users u ON pcr.user_id = u.id
WHERE pcr.property_id = $1
ORDER BY pcr.helpful_votes DESC, pcr.created_at DESC
LIMIT $2 OFFSET $3;

-- Get verified reviews for property
-- name: GetVerifiedPropertyCommunityReviews :many
SELECT pcr.*, u.first_name, u.last_name
FROM property_community_reviews pcr
JOIN users u ON pcr.user_id = u.id
WHERE pcr.property_id = $1 AND pcr.is_verified = true
ORDER BY pcr.helpful_votes DESC, pcr.created_at DESC
LIMIT $2 OFFSET $3;

-- Get user's review for property
-- name: GetUserPropertyReview :one
SELECT * FROM property_community_reviews 
WHERE property_id = $1 AND user_id = $2
LIMIT 1;

-- Update property community review
-- name: UpdatePropertyCommunityReview :one
UPDATE property_community_reviews 
SET electricity_rating = $2, water_rating = $3, security_rating = $4,
    noise_level = $5, road_condition = $6, flooding_risk = $7,
    internet_connectivity = $8, proximity_to_amenities = $9, comment = $10,
    updated_at = NOW()
WHERE id = $1 
RETURNING *;

-- Verify property review
-- name: VerifyPropertyReview :exec
UPDATE property_community_reviews 
SET is_verified = true, updated_at = NOW()
WHERE id = $1;

-- Increment helpful votes
-- name: IncrementReviewHelpfulVotes :exec
UPDATE property_community_reviews 
SET helpful_votes = helpful_votes + 1
WHERE id = $1;

-- Decrement helpful votes
-- name: DecrementReviewHelpfulVotes :exec
UPDATE property_community_reviews 
SET helpful_votes = GREATEST(helpful_votes - 1, 0)
WHERE id = $1;

-- Get average ratings for property
-- name: GetPropertyAverageRatings :one
SELECT 
  ROUND(AVG(electricity_rating), 2) as avg_electricity,
  ROUND(AVG(water_rating), 2) as avg_water,
  ROUND(AVG(security_rating), 2) as avg_security,
  ROUND(AVG(noise_level), 2) as avg_noise,
  ROUND(AVG(road_condition), 2) as avg_road,
  ROUND(AVG(flooding_risk), 2) as avg_flooding,
  ROUND(AVG(internet_connectivity), 2) as avg_internet,
  ROUND(AVG(proximity_to_amenities), 2) as avg_amenities,
  COUNT(*) as total_reviews
FROM property_community_reviews 
WHERE property_id = $1 AND is_verified = true;

-- Count reviews for property
-- name: CountPropertyReviews :one
SELECT COUNT(*) FROM property_community_reviews 
WHERE property_id = $1;

-- Count verified reviews for property
-- name: CountVerifiedPropertyReviews :one
SELECT COUNT(*) FROM property_community_reviews 
WHERE property_id = $1 AND is_verified = true;

-- List recent reviews
-- name: ListRecentPropertyReviews :many
SELECT pcr.*, u.first_name, u.last_name, p.title
FROM property_community_reviews pcr
JOIN users u ON pcr.user_id = u.id
JOIN properties p ON pcr.property_id = p.id
ORDER BY pcr.created_at DESC
LIMIT $1 OFFSET $2;

-- Delete property community review
-- name: DeletePropertyCommunityReview :exec
DELETE FROM property_community_reviews 
WHERE id = $1;
