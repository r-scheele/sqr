-- Create inspection request
-- name: CreateInspectionRequest :one
INSERT INTO inspection_requests (
  property_id, tenant_id, landlord_id, inspection_type, requested_date,
  requested_time, special_requirements, inspection_fee
) VALUES (
  $1, $2, $3, $4, $5, $6, $7, $8
) RETURNING *;

-- Get inspection request by ID
-- name: GetInspectionRequestByID :one
SELECT * FROM inspection_requests 
WHERE id = $1 LIMIT 1;

-- Get inspection request with details
-- name: GetInspectionRequestWithDetails :one
SELECT ir.*, p.title as property_title, p.address as property_address,
       t.first_name as tenant_first_name, t.last_name as tenant_last_name, t.email as tenant_email, t.phone as tenant_phone,
       l.first_name as landlord_first_name, l.last_name as landlord_last_name, l.email as landlord_email,
       a.first_name as agent_first_name, a.last_name as agent_last_name, a.email as agent_email, a.phone as agent_phone
FROM inspection_requests ir
JOIN properties p ON ir.property_id = p.id
JOIN users t ON ir.tenant_id = t.id
JOIN users l ON ir.landlord_id = l.id
LEFT JOIN users a ON ir.inspection_agent_id = a.id
WHERE ir.id = $1 LIMIT 1;

-- Update inspection request status
-- name: UpdateInspectionRequestStatus :one
UPDATE inspection_requests 
SET status = $2, updated_at = NOW()
WHERE id = $1 
RETURNING *;

-- Assign inspection agent
-- name: AssignInspectionAgent :one
UPDATE inspection_requests 
SET inspection_agent_id = $2, status = 'agent_assigned', updated_at = NOW()
WHERE id = $1 
RETURNING *;

-- Confirm inspection
-- name: ConfirmInspection :one
UPDATE inspection_requests 
SET confirmed_date = $2, confirmed_time = $3, status = 'confirmed', updated_at = NOW()
WHERE id = $1 
RETURNING *;

-- Complete inspection
-- name: CompleteInspection :one
UPDATE inspection_requests 
SET completed_at = NOW(), status = 'completed', updated_at = NOW()
WHERE id = $1 
RETURNING *;

-- Cancel inspection
-- name: CancelInspection :one
UPDATE inspection_requests 
SET cancellation_reason = $2, cancelled_at = NOW(), status = 'cancelled', updated_at = NOW()
WHERE id = $1 
RETURNING *;

-- Update payment status
-- name: UpdateInspectionPaymentStatus :one
UPDATE inspection_requests 
SET payment_status = $2, payment_reference = $3, updated_at = NOW()
WHERE id = $1 
RETURNING *;

-- Get tenant's inspection requests
-- name: GetTenantInspectionRequests :many
SELECT ir.*, p.title as property_title, p.address as property_address,
       l.first_name as landlord_first_name, l.last_name as landlord_last_name
FROM inspection_requests ir
JOIN properties p ON ir.property_id = p.id
JOIN users l ON ir.landlord_id = l.id
WHERE ir.tenant_id = $1
ORDER BY ir.created_at DESC
LIMIT $2 OFFSET $3;

-- Get landlord's inspection requests
-- name: GetLandlordInspectionRequests :many
SELECT ir.*, p.title as property_title,
       t.first_name as tenant_first_name, t.last_name as tenant_last_name, t.email as tenant_email
FROM inspection_requests ir
JOIN properties p ON ir.property_id = p.id
JOIN users t ON ir.tenant_id = t.id
WHERE ir.landlord_id = $1
ORDER BY ir.created_at DESC
LIMIT $2 OFFSET $3;

-- Get agent's inspection requests
-- name: GetAgentInspectionRequests :many
SELECT ir.*, p.title as property_title, p.address as property_address,
       t.first_name as tenant_first_name, t.last_name as tenant_last_name, t.phone as tenant_phone,
       l.first_name as landlord_first_name, l.last_name as landlord_last_name
FROM inspection_requests ir
JOIN properties p ON ir.property_id = p.id
JOIN users t ON ir.tenant_id = t.id
JOIN users l ON ir.landlord_id = l.id
WHERE ir.inspection_agent_id = $1
ORDER BY ir.requested_date ASC, ir.requested_time ASC
LIMIT $2 OFFSET $3;

-- Get pending inspections for agents
-- name: GetPendingInspectionsForAgents :many
SELECT ir.*, p.title as property_title, p.address as property_address, p.city, p.state,
       t.first_name as tenant_first_name, t.last_name as tenant_last_name, t.phone as tenant_phone
FROM inspection_requests ir
JOIN properties p ON ir.property_id = p.id
JOIN users t ON ir.tenant_id = t.id
WHERE ir.inspection_type = 'agent_inspection' 
  AND ir.status = 'pending' 
  AND ir.payment_status = 'paid'
ORDER BY ir.requested_date ASC, ir.requested_time ASC
LIMIT $1 OFFSET $2;

-- Get inspections by date range
-- name: GetInspectionsByDateRange :many
SELECT ir.*, p.title as property_title,
       t.first_name as tenant_first_name, t.last_name as tenant_last_name,
       a.first_name as agent_first_name, a.last_name as agent_last_name
FROM inspection_requests ir
JOIN properties p ON ir.property_id = p.id
JOIN users t ON ir.tenant_id = t.id
LEFT JOIN users a ON ir.inspection_agent_id = a.id
WHERE ir.requested_date BETWEEN $1 AND $2
ORDER BY ir.requested_date ASC, ir.requested_time ASC
LIMIT $3 OFFSET $4;

-- Count inspection requests by status
-- name: CountInspectionRequestsByStatus :one
SELECT COUNT(*) FROM inspection_requests 
WHERE status = $1;

-- Count tenant's inspection requests
-- name: CountTenantInspectionRequests :one
SELECT COUNT(*) FROM inspection_requests 
WHERE tenant_id = $1;

-- Count agent's inspection requests
-- name: CountAgentInspectionRequests :one
SELECT COUNT(*) FROM inspection_requests 
WHERE inspection_agent_id = $1;

-- Get inspection statistics for agent
-- name: GetAgentInspectionStats :one
SELECT 
  COUNT(*) as total_inspections,
  COUNT(CASE WHEN status = 'completed' THEN 1 END) as completed_inspections,
  COUNT(CASE WHEN status = 'cancelled' THEN 1 END) as cancelled_inspections,
  SUM(CASE WHEN status = 'completed' THEN inspection_fee ELSE 0 END) as total_earnings
FROM inspection_requests 
WHERE inspection_agent_id = $1;

-- Delete inspection request
-- name: DeleteInspectionRequest :exec
DELETE FROM inspection_requests 
WHERE id = $1;