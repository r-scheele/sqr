-- Create a new user verification
-- name: CreateUserVerification :one
INSERT INTO user_verifications (
  user_id, verification_type, verification_status, verification_data
) VALUES (
  $1, $2, $3, $4
) RETURNING *;

-- Get user verification by ID
-- name: GetUserVerificationByID :one
SELECT * FROM user_verifications 
WHERE id = $1 LIMIT 1;

-- Get user verifications by user ID
-- name: GetUserVerificationsByUserID :many
SELECT * FROM user_verifications 
WHERE user_id = $1
ORDER BY created_at DESC;

-- Get user verification by type
-- name: GetUserVerificationByType :one
SELECT * FROM user_verifications 
WHERE user_id = $1 AND verification_type = $2
ORDER BY created_at DESC
LIMIT 1;

-- Update verification status
-- name: UpdateVerificationStatus :one
UPDATE user_verifications 
SET verification_status = $2, verified_at = CASE WHEN $2 = 'verified' THEN NOW() ELSE NULL END,
    verified_by = $3
WHERE id = $1 
RETURNING *;

-- Update verification data
-- name: UpdateVerificationData :one
UPDATE user_verifications 
SET verification_data = $2
WHERE id = $1 
RETURNING *;

-- List pending verifications
-- name: ListPendingVerifications :many
SELECT uv.*, u.first_name, u.last_name, u.email 
FROM user_verifications uv
JOIN users u ON uv.user_id = u.id
WHERE uv.verification_status = 'pending'
ORDER BY uv.created_at ASC
LIMIT $1 OFFSET $2;

-- Count pending verifications
-- name: CountPendingVerifications :one
SELECT COUNT(*) FROM user_verifications 
WHERE verification_status = 'pending';

-- List verifications by type and status
-- name: ListVerificationsByTypeAndStatus :many
SELECT uv.*, u.first_name, u.last_name, u.email 
FROM user_verifications uv
JOIN users u ON uv.user_id = u.id
WHERE uv.verification_type = $1 AND uv.verification_status = $2
ORDER BY uv.created_at DESC
LIMIT $3 OFFSET $4;

-- Delete user verification
-- name: DeleteUserVerification :exec
DELETE FROM user_verifications 
WHERE id = $1;
