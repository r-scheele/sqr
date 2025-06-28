-- Create payment
-- name: CreatePayment :one
INSERT INTO payments (
  payer_id, payee_id, payment_type, related_entity_type, related_entity_id,
  amount, currency, payment_method, payment_reference, gateway_reference
) VALUES (
  $1, $2, $3, $4, $5, $6, $7, $8, $9, $10
) RETURNING *;

-- Get payment by ID
-- name: GetPaymentByID :one
SELECT * FROM payments 
WHERE id = $1 LIMIT 1;

-- Get payment by reference
-- name: GetPaymentByReference :one
SELECT * FROM payments 
WHERE payment_reference = $1 LIMIT 1;

-- Get payment by gateway reference
-- name: GetPaymentByGatewayReference :one
SELECT * FROM payments 
WHERE gateway_reference = $1 LIMIT 1;

-- Get payment with details
-- name: GetPaymentWithDetails :one
SELECT p.*, 
       payer.first_name as payer_first_name, payer.last_name as payer_last_name, payer.email as payer_email,
       payee.first_name as payee_first_name, payee.last_name as payee_last_name, payee.email as payee_email
FROM payments p
JOIN users payer ON p.payer_id = payer.id
LEFT JOIN users payee ON p.payee_id = payee.id
WHERE p.id = $1 LIMIT 1;

-- Update payment status
-- name: UpdatePaymentStatus :one
UPDATE payments 
SET status = $2, gateway_response = $3, processed_at = CASE WHEN $2 = 'completed' THEN NOW() ELSE processed_at END,
    updated_at = NOW()
WHERE id = $1 
RETURNING *;

-- Process payment
-- name: ProcessPayment :one
UPDATE payments 
SET status = 'completed', processed_at = NOW(), gateway_response = $2, updated_at = NOW()
WHERE id = $1 
RETURNING *;

-- Fail payment
-- name: FailPayment :one
UPDATE payments 
SET status = 'failed', gateway_response = $2, updated_at = NOW()
WHERE id = $1 
RETURNING *;

-- Refund payment
-- name: RefundPayment :one
UPDATE payments 
SET status = 'refunded', refunded_at = NOW(), refund_reason = $2, updated_at = NOW()
WHERE id = $1 
RETURNING *;

-- Cancel payment
-- name: CancelPayment :one
UPDATE payments 
SET status = 'cancelled', updated_at = NOW()
WHERE id = $1 
RETURNING *;

-- Get user payments (as payer)
-- name: GetUserPayments :many
SELECT p.*, payee.first_name as payee_first_name, payee.last_name as payee_last_name
FROM payments p
LEFT JOIN users payee ON p.payee_id = payee.id
WHERE p.payer_id = $1
ORDER BY p.created_at DESC
LIMIT $2 OFFSET $3;

-- Get user earnings (as payee)
-- name: GetUserEarnings :many
SELECT p.*, payer.first_name as payer_first_name, payer.last_name as payer_last_name
FROM payments p
JOIN users payer ON p.payer_id = payer.id
WHERE p.payee_id = $1
ORDER BY p.created_at DESC
LIMIT $2 OFFSET $3;

-- Get payments by type
-- name: GetPaymentsByType :many
SELECT p.*, 
       payer.first_name as payer_first_name, payer.last_name as payer_last_name,
       payee.first_name as payee_first_name, payee.last_name as payee_last_name
FROM payments p
JOIN users payer ON p.payer_id = payer.id
LEFT JOIN users payee ON p.payee_id = payee.id
WHERE p.payment_type = $1
ORDER BY p.created_at DESC
LIMIT $2 OFFSET $3;

-- Get payments by status
-- name: GetPaymentsByStatus :many
SELECT p.*, 
       payer.first_name as payer_first_name, payer.last_name as payer_last_name,
       payee.first_name as payee_first_name, payee.last_name as payee_last_name
FROM payments p
JOIN users payer ON p.payer_id = payer.id
LEFT JOIN users payee ON p.payee_id = payee.id
WHERE p.status = $1
ORDER BY p.created_at DESC
LIMIT $2 OFFSET $3;

-- Get payments by entity
-- name: GetPaymentsByEntity :many
SELECT p.*, 
       payer.first_name as payer_first_name, payer.last_name as payer_last_name,
       payee.first_name as payee_first_name, payee.last_name as payee_last_name
FROM payments p
JOIN users payer ON p.payer_id = payer.id
LEFT JOIN users payee ON p.payee_id = payee.id
WHERE p.related_entity_type = $1 AND p.related_entity_id = $2
ORDER BY p.created_at DESC
LIMIT $3 OFFSET $4;

-- Get pending payments
-- name: GetPendingPayments :many
SELECT p.*, 
       payer.first_name as payer_first_name, payer.last_name as payer_last_name, payer.email as payer_email
FROM payments p
JOIN users payer ON p.payer_id = payer.id
WHERE p.status = 'pending'
ORDER BY p.created_at ASC
LIMIT $1 OFFSET $2;

-- Get payments by date range
-- name: GetPaymentsByDateRange :many
SELECT p.*, 
       payer.first_name as payer_first_name, payer.last_name as payer_last_name,
       payee.first_name as payee_first_name, payee.last_name as payee_last_name
FROM payments p
JOIN users payer ON p.payer_id = payer.id
LEFT JOIN users payee ON p.payee_id = payee.id
WHERE p.created_at BETWEEN $1 AND $2
ORDER BY p.created_at DESC
LIMIT $3 OFFSET $4;

-- Count payments by status
-- name: CountPaymentsByStatus :one
SELECT COUNT(*) FROM payments 
WHERE status = $1;

-- Count user payments
-- name: CountUserPayments :one
SELECT COUNT(*) FROM payments 
WHERE payer_id = $1;

-- Count user earnings
-- name: CountUserEarnings :one
SELECT COUNT(*) FROM payments 
WHERE payee_id = $1 AND status = 'completed';

-- Get payment statistics
-- name: GetPaymentStatistics :one
SELECT 
  COUNT(*) as total_payments,
  COUNT(CASE WHEN status = 'completed' THEN 1 END) as completed_payments,
  COUNT(CASE WHEN status = 'pending' THEN 1 END) as pending_payments,
  COUNT(CASE WHEN status = 'failed' THEN 1 END) as failed_payments,
  SUM(CASE WHEN status = 'completed' THEN amount ELSE 0 END) as total_revenue,
  AVG(CASE WHEN status = 'completed' THEN amount ELSE NULL END) as average_payment
FROM payments;

-- Get user payment summary
-- name: GetUserPaymentSummary :one
SELECT 
  COUNT(*) as total_payments,
  SUM(CASE WHEN status = 'completed' THEN amount ELSE 0 END) as total_spent,
  COUNT(CASE WHEN status = 'completed' THEN 1 END) as successful_payments,
  COUNT(CASE WHEN status = 'failed' THEN 1 END) as failed_payments
FROM payments 
WHERE payer_id = $1;

-- Get user earning summary
-- name: GetUserEarningSummary :one
SELECT 
  COUNT(*) as total_earnings,
  SUM(CASE WHEN status = 'completed' THEN amount ELSE 0 END) as total_earned,
  COUNT(CASE WHEN status = 'completed' THEN 1 END) as successful_earnings,
  COUNT(CASE WHEN status = 'refunded' THEN 1 END) as refunded_payments
FROM payments 
WHERE payee_id = $1;

-- Delete payment
-- name: DeletePayment :exec
DELETE FROM payments 
WHERE id = $1;
