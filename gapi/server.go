package gapi

import (
	"fmt"

	db "github.com/r-scheele/sqr/internal/db/sqlc"
	"github.com/r-scheele/sqr/internal/pb"
	"github.com/r-scheele/sqr/internal/ratelimit"
	"github.com/r-scheele/sqr/internal/token"
	"github.com/r-scheele/sqr/internal/util"
	"github.com/r-scheele/sqr/internal/worker"
)

// Server serves gRPC requests for our banking service.
type Server struct {
	pb.UnimplementedSqrServer
	config          util.Config
	store           db.Store
	tokenMaker      token.Maker
	taskDistributor worker.TaskDistributor
	rateLimiter     *ratelimit.GRPCRateLimiter
}

// NewServer creates a new gRPC server.
func NewServer(config util.Config, store db.Store, taskDistributor worker.TaskDistributor, rateLimiter *ratelimit.GRPCRateLimiter) (*Server, error) {
	tokenMaker, err := token.NewPasetoMaker(config.TokenSymmetricKey)
	if err != nil {
		return nil, fmt.Errorf("cannot create token maker: %w", err)
	}

	server := &Server{
		config:          config,
		store:           store,
		tokenMaker:      tokenMaker,
		taskDistributor: taskDistributor,
		rateLimiter:     rateLimiter,
	}

	return server, nil
}
