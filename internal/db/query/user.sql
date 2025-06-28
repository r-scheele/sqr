-- Create a new user
-- name: CreateUser :one
INSERT INTO users (
  email, phone, password_hash, first_name, last_name, user_type, nin, profile_picture_url
) VALUES (
  $1, $2, $3, $4, $5, $6, $7, $8
) RETURNING *;

-- Get user by ID
-- name: GetUserByID :one
SELECT * FROM users 
WHERE id = $1 LIMIT 1;

-- Get user by email
-- name: GetUserByEmail :one
SELECT * FROM users 
WHERE email = $1 LIMIT 1;

-- Get user by phone
-- name: GetUserByPhone :one
SELECT * FROM users 
WHERE phone = $1 LIMIT 1;

-- Update user
-- name: UpdateUser :one
UPDATE users 
SET email = $2, phone = $3, first_name = $4, last_name = $5, nin = $6, 
    profile_picture_url = $7, updated_at = NOW()
WHERE id = $1 
RETURNING *;

-- Update user password
-- name: UpdateUserPassword :exec
UPDATE users 
SET password_hash = $2, updated_at = NOW()
WHERE id = $1;

-- Update user verification status
-- name: UpdateUserVerificationStatus :exec
UPDATE users 
SET is_verified = $2, updated_at = NOW()
WHERE id = $1;

-- Update user active status
-- name: UpdateUserActiveStatus :exec
UPDATE users 
SET is_active = $2, updated_at = NOW()
WHERE id = $1;

-- Update user last login time
-- name: UpdateUserLastLogin :exec
UPDATE users 
SET last_login = NOW() 
WHERE id = $1;

-- List users by type
-- name: ListUsersByType :many
SELECT * FROM users 
WHERE user_type = $1 AND is_active = true
ORDER BY created_at DESC
LIMIT $2 OFFSET $3;

-- Count users by type
-- name: CountUsersByType :one
SELECT COUNT(*) FROM users 
WHERE user_type = $1 AND is_active = true;

-- Search users
-- name: SearchUsers :many
SELECT * FROM users 
WHERE (first_name ILIKE $1 OR last_name ILIKE $1 OR email ILIKE $1) 
  AND is_active = true
ORDER BY created_at DESC
LIMIT $2 OFFSET $3;

-- Delete user (soft delete by setting inactive)
-- name: DeleteUser :exec
UPDATE users 
SET is_active = false, updated_at = NOW()
WHERE id = $1;