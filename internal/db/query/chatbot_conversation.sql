-- Create chatbot conversation
-- name: CreateChatbotConversation :one
INSERT INTO chatbot_conversations (
  user_id, session_id, message_text, response_text, intent, entities, confidence_score
) VALUES (
  $1, $2, $3, $4, $5, $6, $7
) RETURNING *;

-- Get chatbot conversation by ID
-- name: GetChatbotConversationByID :one
SELECT * FROM chatbot_conversations 
WHERE id = $1 LIMIT 1;

-- Update conversation escalation
-- name: EscalateConversation :one
UPDATE chatbot_conversations 
SET is_escalated = true, escalated_to = $2
WHERE id = $1 
RETURNING *;

-- Get conversations by session
-- name: GetConversationsBySession :many
SELECT * FROM chatbot_conversations 
WHERE session_id = $1
ORDER BY created_at ASC
LIMIT $2 OFFSET $3;

-- Get conversations by user
-- name: GetConversationsByUser :many
SELECT * FROM chatbot_conversations 
WHERE user_id = $1
ORDER BY created_at DESC
LIMIT $2 OFFSET $3;

-- Get user sessions
-- name: GetUserChatbotSessions :many
SELECT DISTINCT session_id, MAX(created_at) as last_message_time, COUNT(*) as message_count
FROM chatbot_conversations 
WHERE user_id = $1
GROUP BY session_id
ORDER BY last_message_time DESC
LIMIT $2 OFFSET $3;

-- Get escalated conversations
-- name: GetEscalatedConversations :many
SELECT cc.*, u.first_name, u.last_name, u.email,
       escalated_user.first_name as escalated_to_first_name, escalated_user.last_name as escalated_to_last_name
FROM chatbot_conversations cc
JOIN users u ON cc.user_id = u.id
LEFT JOIN users escalated_user ON cc.escalated_to = escalated_user.id
WHERE cc.is_escalated = true
ORDER BY cc.created_at DESC
LIMIT $1 OFFSET $2;

-- Get conversations by intent
-- name: GetConversationsByIntent :many
SELECT cc.*, u.first_name, u.last_name, u.email
FROM chatbot_conversations cc
JOIN users u ON cc.user_id = u.id
WHERE cc.intent = $1
ORDER BY cc.created_at DESC
LIMIT $2 OFFSET $3;

-- Get low confidence conversations
-- name: GetLowConfidenceConversations :many
SELECT cc.*, u.first_name, u.last_name, u.email
FROM chatbot_conversations cc
JOIN users u ON cc.user_id = u.id
WHERE cc.confidence_score < $1
ORDER BY cc.confidence_score ASC, cc.created_at DESC
LIMIT $2 OFFSET $3;

-- Get conversations by agent
-- name: GetConversationsByAgent :many
SELECT cc.*, u.first_name, u.last_name, u.email
FROM chatbot_conversations cc
JOIN users u ON cc.user_id = u.id
WHERE cc.escalated_to = $1
ORDER BY cc.created_at DESC
LIMIT $2 OFFSET $3;

-- Get recent conversations
-- name: GetRecentChatbotConversations :many
SELECT cc.*, u.first_name, u.last_name, u.email
FROM chatbot_conversations cc
JOIN users u ON cc.user_id = u.id
ORDER BY cc.created_at DESC
LIMIT $1 OFFSET $2;

-- Search conversations
-- name: SearchChatbotConversations :many
SELECT cc.*, u.first_name, u.last_name, u.email
FROM chatbot_conversations cc
JOIN users u ON cc.user_id = u.id
WHERE cc.message_text ILIKE '%' || $1 || '%' OR cc.response_text ILIKE '%' || $1 || '%'
ORDER BY cc.created_at DESC
LIMIT $2 OFFSET $3;

-- Count conversations by user
-- name: CountConversationsByUser :one
SELECT COUNT(*) FROM chatbot_conversations 
WHERE user_id = $1;

-- Count conversations by session
-- name: CountConversationsBySession :one
SELECT COUNT(*) FROM chatbot_conversations 
WHERE session_id = $1;

-- Count escalated conversations
-- name: CountEscalatedConversations :one
SELECT COUNT(*) FROM chatbot_conversations 
WHERE is_escalated = true;

-- Count conversations by intent
-- name: CountConversationsByIntent :one
SELECT COUNT(*) FROM chatbot_conversations 
WHERE intent = $1;

-- Get chatbot statistics
-- name: GetChatbotStatistics :one
SELECT 
  COUNT(*) as total_conversations,
  COUNT(DISTINCT user_id) as unique_users,
  COUNT(DISTINCT session_id) as unique_sessions,
  COUNT(CASE WHEN is_escalated = true THEN 1 END) as escalated_count,
  AVG(confidence_score) as average_confidence,
  COUNT(CASE WHEN confidence_score < 0.5 THEN 1 END) as low_confidence_count
FROM chatbot_conversations 
WHERE created_at >= $1;

-- Get intent statistics
-- name: GetIntentStatistics :many
SELECT 
  intent,
  COUNT(*) as conversation_count,
  AVG(confidence_score) as average_confidence,
  COUNT(CASE WHEN is_escalated = true THEN 1 END) as escalated_count
FROM chatbot_conversations 
WHERE created_at >= $1 AND intent IS NOT NULL
GROUP BY intent
ORDER BY conversation_count DESC
LIMIT $2 OFFSET $3;

-- Get user conversation summary
-- name: GetUserConversationSummary :one
SELECT 
  COUNT(*) as total_conversations,
  COUNT(DISTINCT session_id) as total_sessions,
  COUNT(CASE WHEN is_escalated = true THEN 1 END) as escalated_count,
  MAX(created_at) as last_conversation_time,
  AVG(confidence_score) as average_confidence
FROM chatbot_conversations 
WHERE user_id = $1;

-- Get daily conversation counts
-- name: GetDailyConversationCounts :many
SELECT 
  DATE(created_at) as conversation_date,
  COUNT(*) as conversation_count,
  COUNT(DISTINCT user_id) as unique_users,
  COUNT(CASE WHEN is_escalated = true THEN 1 END) as escalated_count
FROM chatbot_conversations 
WHERE created_at >= $1
GROUP BY DATE(created_at)
ORDER BY conversation_date DESC
LIMIT $2 OFFSET $3;

-- Clean up old conversations
-- name: CleanupOldConversations :exec
DELETE FROM chatbot_conversations 
WHERE created_at < $1 AND is_escalated = false;

-- Delete conversations by session
-- name: DeleteConversationsBySession :exec
DELETE FROM chatbot_conversations 
WHERE session_id = $1;

-- Delete conversation
-- name: DeleteChatbotConversation :exec
DELETE FROM chatbot_conversations 
WHERE id = $1;
