-- Create a new tenant profile
-- name: CreateTenantProfile :one
INSERT INTO tenant_profiles (
  user_id, preferred_locations, budget_min, budget_max, bedrooms_min, bedrooms_max,
  preferred_amenities, occupation, employer, monthly_income, previous_address,
  "references", pet_friendly
) VALUES (
  $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13
) RETURNING *;

-- Get tenant profile by ID
-- name: GetTenantProfileByID :one
SELECT * FROM tenant_profiles 
WHERE id = $1 LIMIT 1;

-- Get tenant profile by user ID
-- name: GetTenantProfileByUserID :one
SELECT * FROM tenant_profiles 
WHERE user_id = $1 LIMIT 1;

-- Update tenant profile
-- name: UpdateTenantProfile :one
UPDATE tenant_profiles 
SET preferred_locations = $2, budget_min = $3, budget_max = $4, 
    bedrooms_min = $5, bedrooms_max = $6, preferred_amenities = $7,
    occupation = $8, employer = $9, monthly_income = $10, 
    previous_address = $11, "references" = $12, pet_friendly = $13, 
    updated_at = NOW()
WHERE user_id = $1 
RETURNING *;

-- Update tenant budget
-- name: UpdateTenantBudget :one
UPDATE tenant_profiles 
SET budget_min = $2, budget_max = $3, updated_at = NOW()
WHERE user_id = $1 
RETURNING *;

-- Update tenant preferences
-- name: UpdateTenantPreferences :one
UPDATE tenant_profiles 
SET preferred_locations = $2, bedrooms_min = $3, bedrooms_max = $4,
    preferred_amenities = $5, pet_friendly = $6, updated_at = NOW()
WHERE user_id = $1 
RETURNING *;

-- Update tenant employment details
-- name: UpdateTenantEmploymentDetails :one
UPDATE tenant_profiles 
SET occupation = $2, employer = $3, monthly_income = $4, updated_at = NOW()
WHERE user_id = $1 
RETURNING *;

-- Search tenant profiles by criteria
-- name: SearchTenantProfiles :many
SELECT tp.*, u.first_name, u.last_name, u.email 
FROM tenant_profiles tp
JOIN users u ON tp.user_id = u.id
WHERE ($1::decimal IS NULL OR tp.budget_min >= $1)
  AND ($2::decimal IS NULL OR tp.budget_max <= $2)
  AND ($3::integer IS NULL OR tp.bedrooms_min >= $3)
  AND ($4::integer IS NULL OR tp.bedrooms_max <= $4)
  AND u.is_active = true
ORDER BY tp.updated_at DESC
LIMIT $5 OFFSET $6;

-- Delete tenant profile
-- name: DeleteTenantProfile :exec
DELETE FROM tenant_profiles 
WHERE user_id = $1;
