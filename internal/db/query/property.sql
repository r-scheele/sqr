-- Create a new property
-- name: CreateProperty :one
INSERT INTO properties (
  landlord_id, title, description, property_type, address, city, state, country,
  latitude, longitude, bedrooms, bathrooms, rent_amount, rent_period,
  security_deposit, agency_fee, legal_fee, amenities, furnishing_status,
  parking_spaces, total_area, expires_at
) VALUES (
  $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22
) RETURNING *;

-- Get property by ID
-- name: GetPropertyByID :one
SELECT * FROM properties 
WHERE id = $1 LIMIT 1;

-- Get property with landlord details
-- name: GetPropertyWithLandlord :one
SELECT p.*, u.first_name, u.last_name, u.email, u.phone,
       lp.business_name, lp.average_rating as landlord_rating
FROM properties p
JOIN users u ON p.landlord_id = u.id
LEFT JOIN landlord_profiles lp ON u.id = lp.user_id
WHERE p.id = $1 LIMIT 1;

-- Update property
-- name: UpdateProperty :one
UPDATE properties 
SET title = $2, description = $3, property_type = $4, address = $5,
    city = $6, state = $7, latitude = $8, longitude = $9, bedrooms = $10,
    bathrooms = $11, rent_amount = $12, rent_period = $13, security_deposit = $14,
    agency_fee = $15, legal_fee = $16, amenities = $17, furnishing_status = $18,
    parking_spaces = $19, total_area = $20, updated_at = NOW()
WHERE id = $1 
RETURNING *;

-- Update property status
-- name: UpdatePropertyStatus :one
UPDATE properties 
SET status = $2, updated_at = NOW()
WHERE id = $1 
RETURNING *;

-- Update property availability
-- name: UpdatePropertyAvailability :one
UPDATE properties 
SET is_available = $2, last_confirmed_available = CASE WHEN $2 = true THEN NOW() ELSE last_confirmed_available END,
    updated_at = NOW()
WHERE id = $1 
RETURNING *;

-- Verify property
-- name: VerifyProperty :one
UPDATE properties 
SET is_verified = true, verification_badge = $2, verified_at = NOW(), 
    verified_by = $3, updated_at = NOW()
WHERE id = $1 
RETURNING *;

-- Increment property views
-- name: IncrementPropertyViews :exec
UPDATE properties 
SET views_count = views_count + 1
WHERE id = $1;

-- List properties by landlord
-- name: ListPropertiesByLandlord :many
SELECT * FROM properties 
WHERE landlord_id = $1
ORDER BY created_at DESC
LIMIT $2 OFFSET $3;

-- List all properties with basic filtering
-- name: ListProperties :many
SELECT * FROM properties 
WHERE status = 'active' AND is_available = true
ORDER BY created_at DESC
LIMIT $1 OFFSET $2;

-- Search properties with filters
-- name: SearchProperties :many
SELECT p.*, u.first_name, u.last_name
FROM properties p
JOIN users u ON p.landlord_id = u.id
WHERE p.status = 'active' AND p.is_available = true
  AND ($1::text IS NULL OR p.city ILIKE '%' || $1 || '%')
  AND ($2::text IS NULL OR p.state ILIKE '%' || $2 || '%')
  AND ($3::property_type_enum IS NULL OR p.property_type = $3)
  AND ($4::decimal IS NULL OR p.rent_amount >= $4)
  AND ($5::decimal IS NULL OR p.rent_amount <= $5)
  AND ($6::integer IS NULL OR p.bedrooms >= $6)
  AND ($7::integer IS NULL OR p.bathrooms >= $7)
  AND ($8::furnishing_status_enum IS NULL OR p.furnishing_status = $8)
ORDER BY p.created_at DESC
LIMIT $9 OFFSET $10;

-- List featured properties
-- name: ListFeaturedProperties :many
SELECT p.*, u.first_name, u.last_name
FROM properties p
JOIN users u ON p.landlord_id = u.id
WHERE p.status = 'active' AND p.is_available = true AND p.verification_badge = true
ORDER BY p.views_count DESC, p.created_at DESC
LIMIT $1 OFFSET $2;

-- List recent properties
-- name: ListRecentProperties :many
SELECT p.*, u.first_name, u.last_name
FROM properties p
JOIN users u ON p.landlord_id = u.id
WHERE p.status = 'active' AND p.is_available = true
ORDER BY p.created_at DESC
LIMIT $1 OFFSET $2;

-- List properties by location
-- name: ListPropertiesByLocation :many
SELECT * FROM properties 
WHERE city = $1 AND state = $2 AND status = 'active' AND is_available = true
ORDER BY rent_amount ASC
LIMIT $3 OFFSET $4;

-- Count properties by landlord
-- name: CountPropertiesByLandlord :one
SELECT COUNT(*) FROM properties 
WHERE landlord_id = $1;

-- Count available properties
-- name: CountAvailableProperties :one
SELECT COUNT(*) FROM properties 
WHERE status = 'active' AND is_available = true;

-- Delete property (soft delete)
-- name: DeleteProperty :exec
UPDATE properties 
SET status = 'inactive', updated_at = NOW()
WHERE id = $1;