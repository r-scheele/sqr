-- Create custom enum types first (this part is correct)
CREATE TYPE user_type_enum AS ENUM ('tenant', 'landlord', 'inspection_agent', 'admin');
CREATE TYPE verification_type_enum AS ENUM ('email', 'phone', 'nin', 'license', 'background_check');
CREATE TYPE verification_status_enum AS ENUM ('pending', 'verified', 'rejected');
CREATE TYPE property_type_enum AS ENUM ('apartment', 'house', 'studio', 'duplex', 'commercial');
CREATE TYPE rent_period_enum AS ENUM ('monthly', 'annually');
CREATE TYPE furnishing_status_enum AS ENUM ('furnished', 'semi_furnished', 'unfurnished');
CREATE TYPE media_type_enum AS ENUM ('image', 'video', 'virtual_tour');
CREATE TYPE property_status_enum AS ENUM ('draft', 'active', 'rented', 'inactive');
CREATE TYPE inquiry_type_enum AS ENUM ('general', 'viewing_request', 'application');
CREATE TYPE inquiry_status_enum AS ENUM ('sent', 'read', 'responded', 'closed');
CREATE TYPE inspection_type_enum AS ENUM ('self_inspection', 'agent_inspection');
CREATE TYPE inspection_status_enum AS ENUM ('pending', 'confirmed', 'agent_assigned', 'completed', 'cancelled', 'refunded');
CREATE TYPE payment_status_enum AS ENUM ('pending', 'paid', 'refunded');
CREATE TYPE overall_condition_enum AS ENUM ('excellent', 'good', 'fair', 'poor');
CREATE TYPE application_status_enum AS ENUM ('submitted', 'under_review', 'approved', 'rejected', 'withdrawn');
CREATE TYPE agreement_status_enum AS ENUM ('draft', 'pending_signatures', 'active', 'completed', 'terminated');
CREATE TYPE message_type_enum AS ENUM ('text', 'image', 'document', 'system');
CREATE TYPE payment_type_enum AS ENUM ('inspection_fee', 'application_fee', 'rent', 'deposit', 'refund');
CREATE TYPE related_entity_enum AS ENUM ('inspection_request', 'rental_application', 'rental_agreement');
CREATE TYPE payment_method_enum AS ENUM ('card', 'bank_transfer', 'wallet', 'ussd');
CREATE TYPE payment_status_full_enum AS ENUM ('pending', 'processing', 'completed', 'failed', 'refunded', 'cancelled');
CREATE TYPE rating_type_enum AS ENUM ('landlord_to_tenant', 'tenant_to_landlord', 'tenant_to_agent', 'agent_to_tenant');
CREATE TYPE notification_type_enum AS ENUM ('inspection_scheduled', 'application_status', 'payment_received', 'message_received', 'system_alert');
CREATE TYPE notification_entity_enum AS ENUM ('property', 'inspection_request', 'rental_application', 'message');
CREATE TYPE setting_type_enum AS ENUM ('string', 'number', 'boolean', 'json');
CREATE TYPE audit_action_enum AS ENUM ('create', 'update', 'delete', 'login', 'logout', 'payment', 'verification');
CREATE TYPE dispute_entity_enum AS ENUM ('property', 'inspection_request', 'rental_agreement');
CREATE TYPE dispute_type_enum AS ENUM ('payment', 'property_condition', 'service_quality', 'breach_of_agreement', 'fraud');
CREATE TYPE dispute_status_enum AS ENUM ('open', 'investigating', 'resolved', 'closed');

CREATE TABLE "users" (
  "id" bigserial PRIMARY KEY,
  "email" varchar UNIQUE NOT NULL,
  "phone" varchar UNIQUE NOT NULL,
  "password_hash" varchar NOT NULL,
  "first_name" varchar NOT NULL,
  "last_name" varchar NOT NULL,
  "user_type" user_type_enum NOT NULL,
  "nin" varchar,
  "is_verified" boolean DEFAULT false,
  "is_active" boolean DEFAULT true,
  "profile_picture_url" varchar,
  "created_at" timestamptz DEFAULT (now()),
  "updated_at" timestamptz DEFAULT (now()),
  "last_login" timestamptz
);

CREATE TABLE "user_verifications" (
  "id" bigserial PRIMARY KEY,
  "user_id" bigint NOT NULL,
  "verification_type" verification_type_enum NOT NULL,
  "verification_status" verification_status_enum DEFAULT 'pending',
  "verification_data" json,
  "verified_at" timestamptz,
  "verified_by" bigint,
  "created_at" timestamptz DEFAULT (now())
);

CREATE TABLE "tenant_profiles" (
  "id" bigserial PRIMARY KEY,
  "user_id" bigint NOT NULL,
  "preferred_locations" text,
  "budget_min" decimal(12,2),
  "budget_max" decimal(12,2),
  "bedrooms_min" integer,
  "bedrooms_max" integer,
  "preferred_amenities" text,
  "occupation" varchar,
  "employer" varchar,
  "monthly_income" decimal(12,2),
  "previous_address" text,
  "references" text,
  "pet_friendly" boolean DEFAULT false,
  "created_at" timestamptz DEFAULT (now()),
  "updated_at" timestamptz DEFAULT (now())
);

CREATE TABLE "landlord_profiles" (
  "id" bigserial PRIMARY KEY,
  "user_id" bigint NOT NULL,
  "business_name" varchar,
  "business_registration" varchar,
  "tax_id" varchar,
  "bank_name" varchar,
  "bank_account" varchar,
  "bank_account_name" varchar,
  "guarantor_name" varchar,
  "guarantor_phone" varchar,
  "guarantor_address" text,
  "total_properties" integer DEFAULT 0,
  "average_rating" decimal(3,2) DEFAULT 0,
  "created_at" timestamptz DEFAULT (now()),
  "updated_at" timestamptz DEFAULT (now())
);

CREATE TABLE "inspection_agent_profiles" (
  "id" bigserial PRIMARY KEY,
  "user_id" bigint NOT NULL,
  "license_number" varchar,
  "specializations" text,
  "service_areas" text,
  "hourly_rate" decimal(8,2),
  "availability_schedule" text,
  "total_inspections" integer DEFAULT 0,
  "average_rating" decimal(3,2) DEFAULT 0,
  "completion_rate" decimal(5,2) DEFAULT 0,
  "total_earnings" decimal(12,2) DEFAULT 0,
  "bank_name" varchar,
  "bank_account" varchar,
  "bank_account_name" varchar,
  "is_approved" boolean DEFAULT false,
  "approved_at" timestamp,
  "approved_by" bigint,
  "created_at" timestamptz DEFAULT (now()),
  "updated_at" timestamptz DEFAULT (now())
);

CREATE TABLE "properties" (
  "id" bigserial PRIMARY KEY,
  "landlord_id" bigint NOT NULL,
  "title" varchar(255) NOT NULL,
  "description" text,
  "property_type" property_type_enum NOT NULL,
  "address" text NOT NULL,
  "city" varchar(100) NOT NULL,
  "state" varchar(100) NOT NULL,
  "country" varchar(100) DEFAULT 'Nigeria',
  "latitude" decimal(10,8),
  "longitude" decimal(11,8),
  "bedrooms" integer NOT NULL,
  "bathrooms" integer NOT NULL,
  "rent_amount" decimal(12,2) NOT NULL,
  "rent_period" rent_period_enum DEFAULT 'annually',
  "security_deposit" decimal(12,2),
  "agency_fee" decimal(12,2),
  "legal_fee" decimal(12,2),
  "amenities" text,
  "furnishing_status" furnishing_status_enum,
  "parking_spaces" integer DEFAULT 0,
  "total_area" decimal(8,2),
  "is_verified" boolean DEFAULT false,
  "verification_badge" boolean DEFAULT false,
  "verified_at" timestamp,
  "verified_by" bigint,
  "is_available" boolean DEFAULT true,
  "last_confirmed_available" timestamp,
  "views_count" integer DEFAULT 0,
  "status" property_status_enum DEFAULT 'draft',
  "expires_at" timestamptz,
  "created_at" timestamptz DEFAULT (now()),
  "updated_at" timestamptz DEFAULT (now())
);

CREATE TABLE "property_media" (
  "id" bigserial PRIMARY KEY,
  "property_id" bigint NOT NULL,
  "media_type" media_type_enum NOT NULL,
  "media_url" varchar(500) NOT NULL,
  "thumbnail_url" varchar(500),
  "caption" varchar(255),
  "display_order" integer DEFAULT 0,
  "is_primary" boolean DEFAULT false,
  "created_at" timestamptz DEFAULT (now())
);

CREATE TABLE "property_community_reviews" (
  "id" bigserial PRIMARY KEY,
  "property_id" bigint NOT NULL,
  "user_id" bigint NOT NULL,
  "electricity_rating" integer,
  "water_rating" integer,
  "security_rating" integer,
  "noise_level" integer,
  "road_condition" integer,
  "flooding_risk" integer,
  "internet_connectivity" integer,
  "proximity_to_amenities" integer,
  "comment" text,
  "is_verified" boolean DEFAULT false,
  "helpful_votes" integer DEFAULT 0,
  "created_at" timestamptz DEFAULT (now()),
  "updated_at" timestamptz DEFAULT (now())
);

CREATE TABLE "saved_properties" (
  "id" bigserial PRIMARY KEY,
  "tenant_id" bigint NOT NULL,
  "property_id" bigint NOT NULL,
  "saved_at" timestamptz DEFAULT (now())
);

CREATE TABLE "property_inquiries" (
  "id" bigserial PRIMARY KEY,
  "property_id" bigint NOT NULL,
  "tenant_id" bigint NOT NULL,
  "landlord_id" bigint NOT NULL,
  "inquiry_type" inquiry_type_enum NOT NULL,
  "message" text,
  "status" inquiry_status_enum DEFAULT 'sent',
  "response" text,
  "responded_at" timestamptz,
  "created_at" timestamptz DEFAULT (now())
);

CREATE TABLE "inspection_requests" (
  "id" bigserial PRIMARY KEY,
  "property_id" bigint NOT NULL,
  "tenant_id" bigint NOT NULL,
  "landlord_id" bigint NOT NULL,
  "inspection_agent_id" bigint,
  "inspection_type" inspection_type_enum NOT NULL,
  "requested_date" date NOT NULL,
  "requested_time" time NOT NULL,
  "special_requirements" text,
  "inspection_fee" decimal(8,2) DEFAULT 0,
  "status" inspection_status_enum DEFAULT 'pending',
  "payment_status" payment_status_enum DEFAULT 'pending',
  "payment_reference" varchar(100),
  "confirmed_date" date,
  "confirmed_time" time,
  "completed_at" timestamptz,
  "cancellation_reason" text,
  "cancelled_at" timestamptz,
  "created_at" timestamptz DEFAULT (now()),
  "updated_at" timestamptz DEFAULT (now())
);

CREATE TABLE "inspection_reports" (
  "id" bigserial PRIMARY KEY,
  "inspection_request_id" bigint NOT NULL,
  "inspection_agent_id" bigint NOT NULL,
  "overall_condition" overall_condition_enum NOT NULL,
  "structural_condition" text,
  "electrical_condition" text,
  "plumbing_condition" text,
  "safety_assessment" text,
  "neighborhood_assessment" text,
  "special_findings" text,
  "recommendations" text,
  "photos" text,
  "videos" text,
  "checklist_data" text,
  "report_summary" text NOT NULL,
  "is_approved" boolean DEFAULT false,
  "approved_at" timestamptz,
  "created_at" timestamptz DEFAULT (now()),
  "updated_at" timestamptz DEFAULT (now())
);

CREATE TABLE "rental_applications" (
  "id" bigserial PRIMARY KEY,
  "property_id" bigint NOT NULL,
  "tenant_id" bigint NOT NULL,
  "landlord_id" bigint NOT NULL,
  "application_documents" text,
  "employment_details" text,
  "references" text,
  "preferred_move_in_date" date,
  "additional_notes" text,
  "status" application_status_enum DEFAULT 'submitted',
  "decision_reason" text,
  "decided_at" timestamptz,
  "decided_by" bigint,
  "created_at" timestamptz DEFAULT (now()),
  "updated_at" timestamptz DEFAULT (now())
);

CREATE TABLE "rental_agreements" (
  "id" bigserial PRIMARY KEY,
  "application_id" bigint NOT NULL,
  "property_id" bigint NOT NULL,
  "tenant_id" bigint NOT NULL,
  "landlord_id" bigint NOT NULL,
  "agreement_document_url" varchar(500),
  "lease_start_date" date NOT NULL,
  "lease_end_date" date NOT NULL,
  "monthly_rent" decimal(12,2) NOT NULL,
  "security_deposit" decimal(12,2),
  "total_upfront_payment" decimal(12,2),
  "payment_schedule" text,
  "terms_and_conditions" text,
  "status" agreement_status_enum DEFAULT 'draft',
  "tenant_signed_at" timestamptz,
  "landlord_signed_at" timestamptz,
  "created_at" timestamptz DEFAULT (now()),
  "updated_at" timestamptz DEFAULT (now())
);

CREATE TABLE "messages" (
  "id" bigserial PRIMARY KEY,
  "sender_id" bigint NOT NULL,
  "recipient_id" bigint NOT NULL,
  "property_id" bigint,
  "inspection_request_id" bigint,
  "application_id" bigint,
  "message_type" message_type_enum DEFAULT 'text',
  "content" text NOT NULL,
  "media_url" varchar(500),
  "is_read" boolean DEFAULT false,
  "read_at" timestamptz,
  "created_at" timestamptz DEFAULT (now())
);

CREATE TABLE "payments" (
  "id" bigserial PRIMARY KEY,
  "payer_id" bigint NOT NULL,
  "payee_id" bigint,
  "payment_type" payment_type_enum NOT NULL,
  "related_entity_type" related_entity_enum,
  "related_entity_id" bigint,
  "amount" decimal(12,2) NOT NULL,
  "currency" varchar(3) DEFAULT 'NGN',
  "payment_method" payment_method_enum NOT NULL,
  "payment_reference" varchar(100) UNIQUE NOT NULL,
  "gateway_reference" varchar(100),
  "status" payment_status_full_enum DEFAULT 'pending',
  "gateway_response" text,
  "processed_at" timestamptz,
  "refunded_at" timestamptz,
  "refund_reason" text,
  "created_at" timestamptz DEFAULT (now()),
  "updated_at" timestamptz DEFAULT (now())
);

CREATE TABLE "user_ratings" (
  "id" bigserial PRIMARY KEY,
  "rater_id" bigint NOT NULL,
  "rated_user_id" bigint NOT NULL,
  "rating_type" rating_type_enum,
  "related_entity_type" related_entity_enum,
  "related_entity_id" bigint,
  "rating" integer NOT NULL,
  "review_text" text,
  "response_text" text,
  "is_verified" boolean DEFAULT false,
  "created_at" timestamptz DEFAULT (now()),
  "updated_at" timestamptz DEFAULT (now())
);

CREATE TABLE "notifications" (
  "id" bigserial PRIMARY KEY,
  "user_id" bigint NOT NULL,
  "notification_type" notification_type_enum NOT NULL,
  "title" varchar(255) NOT NULL,
  "content" text NOT NULL,
  "related_entity_type" notification_entity_enum,
  "related_entity_id" bigint,
  "is_read" boolean DEFAULT false,
  "is_push_sent" boolean DEFAULT false,
  "is_email_sent" boolean DEFAULT false,
  "is_sms_sent" boolean DEFAULT false,
  "read_at" timestamptz,
  "created_at" timestamptz DEFAULT (now())
);

CREATE TABLE "user_sessions" (
  "id" bigserial PRIMARY KEY,
  "user_id" bigint NOT NULL,
  "session_token" varchar(255) UNIQUE NOT NULL,
  "device_info" text,
  "ip_address" varchar(45),
  "location_data" text,
  "expires_at" timestamptz NOT NULL,
  "is_active" boolean DEFAULT true,
  "created_at" timestamptz DEFAULT (now())
);

CREATE TABLE "system_settings" (
  "id" bigserial PRIMARY KEY,
  "setting_key" varchar(100) UNIQUE NOT NULL,
  "setting_value" text,
  "setting_type" setting_type_enum DEFAULT 'string',
  "description" text,
  "is_public" boolean DEFAULT false,
  "updated_by" bigint,
  "created_at" timestamptz DEFAULT (now()),
  "updated_at" timestamptz DEFAULT (now())
);

CREATE TABLE "audit_logs" (
  "id" bigserial PRIMARY KEY,
  "user_id" bigint,
  "action" audit_action_enum NOT NULL,
  "entity_type" varchar(50) NOT NULL,
  "entity_id" bigint,
  "old_values" text,
  "new_values" text,
  "ip_address" varchar(45),
  "user_agent" text,
  "created_at" timestamptz DEFAULT (now())
);

CREATE TABLE "dispute_cases" (
  "id" bigserial PRIMARY KEY,
  "complainant_id" bigint NOT NULL,
  "respondent_id" bigint NOT NULL,
  "related_entity_type" dispute_entity_enum,
  "related_entity_id" bigint,
  "dispute_type" dispute_type_enum NOT NULL,
  "description" text NOT NULL,
  "evidence_files" text,
  "status" dispute_status_enum DEFAULT 'open',
  "assigned_admin_id" bigint,
  "resolution_notes" text,
  "resolved_at" timestamptz,
  "created_at" timestamptz DEFAULT (now()),
  "updated_at" timestamptz DEFAULT (now())
);

CREATE TABLE "chatbot_conversations" (
  "id" bigserial PRIMARY KEY,
  "user_id" bigint NOT NULL,
  "session_id" varchar(100) NOT NULL,
  "message_text" text NOT NULL,
  "response_text" text NOT NULL,
  "intent" varchar(100),
  "entities" text,
  "confidence_score" decimal(3,2),
  "is_escalated" boolean DEFAULT false,
  "escalated_to" bigint,
  "created_at" timestamptz DEFAULT (now())
);

CREATE TABLE "property_search_cache" (
  "id" bigserial PRIMARY KEY,
  "search_hash" varchar(64) UNIQUE NOT NULL,
  "search_params" text,
  "property_ids" text,
  "result_count" integer NOT NULL,
  "expires_at" timestamptz NOT NULL,
  "created_at" timestamptz DEFAULT (now())
);



CREATE INDEX ON "users" ("user_type");

CREATE INDEX ON "users" ("is_active");

CREATE INDEX ON "users" ("is_verified");

CREATE INDEX ON "users" ("created_at");

CREATE INDEX ON "users" ("last_login");

CREATE INDEX ON "users" ("user_type", "is_active");

CREATE INDEX ON "users" ("user_type", "is_verified");

CREATE INDEX ON "user_verifications" ("user_id");

CREATE INDEX ON "user_verifications" ("verification_type");

CREATE INDEX ON "user_verifications" ("verification_status");

CREATE INDEX ON "user_verifications" ("verified_by");

CREATE INDEX ON "user_verifications" ("created_at");

CREATE INDEX ON "user_verifications" ("verification_type", "verification_status");

CREATE INDEX ON "tenant_profiles" ("user_id");

CREATE INDEX ON "tenant_profiles" ("budget_min", "budget_max");

CREATE INDEX ON "tenant_profiles" ("bedrooms_min", "bedrooms_max");

CREATE INDEX ON "tenant_profiles" ("pet_friendly");

CREATE INDEX ON "landlord_profiles" ("user_id");

CREATE INDEX ON "landlord_profiles" ("average_rating");

CREATE INDEX ON "landlord_profiles" ("total_properties");

CREATE INDEX ON "inspection_agent_profiles" ("user_id");

CREATE INDEX ON "inspection_agent_profiles" ("is_approved");

CREATE INDEX ON "inspection_agent_profiles" ("average_rating");

CREATE INDEX ON "inspection_agent_profiles" ("approved_by");

CREATE INDEX ON "properties" ("landlord_id");

CREATE INDEX ON "properties" ("status");

CREATE INDEX ON "properties" ("is_available");

CREATE INDEX ON "properties" ("is_verified");

CREATE INDEX ON "properties" ("property_type");

CREATE INDEX ON "properties" ("city", "state");

CREATE INDEX ON "properties" ("rent_amount");

CREATE INDEX ON "properties" ("bedrooms");

CREATE INDEX ON "properties" ("created_at");

CREATE INDEX ON "properties" ("views_count");

CREATE INDEX ON "properties" ("expires_at");

CREATE INDEX ON "properties" ("status", "is_available", "property_type");

CREATE INDEX ON "properties" ("city", "state", "status", "is_available");

CREATE INDEX ON "properties" ("rent_amount", "bedrooms", "status", "is_available");

CREATE INDEX ON "properties" ("landlord_id", "status");

CREATE INDEX ON "property_media" ("property_id");

CREATE INDEX ON "property_media" ("is_primary");

CREATE INDEX ON "property_media" ("property_id", "display_order");

CREATE INDEX ON "property_community_reviews" ("property_id");

CREATE INDEX ON "property_community_reviews" ("user_id");

CREATE INDEX ON "property_community_reviews" ("is_verified");

CREATE INDEX ON "property_community_reviews" ("created_at");

CREATE INDEX ON "property_community_reviews" ("helpful_votes");

CREATE UNIQUE INDEX ON "saved_properties" ("tenant_id", "property_id");

CREATE INDEX ON "saved_properties" ("tenant_id");

CREATE INDEX ON "saved_properties" ("saved_at");

CREATE INDEX ON "property_inquiries" ("property_id");

CREATE INDEX ON "property_inquiries" ("tenant_id");

CREATE INDEX ON "property_inquiries" ("landlord_id");

CREATE INDEX ON "property_inquiries" ("status");

CREATE INDEX ON "property_inquiries" ("created_at");

CREATE INDEX ON "property_inquiries" ("landlord_id", "status");

CREATE INDEX ON "property_inquiries" ("tenant_id", "status");

CREATE INDEX ON "inspection_requests" ("property_id");

CREATE INDEX ON "inspection_requests" ("tenant_id");

CREATE INDEX ON "inspection_requests" ("landlord_id");

CREATE INDEX ON "inspection_requests" ("inspection_agent_id");

CREATE INDEX ON "inspection_requests" ("status");

CREATE INDEX ON "inspection_requests" ("payment_status");

CREATE INDEX ON "inspection_requests" ("requested_date");

CREATE INDEX ON "inspection_requests" ("created_at");

CREATE INDEX ON "inspection_requests" ("inspection_agent_id", "status");

CREATE INDEX ON "inspection_requests" ("requested_date", "status");

CREATE INDEX ON "inspection_reports" ("inspection_request_id");

CREATE INDEX ON "inspection_reports" ("inspection_agent_id");

CREATE INDEX ON "inspection_reports" ("is_approved");

CREATE INDEX ON "inspection_reports" ("created_at");

CREATE INDEX ON "rental_applications" ("property_id");

CREATE INDEX ON "rental_applications" ("tenant_id");

CREATE INDEX ON "rental_applications" ("landlord_id");

CREATE INDEX ON "rental_applications" ("status");

CREATE INDEX ON "rental_applications" ("decided_by");

CREATE INDEX ON "rental_applications" ("created_at");

CREATE INDEX ON "rental_applications" ("landlord_id", "status");

CREATE INDEX ON "rental_agreements" ("application_id");

CREATE INDEX ON "rental_agreements" ("property_id");

CREATE INDEX ON "rental_agreements" ("tenant_id");

CREATE INDEX ON "rental_agreements" ("landlord_id");

CREATE INDEX ON "rental_agreements" ("status");

CREATE INDEX ON "rental_agreements" ("lease_start_date", "lease_end_date");

CREATE INDEX ON "messages" ("sender_id");

CREATE INDEX ON "messages" ("recipient_id");

CREATE INDEX ON "messages" ("property_id");

CREATE INDEX ON "messages" ("inspection_request_id");

CREATE INDEX ON "messages" ("application_id");

CREATE INDEX ON "messages" ("is_read");

CREATE INDEX ON "messages" ("created_at");

CREATE INDEX ON "messages" ("sender_id", "recipient_id", "created_at");

CREATE INDEX ON "messages" ("recipient_id", "is_read", "created_at");

CREATE INDEX ON "payments" ("payer_id");

CREATE INDEX ON "payments" ("payee_id");

CREATE INDEX ON "payments" ("payment_type");

CREATE INDEX ON "payments" ("status");

CREATE INDEX ON "payments" ("gateway_reference");

CREATE INDEX ON "payments" ("related_entity_type", "related_entity_id");

CREATE INDEX ON "payments" ("created_at");

CREATE INDEX ON "payments" ("processed_at");

CREATE INDEX ON "payments" ("payer_id", "status", "created_at");

CREATE INDEX ON "payments" ("payee_id", "status", "created_at");

CREATE INDEX ON "payments" ("payer_id", "payee_id");

CREATE UNIQUE INDEX ON "user_ratings" ("rater_id", "rated_user_id", "related_entity_type", "related_entity_id");

CREATE INDEX ON "user_ratings" ("rater_id");

CREATE INDEX ON "user_ratings" ("rated_user_id");

CREATE INDEX ON "user_ratings" ("rating_type");

CREATE INDEX ON "user_ratings" ("is_verified");

CREATE INDEX ON "user_ratings" ("created_at");

CREATE INDEX ON "user_ratings" ("related_entity_type", "related_entity_id");

CREATE INDEX ON "notifications" ("user_id");

CREATE INDEX ON "notifications" ("notification_type");

CREATE INDEX ON "notifications" ("is_read");

CREATE INDEX ON "notifications" ("created_at");

CREATE INDEX ON "notifications" ("related_entity_type", "related_entity_id");

CREATE INDEX ON "notifications" ("user_id", "is_read", "created_at");

CREATE INDEX ON "user_sessions" ("user_id");

CREATE INDEX ON "user_sessions" ("expires_at");

CREATE INDEX ON "user_sessions" ("is_active");

CREATE INDEX ON "user_sessions" ("ip_address");

CREATE INDEX ON "system_settings" ("is_public");

CREATE INDEX ON "system_settings" ("updated_by");

CREATE INDEX ON "audit_logs" ("user_id");

CREATE INDEX ON "audit_logs" ("action");

CREATE INDEX ON "audit_logs" ("entity_type");

CREATE INDEX ON "audit_logs" ("entity_type", "entity_id");

CREATE INDEX ON "audit_logs" ("created_at");

CREATE INDEX ON "audit_logs" ("ip_address");

CREATE INDEX ON "audit_logs" ("user_id", "created_at");

CREATE INDEX ON "dispute_cases" ("complainant_id");

CREATE INDEX ON "dispute_cases" ("respondent_id");

CREATE INDEX ON "dispute_cases" ("status");

CREATE INDEX ON "dispute_cases" ("dispute_type");

CREATE INDEX ON "dispute_cases" ("assigned_admin_id");

CREATE INDEX ON "dispute_cases" ("created_at");

CREATE INDEX ON "dispute_cases" ("related_entity_type", "related_entity_id");

CREATE INDEX ON "chatbot_conversations" ("user_id");

CREATE INDEX ON "chatbot_conversations" ("session_id");

CREATE INDEX ON "chatbot_conversations" ("intent");

CREATE INDEX ON "chatbot_conversations" ("is_escalated");

CREATE INDEX ON "chatbot_conversations" ("escalated_to");

CREATE INDEX ON "chatbot_conversations" ("created_at");

CREATE INDEX ON "property_search_cache" ("expires_at");

CREATE INDEX ON "property_search_cache" ("created_at");

ALTER TABLE "user_verifications" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "user_verifications" ADD FOREIGN KEY ("verified_by") REFERENCES "users" ("id");

ALTER TABLE "tenant_profiles" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "landlord_profiles" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "inspection_agent_profiles" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "inspection_agent_profiles" ADD FOREIGN KEY ("approved_by") REFERENCES "users" ("id");

ALTER TABLE "properties" ADD FOREIGN KEY ("landlord_id") REFERENCES "users" ("id");

ALTER TABLE "properties" ADD FOREIGN KEY ("verified_by") REFERENCES "users" ("id");

ALTER TABLE "property_media" ADD FOREIGN KEY ("property_id") REFERENCES "properties" ("id");

ALTER TABLE "property_community_reviews" ADD FOREIGN KEY ("property_id") REFERENCES "properties" ("id");

ALTER TABLE "property_community_reviews" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "saved_properties" ADD FOREIGN KEY ("tenant_id") REFERENCES "users" ("id");

ALTER TABLE "saved_properties" ADD FOREIGN KEY ("property_id") REFERENCES "properties" ("id");

ALTER TABLE "property_inquiries" ADD FOREIGN KEY ("property_id") REFERENCES "properties" ("id");

ALTER TABLE "property_inquiries" ADD FOREIGN KEY ("tenant_id") REFERENCES "users" ("id");

ALTER TABLE "property_inquiries" ADD FOREIGN KEY ("landlord_id") REFERENCES "users" ("id");

ALTER TABLE "inspection_requests" ADD FOREIGN KEY ("property_id") REFERENCES "properties" ("id");

ALTER TABLE "inspection_requests" ADD FOREIGN KEY ("tenant_id") REFERENCES "users" ("id");

ALTER TABLE "inspection_requests" ADD FOREIGN KEY ("landlord_id") REFERENCES "users" ("id");

ALTER TABLE "inspection_requests" ADD FOREIGN KEY ("inspection_agent_id") REFERENCES "users" ("id");

ALTER TABLE "inspection_reports" ADD FOREIGN KEY ("inspection_request_id") REFERENCES "inspection_requests" ("id");

ALTER TABLE "inspection_reports" ADD FOREIGN KEY ("inspection_agent_id") REFERENCES "users" ("id");

ALTER TABLE "rental_applications" ADD FOREIGN KEY ("property_id") REFERENCES "properties" ("id");

ALTER TABLE "rental_applications" ADD FOREIGN KEY ("tenant_id") REFERENCES "users" ("id");

ALTER TABLE "rental_applications" ADD FOREIGN KEY ("landlord_id") REFERENCES "users" ("id");

ALTER TABLE "rental_applications" ADD FOREIGN KEY ("decided_by") REFERENCES "users" ("id");

ALTER TABLE "rental_agreements" ADD FOREIGN KEY ("application_id") REFERENCES "rental_applications" ("id");

ALTER TABLE "rental_agreements" ADD FOREIGN KEY ("property_id") REFERENCES "properties" ("id");

ALTER TABLE "rental_agreements" ADD FOREIGN KEY ("tenant_id") REFERENCES "users" ("id");

ALTER TABLE "rental_agreements" ADD FOREIGN KEY ("landlord_id") REFERENCES "users" ("id");

ALTER TABLE "messages" ADD FOREIGN KEY ("sender_id") REFERENCES "users" ("id");

ALTER TABLE "messages" ADD FOREIGN KEY ("recipient_id") REFERENCES "users" ("id");

ALTER TABLE "messages" ADD FOREIGN KEY ("property_id") REFERENCES "properties" ("id");

ALTER TABLE "messages" ADD FOREIGN KEY ("inspection_request_id") REFERENCES "inspection_requests" ("id");

ALTER TABLE "messages" ADD FOREIGN KEY ("application_id") REFERENCES "rental_applications" ("id");

ALTER TABLE "payments" ADD FOREIGN KEY ("payer_id") REFERENCES "users" ("id");

ALTER TABLE "payments" ADD FOREIGN KEY ("payee_id") REFERENCES "users" ("id");

ALTER TABLE "user_ratings" ADD FOREIGN KEY ("rater_id") REFERENCES "users" ("id");

ALTER TABLE "user_ratings" ADD FOREIGN KEY ("rated_user_id") REFERENCES "users" ("id");

ALTER TABLE "notifications" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "user_sessions" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "system_settings" ADD FOREIGN KEY ("updated_by") REFERENCES "users" ("id");

ALTER TABLE "audit_logs" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "dispute_cases" ADD FOREIGN KEY ("complainant_id") REFERENCES "users" ("id");

ALTER TABLE "dispute_cases" ADD FOREIGN KEY ("respondent_id") REFERENCES "users" ("id");

ALTER TABLE "dispute_cases" ADD FOREIGN KEY ("assigned_admin_id") REFERENCES "users" ("id");

ALTER TABLE "chatbot_conversations" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "chatbot_conversations" ADD FOREIGN KEY ("escalated_to") REFERENCES "users" ("id");


