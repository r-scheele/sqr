-- Migration Down Script
-- This script undoes all changes made by the up migration

-- Drop tables in reverse order of dependencies to avoid foreign key constraint errors

-- Drop tables with no dependencies first
DROP TABLE IF EXISTS "property_search_cache";
DROP TABLE IF EXISTS "chatbot_conversations";
DROP TABLE IF EXISTS "dispute_cases";
DROP TABLE IF EXISTS "audit_logs";
DROP TABLE IF EXISTS "system_settings";
DROP TABLE IF EXISTS "user_sessions";
DROP TABLE IF EXISTS "notifications";
DROP TABLE IF EXISTS "user_ratings";
DROP TABLE IF EXISTS "payments";

-- Drop tables that depend on the above
DROP TABLE IF EXISTS "messages";
DROP TABLE IF EXISTS "rental_agreements";
DROP TABLE IF EXISTS "rental_applications";
DROP TABLE IF EXISTS "inspection_reports";
DROP TABLE IF EXISTS "inspection_requests";
DROP TABLE IF EXISTS "property_inquiries";
DROP TABLE IF EXISTS "saved_properties";
DROP TABLE IF EXISTS "property_community_reviews";
DROP TABLE IF EXISTS "property_media";

-- Drop properties table
DROP TABLE IF EXISTS "properties";

-- Drop profile tables
DROP TABLE IF EXISTS "inspection_agent_profiles";
DROP TABLE IF EXISTS "landlord_profiles";
DROP TABLE IF EXISTS "tenant_profiles";

-- Drop user verifications table
DROP TABLE IF EXISTS "user_verifications";

-- Drop users table last (as it's referenced by most other tables)
DROP TABLE IF EXISTS "users";
