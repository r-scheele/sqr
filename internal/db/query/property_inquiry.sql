-- Create property inquiry
-- name: CreatePropertyInquiry :one
INSERT INTO property_inquiries (
  property_id, tenant_id, landlord_id, inquiry_type, message
) VALUES (
  $1, $2, $3, $4, $5
) RETURNING *;

-- Get property inquiry by ID
-- name: GetPropertyInquiryByID :one
SELECT * FROM property_inquiries 
WHERE id = $1 LIMIT 1;

-- Get inquiry with details
-- name: GetPropertyInquiryWithDetails :one
SELECT pi.*, p.title as property_title, 
       t.first_name as tenant_first_name, t.last_name as tenant_last_name, t.email as tenant_email,
       l.first_name as landlord_first_name, l.last_name as landlord_last_name, l.email as landlord_email
FROM property_inquiries pi
JOIN properties p ON pi.property_id = p.id
JOIN users t ON pi.tenant_id = t.id
JOIN users l ON pi.landlord_id = l.id
WHERE pi.id = $1 LIMIT 1;

-- Update inquiry status
-- name: UpdateInquiryStatus :one
UPDATE property_inquiries 
SET status = $2, updated_at = NOW()
WHERE id = $1 
RETURNING *;

-- Respond to inquiry
-- name: RespondToInquiry :one
UPDATE property_inquiries 
SET response = $2, status = 'responded', responded_at = NOW()
WHERE id = $1 
RETURNING *;

-- Mark inquiry as read
-- name: MarkInquiryAsRead :exec
UPDATE property_inquiries 
SET status = 'read'
WHERE id = $1 AND status = 'sent';

-- Get inquiries for landlord
-- name: GetLandlordInquiries :many
SELECT pi.*, p.title as property_title,
       u.first_name as tenant_first_name, u.last_name as tenant_last_name, u.email as tenant_email
FROM property_inquiries pi
JOIN properties p ON pi.property_id = p.id
JOIN users u ON pi.tenant_id = u.id
WHERE pi.landlord_id = $1
ORDER BY pi.created_at DESC
LIMIT $2 OFFSET $3;

-- Get inquiries for tenant
-- name: GetTenantInquiries :many
SELECT pi.*, p.title as property_title,
       u.first_name as landlord_first_name, u.last_name as landlord_last_name, u.email as landlord_email
FROM property_inquiries pi
JOIN properties p ON pi.property_id = p.id
JOIN users u ON pi.landlord_id = u.id
WHERE pi.tenant_id = $1
ORDER BY pi.created_at DESC
LIMIT $2 OFFSET $3;

-- Get inquiries for property
-- name: GetPropertyInquiries :many
SELECT pi.*, u.first_name as tenant_first_name, u.last_name as tenant_last_name, u.email as tenant_email
FROM property_inquiries pi
JOIN users u ON pi.tenant_id = u.id
WHERE pi.property_id = $1
ORDER BY pi.created_at DESC
LIMIT $2 OFFSET $3;

-- Get unread inquiries for landlord
-- name: GetUnreadLandlordInquiries :many
SELECT pi.*, p.title as property_title,
       u.first_name as tenant_first_name, u.last_name as tenant_last_name
FROM property_inquiries pi
JOIN properties p ON pi.property_id = p.id
JOIN users u ON pi.tenant_id = u.id
WHERE pi.landlord_id = $1 AND pi.status = 'sent'
ORDER BY pi.created_at ASC
LIMIT $2 OFFSET $3;

-- Count inquiries for landlord
-- name: CountLandlordInquiries :one
SELECT COUNT(*) FROM property_inquiries 
WHERE landlord_id = $1;

-- Count unread inquiries for landlord
-- name: CountUnreadLandlordInquiries :one
SELECT COUNT(*) FROM property_inquiries 
WHERE landlord_id = $1 AND status = 'sent';

-- Count inquiries for property
-- name: CountPropertyInquiries :one
SELECT COUNT(*) FROM property_inquiries 
WHERE property_id = $1;

-- Count inquiries by type for property
-- name: CountPropertyInquiriesByType :one
SELECT COUNT(*) FROM property_inquiries 
WHERE property_id = $1 AND inquiry_type = $2;

-- Get inquiry statistics for landlord
-- name: GetLandlordInquiryStats :one
SELECT 
  COUNT(*) as total_inquiries,
  COUNT(CASE WHEN status = 'sent' THEN 1 END) as unread_count,
  COUNT(CASE WHEN status = 'responded' THEN 1 END) as responded_count,
  COUNT(CASE WHEN inquiry_type = 'viewing_request' THEN 1 END) as viewing_requests
FROM property_inquiries 
WHERE landlord_id = $1;

-- Delete property inquiry
-- name: DeletePropertyInquiry :exec
DELETE FROM property_inquiries 
WHERE id = $1;
