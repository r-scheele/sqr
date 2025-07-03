-- name: CreateMediaFile :one
INSERT INTO media_files (
    filename, original_filename, file_type, mime_type, file_size,
    width, height, duration, storage_path, uploaded_by
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10
) RETURNING *;

-- name: GetMediaFileByUUID :one
SELECT * FROM media_files WHERE uuid = $1;

-- name: GetMediaFileByID :one
SELECT * FROM media_files WHERE id = $1;

-- name: UpdateMediaFileStatus :one
UPDATE media_files 
SET upload_status = $2, cdn_url = $3, upload_progress = $4, updated_at = NOW()
WHERE uuid = $1
RETURNING *;

-- name: DeleteMediaFile :exec
DELETE FROM media_files WHERE uuid = $1;

-- name: ListMediaFilesByUser :many
SELECT * FROM media_files 
WHERE uploaded_by = $1
ORDER BY created_at DESC
LIMIT $2 OFFSET $3;

-- name: UpdateMediaAccessStats :exec
UPDATE media_files 
SET view_count = view_count + 1, last_accessed = NOW()
WHERE uuid = $1;

-- name: AddPropertyMedia :one
INSERT INTO property_media (property_id, media_file_id, media_purpose, display_order, is_featured)
VALUES ($1, $2, $3, $4, $5)
RETURNING *;

-- name: GetPropertyMedia :many
SELECT mf.*, pm.media_purpose, pm.display_order, pm.is_featured
FROM media_files mf
JOIN property_media pm ON mf.id = pm.media_file_id
WHERE pm.property_id = $1
ORDER BY pm.is_featured DESC, pm.display_order ASC;

-- name: DeletePropertyMedia :exec
DELETE FROM property_media 
WHERE property_id = $1 AND media_file_id = $2;

-- name: AddInspectionMedia :one
INSERT INTO inspection_media (inspection_id, media_file_id, room_type, inspection_category, notes)
VALUES ($1, $2, $3, $4, $5)
RETURNING *;

-- name: GetInspectionMedia :many
SELECT mf.*, im.room_type, im.inspection_category, im.notes
FROM media_files mf
JOIN inspection_media im ON mf.id = im.media_file_id
WHERE im.inspection_id = $1
ORDER BY im.created_at ASC;

-- name: AddUserMedia :one
INSERT INTO user_media (user_id, media_file_id, media_purpose)
VALUES ($1, $2, $3)
RETURNING *;

-- name: GetUserMedia :many
SELECT mf.*, um.media_purpose
FROM media_files mf
JOIN user_media um ON mf.id = um.media_file_id
WHERE um.user_id = $1
ORDER BY um.created_at DESC;