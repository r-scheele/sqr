package storage

import (
	"bytes"
	"context"
	"fmt"
	"image"
	"image/jpeg"
	"image/png"
	"io"
)

type ImageProcessor struct {
	watermarkPath string
}

func (p *ImageProcessor) ResizeImage(ctx context.Context, input io.Reader, width, height int, quality int) (io.Reader, error) {
	// Decode image
	img, format, err := image.Decode(input)
	if err != nil {
		return nil, fmt.Errorf("failed to decode image: %w", err)
	}

	// TODO: Implement actual image resizing
	// For now, just re-encode the original image
	var buf bytes.Buffer
	switch format {
	case "jpeg":
		err = jpeg.Encode(&buf, img, &jpeg.Options{Quality: quality})
	case "png":
		err = png.Encode(&buf, img)
	default:
		return nil, fmt.Errorf("unsupported format: %s", format)
	}

	if err != nil {
		return nil, fmt.Errorf("failed to encode resized image: %w", err)
	}

	return bytes.NewReader(buf.Bytes()), nil
}

func (p *ImageProcessor) GenerateThumbnail(ctx context.Context, input io.Reader, size int) (io.Reader, error) {
	return p.ResizeImage(ctx, input, size, size, 85) // 85% quality for thumbnails
}
