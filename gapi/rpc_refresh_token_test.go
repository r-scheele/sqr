package gapi

import (
	"context"
	"testing"
	"time"

	"github.com/golang/mock/gomock"
	"github.com/jackc/pgx/v5/pgtype"
	mockdb "github.com/r-scheele/sqr/internal/db/mock"
	db "github.com/r-scheele/sqr/internal/db/sqlc"
	"github.com/r-scheele/sqr/internal/pb"
	"github.com/r-scheele/sqr/internal/token"
	"github.com/r-scheele/sqr/internal/util"
	"github.com/stretchr/testify/require"
)

func TestRefreshTokenAPI(t *testing.T) {
	user, _ := randomUser(t, util.TenantRole)

	testCases := []struct {
		name          string
		setupToken    func(tokenMaker token.Maker) string
		buildStubs    func(store *mockdb.MockStore, token string)
		checkResponse func(t *testing.T, res *pb.RefreshTokenResponse, err error)
	}{
		{
			name: "OK",
			setupToken: func(tokenMaker token.Maker) string {
				username := user.FirstName + "_" + user.LastName
				refreshToken, _, err := tokenMaker.CreateToken(
					username,
					string(user.UserType),
					time.Hour,
					token.TokenTypeRefreshToken,
				)
				require.NoError(t, err)
				return refreshToken
			},
			buildStubs: func(store *mockdb.MockStore, refreshToken string) {
				session := db.UserSession{
					ID:           1,
					UserID:       user.ID,
					SessionToken: refreshToken,
					IsActive:     pgtype.Bool{Bool: true, Valid: true},
					ExpiresAt:    time.Now().Add(time.Hour),
				}

				store.EXPECT().
					GetUserSessionByToken(gomock.Any(), refreshToken).
					Times(1).
					Return(session, nil)

				store.EXPECT().
					GetUserByID(gomock.Any(), user.ID).
					Times(1).
					Return(user, nil)

				store.EXPECT().
					UpdateSessionActivity(gomock.Any(), gomock.Any()).
					Times(1).
					Return(nil)
			},
			checkResponse: func(t *testing.T, res *pb.RefreshTokenResponse, err error) {
				require.NoError(t, err)
				require.NotNil(t, res)
				require.NotEmpty(t, res.AccessToken)
				require.NotNil(t, res.AccessTokenExpiresAt)
			},
		},
		{
			name: "InvalidRefreshToken",
			setupToken: func(tokenMaker token.Maker) string {
				return "invalid_token"
			},
			buildStubs: func(store *mockdb.MockStore, token string) {
				// No database calls should be made for invalid tokens
			},
			checkResponse: func(t *testing.T, res *pb.RefreshTokenResponse, err error) {
				require.Error(t, err)
				require.Nil(t, res)
			},
		},
	}

	for i := range testCases {
		tc := testCases[i]

		t.Run(tc.name, func(t *testing.T) {
			ctrl := gomock.NewController(t)
			defer ctrl.Finish()

			store := mockdb.NewMockStore(ctrl)
			server := newTestServer(t, store)
			
			// Set up the token for this test case
			refreshToken := tc.setupToken(server.tokenMaker)
			tc.buildStubs(store, refreshToken)

			req := &pb.RefreshTokenRequest{
				RefreshToken: refreshToken,
			}

			res, err := server.RefreshToken(context.Background(), req)
			tc.checkResponse(t, res, err)
		})
	}
}
