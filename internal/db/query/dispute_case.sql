-- Create dispute case
-- name: CreateDisputeCase :one
INSERT INTO dispute_cases (
  complainant_id, respondent_id, related_entity_type, related_entity_id,
  dispute_type, description, evidence_files
) VALUES (
  $1, $2, $3, $4, $5, $6, $7
) RETURNING *;

-- Get dispute case by ID
-- name: GetDisputeCaseByID :one
SELECT * FROM dispute_cases 
WHERE id = $1 LIMIT 1;

-- Get dispute case with details
-- name: GetDisputeCaseWithDetails :one
SELECT dc.*, 
       c.first_name as complainant_first_name, c.last_name as complainant_last_name, c.email as complainant_email,
       r.first_name as respondent_first_name, r.last_name as respondent_last_name, r.email as respondent_email,
       a.first_name as admin_first_name, a.last_name as admin_last_name, a.email as admin_email
FROM dispute_cases dc
JOIN users c ON dc.complainant_id = c.id
JOIN users r ON dc.respondent_id = r.id
LEFT JOIN users a ON dc.assigned_admin_id = a.id
WHERE dc.id = $1 LIMIT 1;

-- Update dispute case
-- name: UpdateDisputeCase :one
UPDATE dispute_cases 
SET description = $2, evidence_files = $3, updated_at = NOW()
WHERE id = $1 
RETURNING *;

-- Update dispute status
-- name: UpdateDisputeStatus :one
UPDATE dispute_cases 
SET status = $2, updated_at = NOW()
WHERE id = $1 
RETURNING *;

-- Assign admin to dispute
-- name: AssignAdminToDispute :one
UPDATE dispute_cases 
SET assigned_admin_id = $2, status = 'investigating', updated_at = NOW()
WHERE id = $1 
RETURNING *;

-- Resolve dispute
-- name: ResolveDispute :one
UPDATE dispute_cases 
SET status = 'resolved', resolution_notes = $2, resolved_at = NOW(), updated_at = NOW()
WHERE id = $1 
RETURNING *;

-- Close dispute
-- name: CloseDispute :one
UPDATE dispute_cases 
SET status = 'closed', resolution_notes = $2, resolved_at = NOW(), updated_at = NOW()
WHERE id = $1 
RETURNING *;

-- Add evidence to dispute
-- name: AddDisputeEvidence :one
UPDATE dispute_cases 
SET evidence_files = $2, updated_at = NOW()
WHERE id = $1 
RETURNING *;

-- Get disputes for complainant
-- name: GetDisputesForComplainant :many
SELECT dc.*, 
       r.first_name as respondent_first_name, r.last_name as respondent_last_name,
       a.first_name as admin_first_name, a.last_name as admin_last_name
FROM dispute_cases dc
JOIN users r ON dc.respondent_id = r.id
LEFT JOIN users a ON dc.assigned_admin_id = a.id
WHERE dc.complainant_id = $1
ORDER BY dc.created_at DESC
LIMIT $2 OFFSET $3;

-- Get disputes for respondent
-- name: GetDisputesForRespondent :many
SELECT dc.*, 
       c.first_name as complainant_first_name, c.last_name as complainant_last_name,
       a.first_name as admin_first_name, a.last_name as admin_last_name
FROM dispute_cases dc
JOIN users c ON dc.complainant_id = c.id
LEFT JOIN users a ON dc.assigned_admin_id = a.id
WHERE dc.respondent_id = $1
ORDER BY dc.created_at DESC
LIMIT $2 OFFSET $3;

-- Get disputes assigned to admin
-- name: GetDisputesAssignedToAdmin :many
SELECT dc.*, 
       c.first_name as complainant_first_name, c.last_name as complainant_last_name, c.email as complainant_email,
       r.first_name as respondent_first_name, r.last_name as respondent_last_name, r.email as respondent_email
FROM dispute_cases dc
JOIN users c ON dc.complainant_id = c.id
JOIN users r ON dc.respondent_id = r.id
WHERE dc.assigned_admin_id = $1
ORDER BY dc.created_at ASC
LIMIT $2 OFFSET $3;

-- Get disputes by status
-- name: GetDisputesByStatus :many
SELECT dc.*, 
       c.first_name as complainant_first_name, c.last_name as complainant_last_name,
       r.first_name as respondent_first_name, r.last_name as respondent_last_name,
       a.first_name as admin_first_name, a.last_name as admin_last_name
FROM dispute_cases dc
JOIN users c ON dc.complainant_id = c.id
JOIN users r ON dc.respondent_id = r.id
LEFT JOIN users a ON dc.assigned_admin_id = a.id
WHERE dc.status = $1
ORDER BY dc.created_at ASC
LIMIT $2 OFFSET $3;

-- Get disputes by type
-- name: GetDisputesByType :many
SELECT dc.*, 
       c.first_name as complainant_first_name, c.last_name as complainant_last_name,
       r.first_name as respondent_first_name, r.last_name as respondent_last_name
FROM dispute_cases dc
JOIN users c ON dc.complainant_id = c.id
JOIN users r ON dc.respondent_id = r.id
WHERE dc.dispute_type = $1
ORDER BY dc.created_at DESC
LIMIT $2 OFFSET $3;

-- Get disputes by entity
-- name: GetDisputesByEntity :many
SELECT dc.*, 
       c.first_name as complainant_first_name, c.last_name as complainant_last_name,
       r.first_name as respondent_first_name, r.last_name as respondent_last_name
FROM dispute_cases dc
JOIN users c ON dc.complainant_id = c.id
JOIN users r ON dc.respondent_id = r.id
WHERE dc.related_entity_type = $1 AND dc.related_entity_id = $2
ORDER BY dc.created_at DESC
LIMIT $3 OFFSET $4;

-- Get open disputes
-- name: GetOpenDisputes :many
SELECT dc.*, 
       c.first_name as complainant_first_name, c.last_name as complainant_last_name, c.email as complainant_email,
       r.first_name as respondent_first_name, r.last_name as respondent_last_name, r.email as respondent_email
FROM dispute_cases dc
JOIN users c ON dc.complainant_id = c.id
JOIN users r ON dc.respondent_id = r.id
WHERE dc.status = 'open'
ORDER BY dc.created_at ASC
LIMIT $1 OFFSET $2;

-- Get unassigned disputes
-- name: GetUnassignedDisputes :many
SELECT dc.*, 
       c.first_name as complainant_first_name, c.last_name as complainant_last_name, c.email as complainant_email,
       r.first_name as respondent_first_name, r.last_name as respondent_last_name, r.email as respondent_email
FROM dispute_cases dc
JOIN users c ON dc.complainant_id = c.id
JOIN users r ON dc.respondent_id = r.id
WHERE dc.assigned_admin_id IS NULL AND dc.status = 'open'
ORDER BY dc.created_at ASC
LIMIT $1 OFFSET $2;

-- Count disputes by status
-- name: CountDisputesByStatus :one
SELECT COUNT(*) FROM dispute_cases 
WHERE status = $1;

-- Count disputes for user (as complainant)
-- name: CountDisputesForComplainant :one
SELECT COUNT(*) FROM dispute_cases 
WHERE complainant_id = $1;

-- Count disputes for user (as respondent)
-- name: CountDisputesForRespondent :one
SELECT COUNT(*) FROM dispute_cases 
WHERE respondent_id = $1;

-- Count disputes assigned to admin
-- name: CountDisputesAssignedToAdmin :one
SELECT COUNT(*) FROM dispute_cases 
WHERE assigned_admin_id = $1;

-- Get dispute statistics
-- name: GetDisputeStatistics :one
SELECT 
  COUNT(*) as total_disputes,
  COUNT(CASE WHEN status = 'open' THEN 1 END) as open_disputes,
  COUNT(CASE WHEN status = 'investigating' THEN 1 END) as investigating_disputes,
  COUNT(CASE WHEN status = 'resolved' THEN 1 END) as resolved_disputes,
  COUNT(CASE WHEN status = 'closed' THEN 1 END) as closed_disputes,
  COUNT(CASE WHEN dispute_type = 'payment' THEN 1 END) as payment_disputes,
  COUNT(CASE WHEN dispute_type = 'property_condition' THEN 1 END) as property_disputes,
  AVG(EXTRACT(EPOCH FROM (resolved_at - created_at))/86400) as avg_resolution_days
FROM dispute_cases 
WHERE created_at >= $1;

-- Get admin dispute workload
-- name: GetAdminDisputeWorkload :one
SELECT 
  COUNT(*) as total_assigned,
  COUNT(CASE WHEN status = 'investigating' THEN 1 END) as active_cases,
  COUNT(CASE WHEN status = 'resolved' THEN 1 END) as resolved_cases,
  AVG(EXTRACT(EPOCH FROM (COALESCE(resolved_at, NOW()) - created_at))/86400) as avg_handling_days
FROM dispute_cases 
WHERE assigned_admin_id = $1;

-- Delete dispute case
-- name: DeleteDisputeCase :exec
DELETE FROM dispute_cases 
WHERE id = $1;
