-- Create rental agreement
-- name: CreateRentalAgreement :one
INSERT INTO rental_agreements (
  application_id, property_id, tenant_id, landlord_id, lease_start_date,
  lease_end_date, monthly_rent, security_deposit, total_upfront_payment,
  payment_schedule, terms_and_conditions
) VALUES (
  $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11
) RETURNING *;

-- Get rental agreement by ID
-- name: GetRentalAgreementByID :one
SELECT * FROM rental_agreements 
WHERE id = $1 LIMIT 1;

-- Get rental agreement by application ID
-- name: GetRentalAgreementByApplicationID :one
SELECT * FROM rental_agreements 
WHERE application_id = $1 LIMIT 1;

-- Get rental agreement with details
-- name: GetRentalAgreementWithDetails :one
SELECT ra.*, p.title as property_title, p.address as property_address,
       t.first_name as tenant_first_name, t.last_name as tenant_last_name, t.email as tenant_email, t.phone as tenant_phone,
       l.first_name as landlord_first_name, l.last_name as landlord_last_name, l.email as landlord_email, l.phone as landlord_phone,
       app.preferred_move_in_date
FROM rental_agreements ra
JOIN properties p ON ra.property_id = p.id
JOIN users t ON ra.tenant_id = t.id
JOIN users l ON ra.landlord_id = l.id
JOIN rental_applications app ON ra.application_id = app.id
WHERE ra.id = $1 LIMIT 1;

-- Update rental agreement
-- name: UpdateRentalAgreement :one
UPDATE rental_agreements 
SET lease_start_date = $2, lease_end_date = $3, monthly_rent = $4,
    security_deposit = $5, total_upfront_payment = $6, payment_schedule = $7,
    terms_and_conditions = $8, updated_at = NOW()
WHERE id = $1 
RETURNING *;

-- Update agreement status
-- name: UpdateAgreementStatus :one
UPDATE rental_agreements 
SET status = $2, updated_at = NOW()
WHERE id = $1 
RETURNING *;

-- Update agreement document
-- name: UpdateAgreementDocument :one
UPDATE rental_agreements 
SET agreement_document_url = $2, updated_at = NOW()
WHERE id = $1 
RETURNING *;

-- Tenant sign agreement
-- name: TenantSignAgreement :one
UPDATE rental_agreements 
SET tenant_signed_at = NOW(), updated_at = NOW(),
    status = CASE WHEN landlord_signed_at IS NOT NULL THEN 'active' ELSE 'pending_signatures' END
WHERE id = $1 
RETURNING *;

-- Landlord sign agreement
-- name: LandlordSignAgreement :one
UPDATE rental_agreements 
SET landlord_signed_at = NOW(), updated_at = NOW(),
    status = CASE WHEN tenant_signed_at IS NOT NULL THEN 'active' ELSE 'pending_signatures' END
WHERE id = $1 
RETURNING *;

-- Activate agreement
-- name: ActivateAgreement :one
UPDATE rental_agreements 
SET status = 'active', updated_at = NOW()
WHERE id = $1 AND tenant_signed_at IS NOT NULL AND landlord_signed_at IS NOT NULL
RETURNING *;

-- Complete agreement
-- name: CompleteAgreement :one
UPDATE rental_agreements 
SET status = 'completed', updated_at = NOW()
WHERE id = $1 
RETURNING *;

-- Terminate agreement
-- name: TerminateAgreement :one
UPDATE rental_agreements 
SET status = 'terminated', updated_at = NOW()
WHERE id = $1 
RETURNING *;

-- Get tenant's rental agreements
-- name: GetTenantRentalAgreements :many
SELECT ra.*, p.title as property_title, p.address as property_address,
       l.first_name as landlord_first_name, l.last_name as landlord_last_name, l.email as landlord_email
FROM rental_agreements ra
JOIN properties p ON ra.property_id = p.id
JOIN users l ON ra.landlord_id = l.id
WHERE ra.tenant_id = $1
ORDER BY ra.created_at DESC
LIMIT $2 OFFSET $3;

-- Get landlord's rental agreements
-- name: GetLandlordRentalAgreements :many
SELECT ra.*, p.title as property_title,
       t.first_name as tenant_first_name, t.last_name as tenant_last_name, t.email as tenant_email
FROM rental_agreements ra
JOIN properties p ON ra.property_id = p.id
JOIN users t ON ra.tenant_id = t.id
WHERE ra.landlord_id = $1
ORDER BY ra.created_at DESC
LIMIT $2 OFFSET $3;

-- Get active agreements for tenant
-- name: GetActiveTenantAgreements :many
SELECT ra.*, p.title as property_title, p.address as property_address,
       l.first_name as landlord_first_name, l.last_name as landlord_last_name
FROM rental_agreements ra
JOIN properties p ON ra.property_id = p.id
JOIN users l ON ra.landlord_id = l.id
WHERE ra.tenant_id = $1 AND ra.status = 'active'
ORDER BY ra.lease_end_date ASC
LIMIT $2 OFFSET $3;

-- Get active agreements for landlord
-- name: GetActiveLandlordAgreements :many
SELECT ra.*, p.title as property_title,
       t.first_name as tenant_first_name, t.last_name as tenant_last_name
FROM rental_agreements ra
JOIN properties p ON ra.property_id = p.id
JOIN users t ON ra.tenant_id = t.id
WHERE ra.landlord_id = $1 AND ra.status = 'active'
ORDER BY ra.lease_end_date ASC
LIMIT $2 OFFSET $3;

-- Get expiring agreements
-- name: GetExpiringAgreements :many
SELECT ra.*, p.title as property_title,
       t.first_name as tenant_first_name, t.last_name as tenant_last_name, t.email as tenant_email,
       l.first_name as landlord_first_name, l.last_name as landlord_last_name, l.email as landlord_email
FROM rental_agreements ra
JOIN properties p ON ra.property_id = p.id
JOIN users t ON ra.tenant_id = t.id
JOIN users l ON ra.landlord_id = l.id
WHERE ra.status = 'active' AND ra.lease_end_date BETWEEN $1 AND $2
ORDER BY ra.lease_end_date ASC
LIMIT $3 OFFSET $4;

-- Get agreements pending signatures
-- name: GetAgreementsPendingSignatures :many
SELECT ra.*, p.title as property_title,
       t.first_name as tenant_first_name, t.last_name as tenant_last_name,
       l.first_name as landlord_first_name, l.last_name as landlord_last_name
FROM rental_agreements ra
JOIN properties p ON ra.property_id = p.id
JOIN users t ON ra.tenant_id = t.id
JOIN users l ON ra.landlord_id = l.id
WHERE ra.status = 'pending_signatures'
ORDER BY ra.created_at ASC
LIMIT $1 OFFSET $2;

-- Count rental agreements by status
-- name: CountRentalAgreementsByStatus :one
SELECT COUNT(*) FROM rental_agreements 
WHERE status = $1;

-- Count tenant's rental agreements
-- name: CountTenantRentalAgreements :one
SELECT COUNT(*) FROM rental_agreements 
WHERE tenant_id = $1;

-- Count landlord's rental agreements
-- name: CountLandlordRentalAgreements :one
SELECT COUNT(*) FROM rental_agreements 
WHERE landlord_id = $1;

-- Get agreement statistics
-- name: GetAgreementStatistics :one
SELECT 
  COUNT(*) as total_agreements,
  COUNT(CASE WHEN status = 'active' THEN 1 END) as active_agreements,
  COUNT(CASE WHEN status = 'completed' THEN 1 END) as completed_agreements,
  COUNT(CASE WHEN status = 'pending_signatures' THEN 1 END) as pending_signatures,
  AVG(monthly_rent) as average_rent
FROM rental_agreements;

-- Delete rental agreement
-- name: DeleteRentalAgreement :exec
DELETE FROM rental_agreements 
WHERE id = $1;
