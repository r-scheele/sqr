package auth

import (
	db "github.com/r-scheele/sqr/internal/db/sqlc"
	"github.com/r-scheele/sqr/internal/pb"
	"github.com/r-scheele/sqr/internal/ratelimit"
	"github.com/r-scheele/sqr/internal/token"
	"github.com/r-scheele/sqr/internal/util"
	"github.com/r-scheele/sqr/internal/worker"
)

// Server implements the auth service
type Server struct {
	pb.UnimplementedAuthServiceServer
	config          util.Config
	store           db.Store
	tokenMaker      token.Maker
	taskDistributor worker.TaskDistributor
	rateLimiter     *ratelimit.GRPCRateLimiter
}

// NewServer creates a new auth service server
func NewServer(
	config util.Config,
	store db.Store,
	tokenMaker token.Maker,
	taskDistributor worker.TaskDistributor,
	rateLimiter *ratelimit.GRPCRateLimiter,
) *Server {
	return &Server{
		config:          config,
		store:           store,
		tokenMaker:      tokenMaker,
		taskDistributor: taskDistributor,
		rateLimiter:     rateLimiter,
	}
}

// Verify that Server implements the Service interface
var _ Service = (*Server)(nil)
