-- Create system setting
-- name: CreateSystemSetting :one
INSERT INTO system_settings (
  setting_key, setting_value, setting_type, description, is_public, updated_by
) VALUES (
  $1, $2, $3, $4, $5, $6
) RETURNING *;

-- Get system setting by ID
-- name: GetSystemSettingByID :one
SELECT * FROM system_settings 
WHERE id = $1 LIMIT 1;

-- Get system setting by key
-- name: GetSystemSettingByKey :one
SELECT * FROM system_settings 
WHERE setting_key = $1 LIMIT 1;

-- Update system setting
-- name: UpdateSystemSetting :one
UPDATE system_settings 
SET setting_value = $2, setting_type = $3, description = $4, 
    is_public = $5, updated_by = $6, updated_at = NOW()
WHERE setting_key = $1 
RETURNING *;

-- Update setting value
-- name: UpdateSettingValue :one
UPDATE system_settings 
SET setting_value = $2, updated_by = $3, updated_at = NOW()
WHERE setting_key = $1 
RETURNING *;

-- Update setting visibility
-- name: UpdateSettingVisibility :exec
UPDATE system_settings 
SET is_public = $2, updated_by = $3, updated_at = NOW()
WHERE setting_key = $1;

-- Get all system settings
-- name: GetAllSystemSettings :many
SELECT * FROM system_settings 
ORDER BY setting_key ASC
LIMIT $1 OFFSET $2;

-- Get public system settings
-- name: GetPublicSystemSettings :many
SELECT setting_key, setting_value, setting_type, description
FROM system_settings 
WHERE is_public = true
ORDER BY setting_key ASC;

-- Get settings by type
-- name: GetSettingsByType :many
SELECT * FROM system_settings 
WHERE setting_type = $1
ORDER BY setting_key ASC
LIMIT $2 OFFSET $3;

-- Search settings
-- name: SearchSettings :many
SELECT * FROM system_settings 
WHERE setting_key ILIKE '%' || $1 || '%' OR description ILIKE '%' || $1 || '%'
ORDER BY setting_key ASC
LIMIT $2 OFFSET $3;

-- Get settings with updater info
-- name: GetSettingsWithUpdaterInfo :many
SELECT ss.*, u.first_name as updated_by_first_name, u.last_name as updated_by_last_name
FROM system_settings ss
LEFT JOIN users u ON ss.updated_by = u.id
ORDER BY ss.updated_at DESC
LIMIT $1 OFFSET $2;

-- Get recently updated settings
-- name: GetRecentlyUpdatedSettings :many
SELECT ss.*, u.first_name as updated_by_first_name, u.last_name as updated_by_last_name
FROM system_settings ss
LEFT JOIN users u ON ss.updated_by = u.id
WHERE ss.updated_at >= $1
ORDER BY ss.updated_at DESC
LIMIT $2 OFFSET $3;

-- Count system settings
-- name: CountSystemSettings :one
SELECT COUNT(*) FROM system_settings;

-- Count public settings
-- name: CountPublicSettings :one
SELECT COUNT(*) FROM system_settings 
WHERE is_public = true;

-- Count settings by type
-- name: CountSettingsByType :one
SELECT COUNT(*) FROM system_settings 
WHERE setting_type = $1;

-- Check if setting exists
-- name: CheckSettingExists :one
SELECT EXISTS(
  SELECT 1 FROM system_settings 
  WHERE setting_key = $1
);

-- Get setting statistics
-- name: GetSettingStatistics :one
SELECT 
  COUNT(*) as total_settings,
  COUNT(CASE WHEN is_public = true THEN 1 END) as public_settings,
  COUNT(CASE WHEN setting_type = 'string' THEN 1 END) as string_settings,
  COUNT(CASE WHEN setting_type = 'number' THEN 1 END) as number_settings,
  COUNT(CASE WHEN setting_type = 'boolean' THEN 1 END) as boolean_settings,
  COUNT(CASE WHEN setting_type = 'json' THEN 1 END) as json_settings
FROM system_settings;

-- Delete system setting
-- name: DeleteSystemSetting :exec
DELETE FROM system_settings 
WHERE setting_key = $1;
