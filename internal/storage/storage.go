package storage

import (
	"context"
	"io"
	"time"
)

type StorageProvider interface {
	Upload(ctx context.Context, file io.Reader, path string, contentType string) (*UploadResult, error)
	Download(ctx context.Context, path string) (io.ReadCloser, error)
	Delete(ctx context.Context, path string) error
	GetURL(ctx context.Context, path string, expiry time.Duration) (string, error)
}

type UploadResult struct {
	Path     string
	URL      string
	Size     int64
	Checksum string
}

type Config struct {
	Provider   string // "s3", "local", "gcs"
	BucketName string
	Region     string
	CDNDomain  string
	LocalPath  string
}
