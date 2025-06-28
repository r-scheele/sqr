-- Create a new landlord profile
-- name: CreateLandlordProfile :one
INSERT INTO landlord_profiles (
  user_id, business_name, business_registration, tax_id, bank_name,
  bank_account, bank_account_name, guarantor_name, guarantor_phone,
  guarantor_address
) VALUES (
  $1, $2, $3, $4, $5, $6, $7, $8, $9, $10
) RETURNING *;

-- Get landlord profile by ID
-- name: GetLandlordProfileByID :one
SELECT * FROM landlord_profiles 
WHERE id = $1 LIMIT 1;

-- Get landlord profile by user ID
-- name: GetLandlordProfileByUserID :one
SELECT * FROM landlord_profiles 
WHERE user_id = $1 LIMIT 1;

-- Update landlord profile
-- name: UpdateLandlordProfile :one
UPDATE landlord_profiles 
SET business_name = $2, business_registration = $3, tax_id = $4,
    bank_name = $5, bank_account = $6, bank_account_name = $7,
    guarantor_name = $8, guarantor_phone = $9, guarantor_address = $10,
    updated_at = NOW()
WHERE user_id = $1 
RETURNING *;

-- Update landlord banking details
-- name: UpdateLandlordBankingDetails :one
UPDATE landlord_profiles 
SET bank_name = $2, bank_account = $3, bank_account_name = $4, updated_at = NOW()
WHERE user_id = $1 
RETURNING *;

-- Update landlord business details
-- name: UpdateLandlordBusinessDetails :one
UPDATE landlord_profiles 
SET business_name = $2, business_registration = $3, tax_id = $4, updated_at = NOW()
WHERE user_id = $1 
RETURNING *;

-- Update landlord guarantor details
-- name: UpdateLandlordGuarantorDetails :one
UPDATE landlord_profiles 
SET guarantor_name = $2, guarantor_phone = $3, guarantor_address = $4, updated_at = NOW()
WHERE user_id = $1 
RETURNING *;

-- Update landlord stats
-- name: UpdateLandlordStats :one
UPDATE landlord_profiles 
SET total_properties = $2, average_rating = $3, updated_at = NOW()
WHERE user_id = $1 
RETURNING *;

-- Increment landlord property count
-- name: IncrementLandlordPropertyCount :exec
UPDATE landlord_profiles 
SET total_properties = total_properties + 1, updated_at = NOW()
WHERE user_id = $1;

-- Decrement landlord property count
-- name: DecrementLandlordPropertyCount :exec
UPDATE landlord_profiles 
SET total_properties = GREATEST(total_properties - 1, 0), updated_at = NOW()
WHERE user_id = $1;

-- List top landlords by rating
-- name: ListTopLandlordsByRating :many
SELECT lp.*, u.first_name, u.last_name, u.email 
FROM landlord_profiles lp
JOIN users u ON lp.user_id = u.id
WHERE u.is_active = true AND lp.total_properties > 0
ORDER BY lp.average_rating DESC, lp.total_properties DESC
LIMIT $1 OFFSET $2;

-- List landlords by property count
-- name: ListLandlordsByPropertyCount :many
SELECT lp.*, u.first_name, u.last_name, u.email 
FROM landlord_profiles lp
JOIN users u ON lp.user_id = u.id
WHERE u.is_active = true
ORDER BY lp.total_properties DESC, lp.average_rating DESC
LIMIT $1 OFFSET $2;

-- Delete landlord profile
-- name: DeleteLandlordProfile :exec
DELETE FROM landlord_profiles 
WHERE user_id = $1;
