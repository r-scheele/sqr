package ratelimit

import (
	"context"
	"time"
)

type Limiter interface {
	Allow(ctx context.Context, key string) (*Result, error)
	Reset(ctx context.Context, key string) error
}

type Result struct {
	Allowed    bool
	Remaining  int64
	ResetTime  time.Time
	RetryAfter time.Duration
}

type RateLimitRule struct {
	Pattern string        // URL pattern or user type
	RPS     int           // Requests per second
	Burst   int           // Burst capacity
	Window  time.Duration // Time window
	Scope   string        // "ip", "user", "endpoint"
}
