package gapi

import (
	"context"
	"fmt"
	"testing"
	"time"

	"github.com/golang/mock/gomock"
	db "github.com/r-scheele/sqr/internal/db/sqlc"
	"github.com/r-scheele/sqr/internal/token"
	"github.com/r-scheele/sqr/internal/util"
	mockwk "github.com/r-scheele/sqr/internal/worker/mock"
	"github.com/stretchr/testify/require"
	"google.golang.org/grpc/metadata"
)

const (
	authorizationHeader = "authorization"
	authorizationBearer = "bearer"
)

func newTestServer(t *testing.T, store db.Store) *Server {
	config := util.Config{
		TokenSymmetricKey:    util.RandomString(32),
		AccessTokenDuration:  time.Minute,
		RefreshTokenDuration: time.Hour, // Add missing refresh token duration
	}

	// Create mock task distributor for tests
	ctrl := gomock.NewController(t)
	taskDistributor := mockwk.NewMockTaskDistributor(ctrl)

	// Rate limiter is optional for tests (pass nil)
	server, err := NewServer(config, store, taskDistributor, nil)
	require.NoError(t, err)

	return server
}

// For tests that need access to the task distributor
func newTestServerWithTaskDistributor(t *testing.T, store db.Store, taskDistributor *mockwk.MockTaskDistributor) *Server {
	config := util.Config{
		TokenSymmetricKey:    util.RandomString(32),
		AccessTokenDuration:  time.Minute,
		RefreshTokenDuration: time.Hour, // Add missing refresh token duration
	}

	// Rate limiter is optional for tests (pass nil)
	server, err := NewServer(config, store, taskDistributor, nil)
	require.NoError(t, err)

	return server
}

func newContextWithBearerToken(t *testing.T, tokenMaker token.Maker, username string, role string, duration time.Duration, tokenType token.TokenType) context.Context {
	accessToken, _, err := tokenMaker.CreateToken(username, role, duration, tokenType)
	require.NoError(t, err)

	bearerToken := fmt.Sprintf("%s %s", authorizationBearer, accessToken)
	md := metadata.MD{
		authorizationHeader: []string{
			bearerToken,
		},
	}

	return metadata.NewIncomingContext(context.Background(), md)
}
