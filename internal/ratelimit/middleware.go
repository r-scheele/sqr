package ratelimit

import (
	"fmt"
	"net/http"
	"strconv"
	"strings"
)

func (g *GRPCRateLimiter) HTTPMiddleware() func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			if !g.config.RateLimitEnabled {
				next.ServeHTTP(w, r)
				return
			}

			key := fmt.Sprintf("http:ip:%s:%s", getClientIP(r), r.URL.Path)

			result, err := g.limiter.Allow(r.Context(), key)
			if err != nil {
				http.Error(w, "Rate limiter error", http.StatusInternalServerError)
				return
			}

			// Set rate limit headers
			w.Header().Set("X-RateLimit-Limit", strconv.FormatInt(result.Remaining+1, 10))
			w.Header().Set("X-RateLimit-Remaining", strconv.FormatInt(result.Remaining, 10))
			w.Header().Set("X-RateLimit-Reset", strconv.FormatInt(result.ResetTime.Unix(), 10))

			if !result.Allowed {
				w.Header().Set("Retry-After", strconv.Itoa(int(result.RetryAfter.Seconds())))
				http.Error(w, "Rate limit exceeded", http.StatusTooManyRequests)
				return
			}

			next.ServeHTTP(w, r)
		})
	}
}

func getClientIP(r *http.Request) string {

	if xff := r.Header.Get("X-Forwarded-For"); xff != "" {
		return strings.Split(xff, ",")[0]
	}

	if xri := r.Header.Get("X-Real-IP"); xri != "" {
		return xri
	}

	return strings.Split(r.RemoteAddr, ":")[0]
}
