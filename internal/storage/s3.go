package storage

import (
	"context"
	"fmt"
	"io"
	"path/filepath"
	"strings"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/google/uuid"
)

type S3Storage struct {
	client     *s3.Client
	bucketName string
	region     string
	cdnDomain  string
}

func NewS3Storage(cfg *Config) (*S3Storage, error) {
	awsConfig, err := config.LoadDefaultConfig(context.TODO(),
		config.WithRegion(cfg.Region),
	)
	if err != nil {
		return nil, fmt.Errorf("failed to load AWS config: %w", err)
	}

	client := s3.NewFromConfig(awsConfig)

	return &S3Storage{
		client:     client,
		bucketName: cfg.BucketName,
		region:     cfg.Region,
		cdnDomain:  cfg.CDNDomain,
	}, nil
}

func (s *S3Storage) Upload(ctx context.Context, file io.Reader, path string, contentType string) (*UploadResult, error) {
	uniquePath := s.generateUniquePath(path)

	_, err := s.client.PutObject(ctx, &s3.PutObjectInput{
		Bucket:       aws.String(s.bucketName),
		Key:          aws.String(uniquePath),
		Body:         file,
		ContentType:  aws.String(contentType),
		CacheControl: aws.String("public, max-age=31536000"),
		Metadata: map[string]string{
			"uploaded-at": time.Now().UTC().Format(time.RFC3339),
			"platform":    "sqr-rental",
		},
	})

	if err != nil {
		return nil, fmt.Errorf("failed to upload to S3: %w", err)
	}

	return &UploadResult{
		Path: uniquePath,
		URL:  s.getCDNURL(uniquePath),
	}, nil
}

func (s *S3Storage) Download(ctx context.Context, path string) (io.ReadCloser, error) {
	result, err := s.client.GetObject(ctx, &s3.GetObjectInput{
		Bucket: aws.String(s.bucketName),
		Key:    aws.String(path),
	})
	if err != nil {
		return nil, fmt.Errorf("failed to download from S3: %w", err)
	}

	return result.Body, nil
}

func (s *S3Storage) Delete(ctx context.Context, path string) error {
	_, err := s.client.DeleteObject(ctx, &s3.DeleteObjectInput{
		Bucket: aws.String(s.bucketName),
		Key:    aws.String(path),
	})
	return err
}

func (s *S3Storage) GetURL(ctx context.Context, path string, expiry time.Duration) (string, error) {
	presignClient := s3.NewPresignClient(s.client)

	request, err := presignClient.PresignGetObject(ctx, &s3.GetObjectInput{
		Bucket: aws.String(s.bucketName),
		Key:    aws.String(path),
	}, func(opts *s3.PresignOptions) {
		opts.Expires = expiry
	})

	if err != nil {
		return "", fmt.Errorf("failed to generate presigned URL: %w", err)
	}

	return request.URL, nil
}

func (s *S3Storage) generateUniquePath(originalPath string) string {
	ext := filepath.Ext(originalPath)
	filename := strings.TrimSuffix(filepath.Base(originalPath), ext)
	timestamp := time.Now().Unix()
	uuid := uuid.New().String()[:8]

	return fmt.Sprintf("media/%d/%s-%s%s", timestamp, filename, uuid, ext)
}

func (s *S3Storage) getCDNURL(path string) string {
	if s.cdnDomain != "" {
		return fmt.Sprintf("https://%s/%s", s.cdnDomain, path)
	}
	return fmt.Sprintf("https://%s.s3.%s.amazonaws.com/%s", s.bucketName, s.region, path)
}
