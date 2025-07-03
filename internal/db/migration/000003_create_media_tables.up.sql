CREATE TYPE media_type_enum AS ENUM (
    'image',
    'video', 
    'document'
);

CREATE TYPE upload_status_enum AS ENUM (
    'pending',
    'processing', 
    'ready',
    'failed'
);

CREATE TYPE storage_tier_enum AS ENUM (
    'hot',
    'warm',
    'cold'
);

CREATE TABLE media_files (
    id BIGSERIAL PRIMARY KEY,
    uuid UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    filename VARCHAR(255) NOT NULL,
    original_filename VARCHAR(255) NOT NULL,
    file_type media_type_enum NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    file_size BIGINT NOT NULL,
    width INTEGER,
    height INTEGER,
    duration INTEGER,
    
    storage_tier storage_tier_enum NOT NULL DEFAULT 'hot',
    storage_path TEXT NOT NULL,
    cdn_url TEXT,
    
    alt_text TEXT,
    caption TEXT,
    tags TEXT[],
    
    upload_status upload_status_enum NOT NULL DEFAULT 'pending',
    upload_progress INTEGER DEFAULT 0,
    
    view_count BIGINT DEFAULT 0,
    last_accessed TIMESTAMPTZ,
    
    uploaded_by BIGINT NOT NULL REFERENCES users(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE property_media (
    id BIGSERIAL PRIMARY KEY,
    property_id BIGINT NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
    media_file_id BIGINT NOT NULL REFERENCES media_files(id) ON DELETE CASCADE,
    media_purpose VARCHAR(50) NOT NULL, -- 'cover', 'gallery', 'floor_plan', 'video_tour'
    display_order INTEGER NOT NULL DEFAULT 0,
    is_featured BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    UNIQUE(property_id, media_file_id)
);

CREATE TABLE inspection_media (
    id BIGSERIAL PRIMARY KEY,
    inspection_id BIGINT NOT NULL REFERENCES inspections(id) ON DELETE CASCADE,
    media_file_id BIGINT NOT NULL REFERENCES media_files(id) ON DELETE CASCADE,
    room_type VARCHAR(100),
    inspection_category VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE user_media (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    media_file_id BIGINT NOT NULL REFERENCES media_files(id) ON DELETE CASCADE,
    media_purpose VARCHAR(50) NOT NULL, -- 'profile_photo', 'verification_document', 'business_license'
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_media_files_type_status ON media_files(file_type, upload_status);
CREATE INDEX idx_media_files_uploaded_by ON media_files(uploaded_by);
CREATE INDEX idx_property_media_property ON property_media(property_id);
CREATE INDEX idx_inspection_media_inspection ON inspection_media(inspection_id);
CREATE INDEX idx_user_media_user ON user_media(user_id);