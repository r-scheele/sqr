-- Create notification
-- name: CreateNotification :one
INSERT INTO notifications (
  user_id, notification_type, title, content, related_entity_type, related_entity_id
) VALUES (
  $1, $2, $3, $4, $5, $6
) RETURNING *;

-- Get notification by ID
-- name: GetNotificationByID :one
SELECT * FROM notifications 
WHERE id = $1 LIMIT 1;

-- Update notification
-- name: UpdateNotification :one
UPDATE notifications 
SET title = $2, content = $3, updated_at = NOW()
WHERE id = $1 
RETURNING *;

-- Mark notification as read
-- name: MarkNotificationAsRead :exec
UPDATE notifications 
SET is_read = true, read_at = NOW()
WHERE id = $1;

-- Mark multiple notifications as read
-- name: MarkNotificationsAsRead :exec
UPDATE notifications 
SET is_read = true, read_at = NOW()
WHERE id = ANY($1::bigint[]);

-- Mark all user notifications as read
-- name: MarkAllUserNotificationsAsRead :exec
UPDATE notifications 
SET is_read = true, read_at = NOW()
WHERE user_id = $1 AND is_read = false;

-- Update push sent status
-- name: UpdateNotificationPushSent :exec
UPDATE notifications 
SET is_push_sent = true
WHERE id = $1;

-- Update email sent status
-- name: UpdateNotificationEmailSent :exec
UPDATE notifications 
SET is_email_sent = true
WHERE id = $1;

-- Update SMS sent status
-- name: UpdateNotificationSMSSent :exec
UPDATE notifications 
SET is_sms_sent = true
WHERE id = $1;

-- Get user notifications
-- name: GetUserNotifications :many
SELECT * FROM notifications 
WHERE user_id = $1
ORDER BY created_at DESC
LIMIT $2 OFFSET $3;

-- Get unread user notifications
-- name: GetUnreadUserNotifications :many
SELECT * FROM notifications 
WHERE user_id = $1 AND is_read = false
ORDER BY created_at DESC
LIMIT $2 OFFSET $3;

-- Get notifications by type for user
-- name: GetNotificationsByTypeForUser :many
SELECT * FROM notifications 
WHERE user_id = $1 AND notification_type = $2
ORDER BY created_at DESC
LIMIT $3 OFFSET $4;

-- Get notifications by entity
-- name: GetNotificationsByEntity :many
SELECT n.*, u.first_name, u.last_name, u.email
FROM notifications n
JOIN users u ON n.user_id = u.id
WHERE n.related_entity_type = $1 AND n.related_entity_id = $2
ORDER BY n.created_at DESC
LIMIT $3 OFFSET $4;

-- Get pending push notifications
-- name: GetPendingPushNotifications :many
SELECT * FROM notifications 
WHERE is_push_sent = false
ORDER BY created_at ASC
LIMIT $1 OFFSET $2;

-- Get pending email notifications
-- name: GetPendingEmailNotifications :many
SELECT n.*, u.email, u.first_name, u.last_name
FROM notifications n
JOIN users u ON n.user_id = u.id
WHERE n.is_email_sent = false
ORDER BY n.created_at ASC
LIMIT $1 OFFSET $2;

-- Get pending SMS notifications
-- name: GetPendingSMSNotifications :many
SELECT n.*, u.phone, u.first_name, u.last_name
FROM notifications n
JOIN users u ON n.user_id = u.id
WHERE n.is_sms_sent = false
ORDER BY n.created_at ASC
LIMIT $1 OFFSET $2;

-- Count unread notifications for user
-- name: CountUnreadNotifications :one
SELECT COUNT(*) FROM notifications 
WHERE user_id = $1 AND is_read = false;

-- Count notifications by type for user
-- name: CountNotificationsByType :one
SELECT COUNT(*) FROM notifications 
WHERE user_id = $1 AND notification_type = $2;

-- Count total notifications for user
-- name: CountUserNotifications :one
SELECT COUNT(*) FROM notifications 
WHERE user_id = $1;

-- Get notification statistics for user
-- name: GetUserNotificationStats :one
SELECT 
  COUNT(*) as total_notifications,
  COUNT(CASE WHEN is_read = false THEN 1 END) as unread_count,
  COUNT(CASE WHEN notification_type = 'inspection_scheduled' THEN 1 END) as inspection_notifications,
  COUNT(CASE WHEN notification_type = 'application_status' THEN 1 END) as application_notifications,
  COUNT(CASE WHEN notification_type = 'payment_received' THEN 1 END) as payment_notifications,
  COUNT(CASE WHEN notification_type = 'message_received' THEN 1 END) as message_notifications
FROM notifications 
WHERE user_id = $1;

-- Get recent notifications across platform
-- name: GetRecentNotifications :many
SELECT n.*, u.first_name, u.last_name, u.email
FROM notifications n
JOIN users u ON n.user_id = u.id
ORDER BY n.created_at DESC
LIMIT $1 OFFSET $2;

-- Get notifications by date range
-- name: GetNotificationsByDateRange :many
SELECT n.*, u.first_name, u.last_name, u.email
FROM notifications n
JOIN users u ON n.user_id = u.id
WHERE n.created_at BETWEEN $1 AND $2
ORDER BY n.created_at DESC
LIMIT $3 OFFSET $4;

-- Delete notification
-- name: DeleteNotification :exec
DELETE FROM notifications 
WHERE id = $1;

-- Delete old notifications
-- name: DeleteOldNotifications :exec
DELETE FROM notifications 
WHERE created_at < $1;

-- Delete all user notifications
-- name: DeleteAllUserNotifications :exec
DELETE FROM notifications 
WHERE user_id = $1;
