package auth

import (
	"testing"
	"time"

	"github.com/golang/mock/gomock"
	db "github.com/r-scheele/sqr/internal/db/sqlc"
	"github.com/r-scheele/sqr/internal/token"
	"github.com/r-scheele/sqr/internal/util"
	mockwk "github.com/r-scheele/sqr/internal/worker/mock"
	"github.com/stretchr/testify/require"
)

func newTestServer(t *testing.T, store db.Store) *Server {
	config := util.Config{
		TokenSymmetricKey:    util.RandomString(32),
		AccessTokenDuration:  time.Minute,
		RefreshTokenDuration: time.Hour,
	}

	tokenMaker, err := token.NewPasetoMaker(config.TokenSymmetricKey)
	require.NoError(t, err)

	// Create mock task distributor for tests
	ctrl := gomock.NewController(t)
	taskDistributor := mockwk.NewMockTaskDistributor(ctrl)

	// Rate limiter is optional for tests (pass nil)
	server := NewServer(config, store, tokenMaker, taskDistributor, nil)

	return server
}

// For tests that need access to the task distributor
func newTestServerWithTaskDistributor(t *testing.T, store db.Store, taskDistributor *mockwk.MockTaskDistributor) *Server {
	config := util.Config{
		TokenSymmetricKey:    util.RandomString(32),
		AccessTokenDuration:  time.Minute,
		RefreshTokenDuration: time.Hour,
	}

	tokenMaker, err := token.NewPasetoMaker(config.TokenSymmetricKey)
	require.NoError(t, err)

	// Rate limiter is optional for tests (pass nil)
	server := NewServer(config, store, tokenMaker, taskDistributor, nil)

	return server
}
