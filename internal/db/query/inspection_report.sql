-- Create inspection report
-- name: CreateInspectionReport :one
INSERT INTO inspection_reports (
  inspection_request_id, inspection_agent_id, overall_condition, structural_condition,
  electrical_condition, plumbing_condition, safety_assessment, neighborhood_assessment,
  special_findings, recommendations, photos, videos, checklist_data, report_summary
) VALUES (
  $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14
) RETURNING *;

-- Get inspection report by ID
-- name: GetInspectionReportByID :one
SELECT * FROM inspection_reports 
WHERE id = $1 LIMIT 1;

-- Get inspection report by request ID
-- name: GetInspectionReportByRequestID :one
SELECT * FROM inspection_reports 
WHERE inspection_request_id = $1 LIMIT 1;

-- Get inspection report with details
-- name: GetInspectionReportWithDetails :one
SELECT ir.*, rep.*, p.title as property_title, p.address as property_address,
       a.first_name as agent_first_name, a.last_name as agent_last_name, a.email as agent_email,
       t.first_name as tenant_first_name, t.last_name as tenant_last_name
FROM inspection_reports rep
JOIN inspection_requests ir ON rep.inspection_request_id = ir.id
JOIN properties p ON ir.property_id = p.id
JOIN users a ON rep.inspection_agent_id = a.id
JOIN users t ON ir.tenant_id = t.id
WHERE rep.id = $1 LIMIT 1;

-- Update inspection report
-- name: UpdateInspectionReport :one
UPDATE inspection_reports 
SET overall_condition = $2, structural_condition = $3, electrical_condition = $4,
    plumbing_condition = $5, safety_assessment = $6, neighborhood_assessment = $7,
    special_findings = $8, recommendations = $9, photos = $10, videos = $11,
    checklist_data = $12, report_summary = $13, updated_at = NOW()
WHERE id = $1 
RETURNING *;

-- Approve inspection report
-- name: ApproveInspectionReport :one
UPDATE inspection_reports 
SET is_approved = true, approved_at = NOW(), updated_at = NOW()
WHERE id = $1 
RETURNING *;

-- Reject inspection report
-- name: RejectInspectionReport :exec
UPDATE inspection_reports 
SET is_approved = false, approved_at = NULL, updated_at = NOW()
WHERE id = $1;

-- Update report media
-- name: UpdateReportMedia :one
UPDATE inspection_reports 
SET photos = $2, videos = $3, updated_at = NOW()
WHERE id = $1 
RETURNING *;

-- Update report summary
-- name: UpdateReportSummary :one
UPDATE inspection_reports 
SET report_summary = $2, updated_at = NOW()
WHERE id = $1 
RETURNING *;

-- Get reports by agent
-- name: GetReportsByAgent :many
SELECT rep.*, ir.requested_date, p.title as property_title, p.address as property_address
FROM inspection_reports rep
JOIN inspection_requests ir ON rep.inspection_request_id = ir.id
JOIN properties p ON ir.property_id = p.id
WHERE rep.inspection_agent_id = $1
ORDER BY rep.created_at DESC
LIMIT $2 OFFSET $3;

-- Get pending approval reports
-- name: GetPendingApprovalReports :many
SELECT rep.*, ir.requested_date, p.title as property_title,
       a.first_name as agent_first_name, a.last_name as agent_last_name
FROM inspection_reports rep
JOIN inspection_requests ir ON rep.inspection_request_id = ir.id
JOIN properties p ON ir.property_id = p.id
JOIN users a ON rep.inspection_agent_id = a.id
WHERE rep.is_approved = false
ORDER BY rep.created_at ASC
LIMIT $1 OFFSET $2;

-- Get approved reports by date range
-- name: GetApprovedReportsByDateRange :many
SELECT rep.*, ir.requested_date, p.title as property_title,
       a.first_name as agent_first_name, a.last_name as agent_last_name
FROM inspection_reports rep
JOIN inspection_requests ir ON rep.inspection_request_id = ir.id
JOIN properties p ON ir.property_id = p.id
JOIN users a ON rep.inspection_agent_id = a.id
WHERE rep.is_approved = true 
  AND rep.created_at BETWEEN $1 AND $2
ORDER BY rep.created_at DESC
LIMIT $3 OFFSET $4;

-- Count reports by agent
-- name: CountReportsByAgent :one
SELECT COUNT(*) FROM inspection_reports 
WHERE inspection_agent_id = $1;

-- Count approved reports by agent
-- name: CountApprovedReportsByAgent :one
SELECT COUNT(*) FROM inspection_reports 
WHERE inspection_agent_id = $1 AND is_approved = true;

-- Count pending approval reports
-- name: CountPendingApprovalReports :one
SELECT COUNT(*) FROM inspection_reports 
WHERE is_approved = false;

-- Get report statistics
-- name: GetReportStatistics :one
SELECT 
  COUNT(*) as total_reports,
  COUNT(CASE WHEN is_approved = true THEN 1 END) as approved_reports,
  COUNT(CASE WHEN overall_condition = 'excellent' THEN 1 END) as excellent_condition,
  COUNT(CASE WHEN overall_condition = 'good' THEN 1 END) as good_condition,
  COUNT(CASE WHEN overall_condition = 'fair' THEN 1 END) as fair_condition,
  COUNT(CASE WHEN overall_condition = 'poor' THEN 1 END) as poor_condition
FROM inspection_reports;

-- Delete inspection report
-- name: DeleteInspectionReport :exec
DELETE FROM inspection_reports 
WHERE id = $1;
