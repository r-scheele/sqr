-- Create user session
-- name: CreateUserSession :one
INSERT INTO user_sessions (
  user_id, session_token, device_info, ip_address, location_data, expires_at
) VALUES (
  $1, $2, $3, $4, $5, $6
) RETURNING *;

-- Get user session by ID
-- name: GetUserSessionByID :one
SELECT * FROM user_sessions 
WHERE id = $1 LIMIT 1;

-- Get user session by token
-- name: GetUserSessionByToken :one
SELECT * FROM user_sessions 
WHERE session_token = $1 AND is_active = true AND expires_at > NOW()
LIMIT 1;

-- Get session with user details
-- name: GetSessionWithUserDetails :one
SELECT us.*, u.first_name, u.last_name, u.email, u.user_type
FROM user_sessions us
JOIN users u ON us.user_id = u.id
WHERE us.session_token = $1 AND us.is_active = true AND us.expires_at > NOW()
LIMIT 1;

-- Update session activity
-- name: UpdateSessionActivity :exec
UPDATE user_sessions 
SET expires_at = $2
WHERE session_token = $1 AND is_active = true;

-- Update session location
-- name: UpdateSessionLocation :exec
UPDATE user_sessions 
SET ip_address = $2, location_data = $3
WHERE session_token = $1;

-- Deactivate session
-- name: DeactivateSession :exec
UPDATE user_sessions 
SET is_active = false
WHERE session_token = $1;

-- Deactivate user sessions
-- name: DeactivateUserSessions :exec
UPDATE user_sessions 
SET is_active = false
WHERE user_id = $1 AND is_active = true;

-- Deactivate all user sessions except current
-- name: DeactivateOtherUserSessions :exec
UPDATE user_sessions 
SET is_active = false
WHERE user_id = $1 AND session_token != $2 AND is_active = true;

-- Get user active sessions
-- name: GetUserActiveSessions :many
SELECT * FROM user_sessions 
WHERE user_id = $1 AND is_active = true AND expires_at > NOW()
ORDER BY created_at DESC
LIMIT $2 OFFSET $3;

-- Get user sessions
-- name: GetUserSessions :many
SELECT * FROM user_sessions 
WHERE user_id = $1
ORDER BY created_at DESC
LIMIT $2 OFFSET $3;

-- Get sessions by IP address
-- name: GetSessionsByIPAddress :many
SELECT us.*, u.first_name, u.last_name, u.email
FROM user_sessions us
JOIN users u ON us.user_id = u.id
WHERE us.ip_address = $1
ORDER BY us.created_at DESC
LIMIT $2 OFFSET $3;

-- Get expired sessions
-- name: GetExpiredSessions :many
SELECT * FROM user_sessions 
WHERE expires_at <= NOW() AND is_active = true
ORDER BY expires_at ASC
LIMIT $1 OFFSET $2;

-- Count user active sessions
-- name: CountUserActiveSessions :one
SELECT COUNT(*) FROM user_sessions 
WHERE user_id = $1 AND is_active = true AND expires_at > NOW();

-- Count user total sessions
-- name: CountUserTotalSessions :one
SELECT COUNT(*) FROM user_sessions 
WHERE user_id = $1;

-- Get session statistics
-- name: GetSessionStatistics :one
SELECT 
  COUNT(*) as total_sessions,
  COUNT(CASE WHEN is_active = true AND expires_at > NOW() THEN 1 END) as active_sessions,
  COUNT(CASE WHEN expires_at <= NOW() THEN 1 END) as expired_sessions,
  COUNT(DISTINCT user_id) as unique_users,
  COUNT(DISTINCT ip_address) as unique_ips
FROM user_sessions;

-- Get user session summary
-- name: GetUserSessionSummary :one
SELECT 
  COUNT(*) as total_sessions,
  COUNT(CASE WHEN is_active = true AND expires_at > NOW() THEN 1 END) as active_sessions,
  MAX(created_at) as last_session_time,
  COUNT(DISTINCT ip_address) as unique_ips
FROM user_sessions 
WHERE user_id = $1;

-- Clean up expired sessions
-- name: CleanupExpiredSessions :exec
DELETE FROM user_sessions 
WHERE expires_at <= NOW() AND is_active = false;

-- Clean up old sessions
-- name: CleanupOldSessions :exec
DELETE FROM user_sessions 
WHERE created_at < $1;

-- Delete user session
-- name: DeleteUserSession :exec
DELETE FROM user_sessions 
WHERE id = $1;

-- Delete all user sessions
-- name: DeleteAllUserSessions :exec
DELETE FROM user_sessions 
WHERE user_id = $1;
