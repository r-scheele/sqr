-- Create a new inspection agent profile
-- name: CreateInspectionAgentProfile :one
INSERT INTO inspection_agent_profiles (
  user_id, license_number, specializations, service_areas, hourly_rate,
  availability_schedule, bank_name, bank_account, bank_account_name
) VALUES (
  $1, $2, $3, $4, $5, $6, $7, $8, $9
) RETURNING *;

-- Get inspection agent profile by ID
-- name: GetInspectionAgentProfileByID :one
SELECT * FROM inspection_agent_profiles 
WHERE id = $1 LIMIT 1;

-- Get inspection agent profile by user ID
-- name: GetInspectionAgentProfileByUserID :one
SELECT * FROM inspection_agent_profiles 
WHERE user_id = $1 LIMIT 1;

-- Update inspection agent profile
-- name: UpdateInspectionAgentProfile :one
UPDATE inspection_agent_profiles 
SET license_number = $2, specializations = $3, service_areas = $4,
    hourly_rate = $5, availability_schedule = $6, bank_name = $7,
    bank_account = $8, bank_account_name = $9, updated_at = NOW()
WHERE user_id = $1 
RETURNING *;

-- Update agent banking details
-- name: UpdateAgentBankingDetails :one
UPDATE inspection_agent_profiles 
SET bank_name = $2, bank_account = $3, bank_account_name = $4, updated_at = NOW()
WHERE user_id = $1 
RETURNING *;

-- Update agent service details
-- name: UpdateAgentServiceDetails :one
UPDATE inspection_agent_profiles 
SET specializations = $2, service_areas = $3, hourly_rate = $4,
    availability_schedule = $5, updated_at = NOW()
WHERE user_id = $1 
RETURNING *;

-- Update agent stats
-- name: UpdateAgentStats :one
UPDATE inspection_agent_profiles 
SET total_inspections = $2, average_rating = $3, completion_rate = $4,
    total_earnings = $5, updated_at = NOW()
WHERE user_id = $1 
RETURNING *;

-- Increment agent inspection count
-- name: IncrementAgentInspectionCount :exec
UPDATE inspection_agent_profiles 
SET total_inspections = total_inspections + 1, updated_at = NOW()
WHERE user_id = $1;

-- Update agent earnings
-- name: UpdateAgentEarnings :exec
UPDATE inspection_agent_profiles 
SET total_earnings = total_earnings + $2, updated_at = NOW()
WHERE user_id = $1;

-- Approve inspection agent
-- name: ApproveInspectionAgent :one
UPDATE inspection_agent_profiles 
SET is_approved = true, approved_at = NOW(), approved_by = $2, updated_at = NOW()
WHERE user_id = $1 
RETURNING *;

-- Reject inspection agent
-- name: RejectInspectionAgent :exec
UPDATE inspection_agent_profiles 
SET is_approved = false, approved_at = NULL, approved_by = NULL, updated_at = NOW()
WHERE user_id = $1;

-- List approved agents by area
-- name: ListApprovedAgentsByArea :many
SELECT iap.*, u.first_name, u.last_name, u.email, u.phone 
FROM inspection_agent_profiles iap
JOIN users u ON iap.user_id = u.id
WHERE iap.is_approved = true 
  AND u.is_active = true
  AND ($1::text IS NULL OR iap.service_areas ILIKE '%' || $1 || '%')
ORDER BY iap.average_rating DESC, iap.completion_rate DESC
LIMIT $2 OFFSET $3;

-- List pending agent applications
-- name: ListPendingAgentApplications :many
SELECT iap.*, u.first_name, u.last_name, u.email, u.phone 
FROM inspection_agent_profiles iap
JOIN users u ON iap.user_id = u.id
WHERE iap.is_approved = false AND u.is_active = true
ORDER BY iap.created_at ASC
LIMIT $1 OFFSET $2;

-- List top agents by rating
-- name: ListTopAgentsByRating :many
SELECT iap.*, u.first_name, u.last_name, u.email 
FROM inspection_agent_profiles iap
JOIN users u ON iap.user_id = u.id
WHERE iap.is_approved = true AND u.is_active = true
ORDER BY iap.average_rating DESC, iap.total_inspections DESC
LIMIT $1 OFFSET $2;

-- Delete inspection agent profile
-- name: DeleteInspectionAgentProfile :exec
DELETE FROM inspection_agent_profiles 
WHERE user_id = $1;
