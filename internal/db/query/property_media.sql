-- Create property media
-- name: CreatePropertyMedia :one
INSERT INTO property_media (
  property_id, media_type, media_url, thumbnail_url, caption, display_order, is_primary
) VALUES (
  $1, $2, $3, $4, $5, $6, $7
) RETURNING *;

-- Get property media by ID
-- name: GetPropertyMediaByID :one
SELECT * FROM property_media 
WHERE id = $1 LIMIT 1;

-- Get all media for property
-- name: GetPropertyMediaByPropertyID :many
SELECT * FROM property_media 
WHERE property_id = $1
ORDER BY display_order ASC, created_at ASC;

-- Get primary media for property
-- name: GetPrimaryPropertyMedia :one
SELECT * FROM property_media 
WHERE property_id = $1 AND is_primary = true
LIMIT 1;

-- Get media by type for property
-- name: GetPropertyMediaByType :many
SELECT * FROM property_media 
WHERE property_id = $1 AND media_type = $2
ORDER BY display_order ASC, created_at ASC;

-- Update property media
-- name: UpdatePropertyMedia :one
UPDATE property_media 
SET media_url = $2, thumbnail_url = $3, caption = $4, display_order = $5
WHERE id = $1 
RETURNING *;

-- Update media display order
-- name: UpdateMediaDisplayOrder :exec
UPDATE property_media 
SET display_order = $2
WHERE id = $1;

-- Set primary media
-- name: SetPrimaryMedia :exec
UPDATE property_media 
SET is_primary = CASE WHEN id = $2 THEN true ELSE false END
WHERE property_id = $1;

-- Update media caption
-- name: UpdateMediaCaption :exec
UPDATE property_media 
SET caption = $2
WHERE id = $1;

-- Count media for property
-- name: CountPropertyMedia :one
SELECT COUNT(*) FROM property_media 
WHERE property_id = $1;

-- Count media by type for property
-- name: CountPropertyMediaByType :one
SELECT COUNT(*) FROM property_media 
WHERE property_id = $1 AND media_type = $2;

-- Delete property media
-- name: DeletePropertyMedia :exec
DELETE FROM property_media 
WHERE id = $1;

-- Delete all media for property
-- name: DeleteAllPropertyMedia :exec
DELETE FROM property_media 
WHERE property_id = $1;
