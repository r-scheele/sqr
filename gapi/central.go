package gapi

import (
	"github.com/r-scheele/sqr/gapi/services/auth"
	userservice "github.com/r-scheele/sqr/gapi/services/user"
	db "github.com/r-scheele/sqr/internal/db/sqlc"
	"github.com/r-scheele/sqr/internal/ratelimit"
	"github.com/r-scheele/sqr/internal/token"
	"github.com/r-scheele/sqr/internal/util"
	"github.com/r-scheele/sqr/internal/worker"
)

// Server serves gRPC requests for our SQR service.
type Server struct {
	config          util.Config
	store           db.Store
	tokenMaker      token.Maker
	taskDistributor worker.TaskDistributor
	rateLimiter     *ratelimit.GRPCRateLimiter

	// Individual services
	authService *auth.Server
	userService *userservice.Server
}

// NewServer creates a new gRPC server.
func NewServer(
	config util.Config,
	store db.Store,
	taskDistributor worker.TaskDistributor,
	rateLimiter *ratelimit.GRPCRateLimiter,
) (*Server, error) {
	tokenMaker, err := token.NewPasetoMaker(config.TokenSymmetricKey)
	if err != nil {
		return nil, err
	}

	// Initialize individual services
	authService := auth.NewServer(config, store, tokenMaker, taskDistributor, rateLimiter)
	userService := userservice.NewServer(config, store, tokenMaker, taskDistributor, rateLimiter)

	server := &Server{
		config:          config,
		store:           store,
		tokenMaker:      tokenMaker,
		taskDistributor: taskDistributor,
		rateLimiter:     rateLimiter,
		authService:     authService,
		userService:     userService,
	}

	return server, nil
}

// AuthService returns the auth service instance
func (server *Server) AuthService() *auth.Server {
	return server.authService
}

// UserService returns the user service instance
func (server *Server) UserService() *userservice.Server {
	return server.userService
}
