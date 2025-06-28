-- Create message
-- name: CreateMessage :one
INSERT INTO messages (
  sender_id, recipient_id, property_id, inspection_request_id, application_id,
  message_type, content, media_url
) VALUES (
  $1, $2, $3, $4, $5, $6, $7, $8
) RETURNING *;

-- Get message by ID
-- name: GetMessageByID :one
SELECT * FROM messages 
WHERE id = $1 LIMIT 1;

-- Get message with sender details
-- name: GetMessageWithSenderDetails :one
SELECT m.*, u.first_name as sender_first_name, u.last_name as sender_last_name, u.profile_picture_url
FROM messages m
JOIN users u ON m.sender_id = u.id
WHERE m.id = $1 LIMIT 1;

-- Mark message as read
-- name: MarkMessageAsRead :exec
UPDATE messages 
SET is_read = true, read_at = NOW()
WHERE id = $1;

-- Mark multiple messages as read
-- name: MarkMessagesAsRead :exec
UPDATE messages 
SET is_read = true, read_at = NOW()
WHERE id = ANY($1::bigint[]);

-- Get conversation between two users
-- name: GetConversationBetweenUsers :many
SELECT m.*, s.first_name as sender_first_name, s.last_name as sender_last_name, s.profile_picture_url
FROM messages m
JOIN users s ON m.sender_id = s.id
WHERE (m.sender_id = $1 AND m.recipient_id = $2) 
   OR (m.sender_id = $2 AND m.recipient_id = $1)
ORDER BY m.created_at DESC
LIMIT $3 OFFSET $4;

-- Get property conversation
-- name: GetPropertyConversation :many
SELECT m.*, s.first_name as sender_first_name, s.last_name as sender_last_name, s.profile_picture_url
FROM messages m
JOIN users s ON m.sender_id = s.id
WHERE m.property_id = $1 
  AND ((m.sender_id = $2 AND m.recipient_id = $3) OR (m.sender_id = $3 AND m.recipient_id = $2))
ORDER BY m.created_at DESC
LIMIT $4 OFFSET $5;

-- Get inspection conversation
-- name: GetInspectionConversation :many
SELECT m.*, s.first_name as sender_first_name, s.last_name as sender_last_name, s.profile_picture_url
FROM messages m
JOIN users s ON m.sender_id = s.id
WHERE m.inspection_request_id = $1
ORDER BY m.created_at DESC
LIMIT $2 OFFSET $3;

-- Get application conversation
-- name: GetApplicationConversation :many
SELECT m.*, s.first_name as sender_first_name, s.last_name as sender_last_name, s.profile_picture_url
FROM messages m
JOIN users s ON m.sender_id = s.id
WHERE m.application_id = $1
ORDER BY m.created_at DESC
LIMIT $2 OFFSET $3;

-- Get user's conversations (distinct recipients)
-- name: GetUserConversations :many
SELECT DISTINCT ON (
  CASE 
    WHEN m.sender_id = $1 THEN m.recipient_id 
    ELSE m.sender_id 
  END
) 
  CASE 
    WHEN m.sender_id = $1 THEN m.recipient_id 
    ELSE m.sender_id 
  END as other_user_id,
  u.first_name, u.last_name, u.profile_picture_url,
  m.content as last_message,
  m.created_at as last_message_time,
  m.is_read,
  COUNT(CASE WHEN m.recipient_id = $1 AND m.is_read = false THEN 1 END) OVER (
    PARTITION BY CASE WHEN m.sender_id = $1 THEN m.recipient_id ELSE m.sender_id END
  ) as unread_count
FROM messages m
JOIN users u ON u.id = CASE WHEN m.sender_id = $1 THEN m.recipient_id ELSE m.sender_id END
WHERE m.sender_id = $1 OR m.recipient_id = $1
ORDER BY 
  CASE 
    WHEN m.sender_id = $1 THEN m.recipient_id 
    ELSE m.sender_id 
  END,
  m.created_at DESC
LIMIT $2 OFFSET $3;

-- Get unread messages for user
-- name: GetUnreadMessages :many
SELECT m.*, s.first_name as sender_first_name, s.last_name as sender_last_name, s.profile_picture_url
FROM messages m
JOIN users s ON m.sender_id = s.id
WHERE m.recipient_id = $1 AND m.is_read = false
ORDER BY m.created_at DESC
LIMIT $2 OFFSET $3;

-- Count unread messages for user
-- name: CountUnreadMessages :one
SELECT COUNT(*) FROM messages 
WHERE recipient_id = $1 AND is_read = false;

-- Count unread messages from sender
-- name: CountUnreadMessagesFromSender :one
SELECT COUNT(*) FROM messages 
WHERE recipient_id = $1 AND sender_id = $2 AND is_read = false;

-- Get recent messages for user
-- name: GetRecentMessages :many
SELECT m.*, s.first_name as sender_first_name, s.last_name as sender_last_name,
       r.first_name as recipient_first_name, r.last_name as recipient_last_name
FROM messages m
JOIN users s ON m.sender_id = s.id
JOIN users r ON m.recipient_id = r.id
WHERE m.sender_id = $1 OR m.recipient_id = $1
ORDER BY m.created_at DESC
LIMIT $2 OFFSET $3;

-- Search messages
-- name: SearchMessages :many
SELECT m.*, s.first_name as sender_first_name, s.last_name as sender_last_name
FROM messages m
JOIN users s ON m.sender_id = s.id
WHERE (m.sender_id = $1 OR m.recipient_id = $1) 
  AND m.content ILIKE '%' || $2 || '%'
ORDER BY m.created_at DESC
LIMIT $3 OFFSET $4;

-- Get messages by property
-- name: GetMessagesByProperty :many
SELECT m.*, s.first_name as sender_first_name, s.last_name as sender_last_name,
       r.first_name as recipient_first_name, r.last_name as recipient_last_name
FROM messages m
JOIN users s ON m.sender_id = s.id
JOIN users r ON m.recipient_id = r.id
WHERE m.property_id = $1
ORDER BY m.created_at DESC
LIMIT $2 OFFSET $3;

-- Delete message
-- name: DeleteMessage :exec
DELETE FROM messages 
WHERE id = $1;

-- Delete conversation between users
-- name: DeleteConversation :exec
DELETE FROM messages 
WHERE (sender_id = $1 AND recipient_id = $2) 
   OR (sender_id = $2 AND recipient_id = $1);
