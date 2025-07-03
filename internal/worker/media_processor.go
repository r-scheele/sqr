package worker

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/hibiken/asynq"
	db "github.com/r-scheele/sqr/internal/db/sqlc"
	"github.com/r-scheele/sqr/internal/storage"
)

type MediaProcessor struct {
	store   db.Store
	storage storage.StorageProvider
}

const (
	TaskProcessImage      = "media:process_image"
	TaskGenerateThumbnail = "media:generate_thumbnail"
	TaskWatermarkImage    = "media:watermark_image"
	TaskCompressVideo     = "media:compress_video"
)

func (p *MediaProcessor) ProcessUploadedMedia(ctx context.Context, task *asynq.Task) error {
	var payload struct {
		MediaUUID string `json:"media_uuid"`
		JobType   string `json:"job_type"`
	}

	if err := json.Unmarshal(task.Payload(), &payload); err != nil {
		return fmt.Errorf("failed to unmarshal payload: %w", err)
	}

	// TODO: Implement media processing logic
	// This is a stub implementation to fix build issues
	return fmt.Errorf("media processing not yet implemented")
}
