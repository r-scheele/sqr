package ratelimit

import (
	"context"
	"fmt"
	"strings"
	"time"

	"github.com/r-scheele/sqr/internal/util"
	"github.com/rs/zerolog/log"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/peer"
	"google.golang.org/grpc/status"
)

type GRPCRateLimiter struct {
	limiter Limiter
	rules   map[string]RateLimitRule
	config  util.Config
}

func NewGRPCRateLimiter(limiter Limiter, config util.Config) *GRPCRateLimiter {
	g := &GRPCRateLimiter{
		limiter: limiter,
		config:  config,
	}
	g.rules = g.getDefaultRules()
	return g
}

func (g *GRPCRateLimiter) UnaryInterceptor() grpc.UnaryServerInterceptor {
	return func(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
		if !g.config.RateLimitEnabled {
			return handler(ctx, req)
		}

		// Get rate limit key
		key, _ := g.getRateLimitKey(ctx, info.FullMethod)

		// Check rate limit
		result, err := g.limiter.Allow(ctx, key)
		if err != nil {
			return nil, status.Errorf(codes.Internal, "rate limiter error: %v", err)
		}

		// Add rate limit headers
		if err := g.addRateLimitHeaders(ctx, result); err != nil {
			log.Error().Err(err).Msg("failed to add rate limit headers")
		}

		if !result.Allowed {
			return nil, status.Errorf(codes.ResourceExhausted,
				"rate limit exceeded, retry after %v", result.RetryAfter)
		}

		return handler(ctx, req)
	}
}

func (g *GRPCRateLimiter) getRateLimitKey(ctx context.Context, method string) (string, RateLimitRule) {
	// Check for specific method rules
	if rule, exists := g.rules[method]; exists {
		switch rule.Scope {
		case "user":
			if userID := getUserIDFromContext(ctx); userID != "" {
				return fmt.Sprintf("user:%s:%s", userID, method), rule
			}
		case "ip":
			if ip := getClientIPFromContext(ctx); ip != "" {
				return fmt.Sprintf("ip:%s:%s", ip, method), rule
			}
		case "endpoint":
			return fmt.Sprintf("endpoint:%s", method), rule
		}
	}

	// Default rule by IP
	if ip := getClientIPFromContext(ctx); ip != "" {
		return fmt.Sprintf("ip:%s", ip), g.getDefaultSingleRule()
	}

	return "default", g.getDefaultSingleRule()
}

func (g *GRPCRateLimiter) addRateLimitHeaders(ctx context.Context, result *Result) error {
	return grpc.SetHeader(ctx, metadata.Pairs(
		"X-RateLimit-Limit", fmt.Sprintf("%d", result.Remaining+1),
		"X-RateLimit-Remaining", fmt.Sprintf("%d", result.Remaining),
		"X-RateLimit-Reset", fmt.Sprintf("%d", result.ResetTime.Unix()),
	))
}

func (g *GRPCRateLimiter) getDefaultRules() map[string]RateLimitRule {
	return map[string]RateLimitRule{
		"/pb.Sqr/CreateUser": {
			Pattern: "/pb.Sqr/CreateUser",
			RPS:     2, // 2 registrations per minute per ip
			Window:  time.Minute,
			Scope:   "ip",
		},
		"/pb.Sqr/LoginUser": {
			Pattern: "/pb.Sqr/LoginUser",
			RPS:     10, // 10 login attempts per minute per ip
			Window:  time.Minute,
			Scope:   "ip",
		},
		"/pb.Sqr/VerifyEmail": {
			Pattern: "/pb.Sqr/VerifyEmail",
			RPS:     5, // 5 verification attempts per minute per ip
			Window:  time.Minute,
			Scope:   "ip",
		},
		"/pb.Sqr/RefreshToken": {
			Pattern: "/pb.Sqr/RefreshToken",
			RPS:     20, // 20 token refresh per minute per user
			Window:  time.Minute,
			Scope:   "user",
		},
		"/pb.Sqr/UpdateTenantProfile": {
			Pattern: "/pb.Sqr/UpdateTenantProfile",
			RPS:     30, // 30 updates per minute per user
			Window:  time.Minute,
			Scope:   "user",
		},
		"/pb.Sqr/GetTenantProfile": {
			Pattern: "/pb.Sqr/GetTenantProfile",
			RPS:     100, // 100 reads per minute per user per ip
			Window:  time.Minute,
			Scope:   "user",
		},
	}
}

func (g *GRPCRateLimiter) getDefaultSingleRule() RateLimitRule {
	return RateLimitRule{
		Pattern: "default",
		RPS:     50, // 50 requests per minute by default
		Window:  time.Minute,
		Scope:   "ip",
	}
}

func getUserIDFromContext(ctx context.Context) string {
	if md, ok := metadata.FromIncomingContext(ctx); ok {
		if userIDs := md.Get("user-id"); len(userIDs) > 0 {
			return userIDs[0]
		}
	}
	return ""
}

func getClientIPFromContext(ctx context.Context) string {
	if p, ok := peer.FromContext(ctx); ok {
		return strings.Split(p.Addr.String(), ":")[0]
	}
	return ""
}
