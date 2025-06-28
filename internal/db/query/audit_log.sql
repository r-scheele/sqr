-- Create audit log
-- name: CreateAuditLog :one
INSERT INTO audit_logs (
  user_id, action, entity_type, entity_id, old_values, new_values, ip_address, user_agent
) VALUES (
  $1, $2, $3, $4, $5, $6, $7, $8
) RETURNING *;

-- Get audit log by ID
-- name: GetAuditLogByID :one
SELECT * FROM audit_logs 
WHERE id = $1 LIMIT 1;

-- Get audit log with user details
-- name: GetAuditLogWithUserDetails :one
SELECT al.*, u.first_name, u.last_name, u.email, u.user_type
FROM audit_logs al
LEFT JOIN users u ON al.user_id = u.id
WHERE al.id = $1 LIMIT 1;

-- Get audit logs by user
-- name: GetAuditLogsByUser :many
SELECT * FROM audit_logs 
WHERE user_id = $1
ORDER BY created_at DESC
LIMIT $2 OFFSET $3;

-- Get audit logs by action
-- name: GetAuditLogsByAction :many
SELECT al.*, u.first_name, u.last_name, u.email
FROM audit_logs al
LEFT JOIN users u ON al.user_id = u.id
WHERE al.action = $1
ORDER BY al.created_at DESC
LIMIT $2 OFFSET $3;

-- Get audit logs by entity
-- name: GetAuditLogsByEntity :many
SELECT al.*, u.first_name, u.last_name, u.email
FROM audit_logs al
LEFT JOIN users u ON al.user_id = u.id
WHERE al.entity_type = $1 AND al.entity_id = $2
ORDER BY al.created_at DESC
LIMIT $3 OFFSET $4;

-- Get audit logs by entity type
-- name: GetAuditLogsByEntityType :many
SELECT al.*, u.first_name, u.last_name, u.email
FROM audit_logs al
LEFT JOIN users u ON al.user_id = u.id
WHERE al.entity_type = $1
ORDER BY al.created_at DESC
LIMIT $2 OFFSET $3;

-- Get audit logs by IP address
-- name: GetAuditLogsByIPAddress :many
SELECT al.*, u.first_name, u.last_name, u.email
FROM audit_logs al
LEFT JOIN users u ON al.user_id = u.id
WHERE al.ip_address = $1
ORDER BY al.created_at DESC
LIMIT $2 OFFSET $3;

-- Get audit logs by date range
-- name: GetAuditLogsByDateRange :many
SELECT al.*, u.first_name, u.last_name, u.email
FROM audit_logs al
LEFT JOIN users u ON al.user_id = u.id
WHERE al.created_at BETWEEN $1 AND $2
ORDER BY al.created_at DESC
LIMIT $3 OFFSET $4;

-- Get recent audit logs
-- name: GetRecentAuditLogs :many
SELECT al.*, u.first_name, u.last_name, u.email
FROM audit_logs al
LEFT JOIN users u ON al.user_id = u.id
ORDER BY al.created_at DESC
LIMIT $1 OFFSET $2;

-- Get user login logs
-- name: GetUserLoginLogs :many
SELECT al.*, u.first_name, u.last_name, u.email
FROM audit_logs al
JOIN users u ON al.user_id = u.id
WHERE al.action = 'login'
ORDER BY al.created_at DESC
LIMIT $1 OFFSET $2;

-- Get failed login attempts
-- name: GetFailedLoginAttempts :many
SELECT * FROM audit_logs 
WHERE action = 'login' AND entity_type = 'failed_login'
  AND ($1::varchar IS NULL OR ip_address = $1)
  AND created_at >= $2
ORDER BY created_at DESC
LIMIT $3 OFFSET $4;

-- Get payment audit logs
-- name: GetPaymentAuditLogs :many
SELECT al.*, u.first_name, u.last_name, u.email
FROM audit_logs al
LEFT JOIN users u ON al.user_id = u.id
WHERE al.action = 'payment'
ORDER BY al.created_at DESC
LIMIT $1 OFFSET $2;

-- Get verification audit logs
-- name: GetVerificationAuditLogs :many
SELECT al.*, u.first_name, u.last_name, u.email
FROM audit_logs al
LEFT JOIN users u ON al.user_id = u.id
WHERE al.action = 'verification'
ORDER BY al.created_at DESC
LIMIT $1 OFFSET $2;

-- Count audit logs by action
-- name: CountAuditLogsByAction :one
SELECT COUNT(*) FROM audit_logs 
WHERE action = $1;

-- Count audit logs by user
-- name: CountAuditLogsByUser :one
SELECT COUNT(*) FROM audit_logs 
WHERE user_id = $1;

-- Count audit logs by entity
-- name: CountAuditLogsByEntity :one
SELECT COUNT(*) FROM audit_logs 
WHERE entity_type = $1 AND entity_id = $2;

-- Count audit logs by date range
-- name: CountAuditLogsByDateRange :one
SELECT COUNT(*) FROM audit_logs 
WHERE created_at BETWEEN $1 AND $2;

-- Get audit statistics
-- name: GetAuditStatistics :one
SELECT 
  COUNT(*) as total_logs,
  COUNT(CASE WHEN action = 'create' THEN 1 END) as create_actions,
  COUNT(CASE WHEN action = 'update' THEN 1 END) as update_actions,
  COUNT(CASE WHEN action = 'delete' THEN 1 END) as delete_actions,
  COUNT(CASE WHEN action = 'login' THEN 1 END) as login_actions,
  COUNT(CASE WHEN action = 'payment' THEN 1 END) as payment_actions,
  COUNT(DISTINCT user_id) as unique_users,
  COUNT(DISTINCT ip_address) as unique_ips
FROM audit_logs 
WHERE created_at >= $1;

-- Get user activity summary
-- name: GetUserActivitySummary :one
SELECT 
  COUNT(*) as total_activities,
  COUNT(CASE WHEN action = 'login' THEN 1 END) as login_count,
  COUNT(CASE WHEN action = 'create' THEN 1 END) as create_count,
  COUNT(CASE WHEN action = 'update' THEN 1 END) as update_count,
  COUNT(CASE WHEN action = 'delete' THEN 1 END) as delete_count,
  MAX(created_at) as last_activity,
  COUNT(DISTINCT ip_address) as unique_ips
FROM audit_logs 
WHERE user_id = $1 AND created_at >= $2;

-- Clean up old audit logs
-- name: CleanupOldAuditLogs :exec
DELETE FROM audit_logs 
WHERE created_at < $1;

-- Delete audit logs by user
-- name: DeleteAuditLogsByUser :exec
DELETE FROM audit_logs 
WHERE user_id = $1;

-- Delete audit log
-- name: DeleteAuditLog :exec
DELETE FROM audit_logs 
WHERE id = $1;
