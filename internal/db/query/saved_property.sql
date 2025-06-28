-- Save a property
-- name: SaveProperty :one
INSERT INTO saved_properties (
  tenant_id, property_id
) VALUES (
  $1, $2
) ON CONFLICT (tenant_id, property_id) DO NOTHING
RETURNING *;

-- Get saved property by ID
-- name: GetSavedPropertyByID :one
SELECT * FROM saved_properties 
WHERE id = $1 LIMIT 1;

-- Check if property is saved by user
-- name: IsPropertySavedByUser :one
SELECT EXISTS(
  SELECT 1 FROM saved_properties 
  WHERE tenant_id = $1 AND property_id = $2
);

-- Get user's saved properties
-- name: GetUserSavedProperties :many
SELECT sp.*, p.title, p.rent_amount, p.bedrooms, p.bathrooms, p.city, p.state,
       p.property_type, p.furnishing_status, p.is_available, p.status
FROM saved_properties sp
JOIN properties p ON sp.property_id = p.id
WHERE sp.tenant_id = $1
ORDER BY sp.saved_at DESC
LIMIT $2 OFFSET $3;

-- Get user's saved properties with landlord info
-- name: GetUserSavedPropertiesWithLandlord :many
SELECT sp.*, p.title, p.rent_amount, p.bedrooms, p.bathrooms, p.city, p.state,
       p.property_type, p.furnishing_status, p.is_available, p.status,
       u.first_name as landlord_first_name, u.last_name as landlord_last_name
FROM saved_properties sp
JOIN properties p ON sp.property_id = p.id
JOIN users u ON p.landlord_id = u.id
WHERE sp.tenant_id = $1 AND p.status = 'active'
ORDER BY sp.saved_at DESC
LIMIT $2 OFFSET $3;

-- Count user's saved properties
-- name: CountUserSavedProperties :one
SELECT COUNT(*) FROM saved_properties sp
JOIN properties p ON sp.property_id = p.id
WHERE sp.tenant_id = $1 AND p.status = 'active';

-- Count saves for property
-- name: CountPropertySaves :one
SELECT COUNT(*) FROM saved_properties 
WHERE property_id = $1;

-- Get most saved properties
-- name: GetMostSavedProperties :many
SELECT p.id, p.title, p.rent_amount, p.city, p.state, COUNT(sp.id) as save_count
FROM properties p
JOIN saved_properties sp ON p.id = sp.property_id
WHERE p.status = 'active' AND p.is_available = true
GROUP BY p.id, p.title, p.rent_amount, p.city, p.state
ORDER BY save_count DESC, p.created_at DESC
LIMIT $1 OFFSET $2;

-- Unsave a property
-- name: UnsaveProperty :exec
DELETE FROM saved_properties 
WHERE tenant_id = $1 AND property_id = $2;

-- Delete saved property by ID
-- name: DeleteSavedProperty :exec
DELETE FROM saved_properties 
WHERE id = $1;

-- Delete all saved properties for user
-- name: DeleteAllUserSavedProperties :exec
DELETE FROM saved_properties 
WHERE tenant_id = $1;
