-- Create rental application
-- name: CreateRentalApplication :one
INSERT INTO rental_applications (
  property_id, tenant_id, landlord_id, application_documents, employment_details,
  "references", preferred_move_in_date, additional_notes
) VALUES (
  $1, $2, $3, $4, $5, $6, $7, $8
) RETURNING *;

-- Get rental application by ID
-- name: GetRentalApplicationByID :one
SELECT * FROM rental_applications 
WHERE id = $1 LIMIT 1;

-- Get rental application with details
-- name: GetRentalApplicationWithDetails :one
SELECT ra.*, p.title as property_title, p.rent_amount, p.address as property_address,
       t.first_name as tenant_first_name, t.last_name as tenant_last_name, t.email as tenant_email, t.phone as tenant_phone,
       l.first_name as landlord_first_name, l.last_name as landlord_last_name, l.email as landlord_email,
       tp.occupation, tp.employer, tp.monthly_income,
       decided_by_user.first_name as decided_by_first_name, decided_by_user.last_name as decided_by_last_name
FROM rental_applications ra
JOIN properties p ON ra.property_id = p.id
JOIN users t ON ra.tenant_id = t.id
JOIN users l ON ra.landlord_id = l.id
LEFT JOIN tenant_profiles tp ON t.id = tp.user_id
LEFT JOIN users decided_by_user ON ra.decided_by = decided_by_user.id
WHERE ra.id = $1 LIMIT 1;

-- Update rental application status
-- name: UpdateRentalApplicationStatus :one
UPDATE rental_applications 
SET status = $2, decision_reason = $3, decided_at = NOW(), decided_by = $4, updated_at = NOW()
WHERE id = $1 
RETURNING *;

-- Update application documents
-- name: UpdateApplicationDocuments :one
UPDATE rental_applications 
SET application_documents = $2, updated_at = NOW()
WHERE id = $1 
RETURNING *;

-- Update employment details
-- name: UpdateApplicationEmploymentDetails :one
UPDATE rental_applications 
SET employment_details = $2, updated_at = NOW()
WHERE id = $1 
RETURNING *;

-- Update application references
-- name: UpdateApplicationReferences :one
UPDATE rental_applications 
SET "references" = $2, updated_at = NOW()
WHERE id = $1 
RETURNING *;

-- Approve rental application
-- name: ApproveRentalApplication :one
UPDATE rental_applications 
SET status = 'approved', decided_at = NOW(), decided_by = $2, updated_at = NOW()
WHERE id = $1 
RETURNING *;

-- Reject rental application
-- name: RejectRentalApplication :one
UPDATE rental_applications 
SET status = 'rejected', decision_reason = $2, decided_at = NOW(), decided_by = $3, updated_at = NOW()
WHERE id = $1 
RETURNING *;

-- Withdraw rental application
-- name: WithdrawRentalApplication :one
UPDATE rental_applications 
SET status = 'withdrawn', updated_at = NOW()
WHERE id = $1 
RETURNING *;

-- Get tenant's rental applications
-- name: GetTenantRentalApplications :many
SELECT ra.*, p.title as property_title, p.rent_amount, p.address as property_address,
       l.first_name as landlord_first_name, l.last_name as landlord_last_name
FROM rental_applications ra
JOIN properties p ON ra.property_id = p.id
JOIN users l ON ra.landlord_id = l.id
WHERE ra.tenant_id = $1
ORDER BY ra.created_at DESC
LIMIT $2 OFFSET $3;

-- Get landlord's rental applications
-- name: GetLandlordRentalApplications :many
SELECT ra.*, p.title as property_title,
       t.first_name as tenant_first_name, t.last_name as tenant_last_name, t.email as tenant_email,
       tp.occupation, tp.monthly_income
FROM rental_applications ra
JOIN properties p ON ra.property_id = p.id
JOIN users t ON ra.tenant_id = t.id
LEFT JOIN tenant_profiles tp ON t.id = tp.user_id
WHERE ra.landlord_id = $1
ORDER BY ra.created_at DESC
LIMIT $2 OFFSET $3;

-- Get applications for property
-- name: GetPropertyRentalApplications :many
SELECT ra.*, t.first_name as tenant_first_name, t.last_name as tenant_last_name, t.email as tenant_email,
       tp.occupation, tp.employer, tp.monthly_income
FROM rental_applications ra
JOIN users t ON ra.tenant_id = t.id
LEFT JOIN tenant_profiles tp ON t.id = tp.user_id
WHERE ra.property_id = $1
ORDER BY ra.created_at DESC
LIMIT $2 OFFSET $3;

-- Get pending applications for landlord
-- name: GetPendingApplicationsForLandlord :many
SELECT ra.*, p.title as property_title,
       t.first_name as tenant_first_name, t.last_name as tenant_last_name, t.email as tenant_email,
       tp.occupation, tp.monthly_income
FROM rental_applications ra
JOIN properties p ON ra.property_id = p.id
JOIN users t ON ra.tenant_id = t.id
LEFT JOIN tenant_profiles tp ON t.id = tp.user_id
WHERE ra.landlord_id = $1 AND ra.status IN ('submitted', 'under_review')
ORDER BY ra.created_at ASC
LIMIT $2 OFFSET $3;

-- Count rental applications by status
-- name: CountRentalApplicationsByStatus :one
SELECT COUNT(*) FROM rental_applications 
WHERE status = $1;

-- Count tenant's rental applications
-- name: CountTenantRentalApplications :one
SELECT COUNT(*) FROM rental_applications 
WHERE tenant_id = $1;

-- Count landlord's rental applications
-- name: CountLandlordRentalApplications :one
SELECT COUNT(*) FROM rental_applications 
WHERE landlord_id = $1;

-- Count property rental applications
-- name: CountPropertyRentalApplications :one
SELECT COUNT(*) FROM rental_applications 
WHERE property_id = $1;

-- Get application statistics for landlord
-- name: GetLandlordApplicationStats :one
SELECT 
  COUNT(*) as total_applications,
  COUNT(CASE WHEN status = 'submitted' THEN 1 END) as pending_review,
  COUNT(CASE WHEN status = 'approved' THEN 1 END) as approved_count,
  COUNT(CASE WHEN status = 'rejected' THEN 1 END) as rejected_count
FROM rental_applications 
WHERE landlord_id = $1;

-- Check if tenant has application for property
-- name: CheckTenantApplicationForProperty :one
SELECT EXISTS(
  SELECT 1 FROM rental_applications 
  WHERE tenant_id = $1 AND property_id = $2 AND status NOT IN ('rejected', 'withdrawn')
);

-- Delete rental application
-- name: DeleteRentalApplication :exec
DELETE FROM rental_applications 
WHERE id = $1;