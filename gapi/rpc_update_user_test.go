package gapi

import (
	"context"
	"testing"

	"github.com/golang/mock/gomock"
	mockdb "github.com/r-scheele/sqr/internal/db/mock"
	db "github.com/r-scheele/sqr/internal/db/sqlc"
	"github.com/r-scheele/sqr/internal/pb"
	"github.com/r-scheele/sqr/internal/util"
	"github.com/stretchr/testify/require"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func TestUpdateUserAPI(t *testing.T) {
	user, _ := randomUser(t, util.TenantRole)

	newName := util.RandomOwner()
	newEmail := util.RandomEmail()
	invalidEmail := "invalid-email"

	testCases := []struct {
		name          string
		req           *pb.UpdateUserRequest
		buildStubs    func(store *mockdb.MockStore)
		checkResponse func(t *testing.T, res *pb.UpdateUserResponse, err error)
	}{
		{
			name: "OK",
			req: &pb.UpdateUserRequest{
				Username: user.Email, // Use email as username
				FullName: &newName,
				Email:    &newEmail,
			},
			buildStubs: func(store *mockdb.MockStore) {
				// First expect to get the user by email
				store.EXPECT().
					GetUserByEmail(gomock.Any(), user.Email).
					Times(1).
					Return(user, nil)

				// Split the new full name for the update
				firstName, lastName := util.SplitFullName(newName)
				arg := db.UpdateUserParams{
					ID:                user.ID,
					Email:             newEmail,
					Phone:             user.Phone,
					FirstName:         firstName,
					LastName:          lastName,
					Nin:               user.Nin,
					ProfilePictureUrl: user.ProfilePictureUrl,
				}
				updatedUser := db.User{
					ID:                user.ID,
					Email:             newEmail,
					Phone:             user.Phone,
					PasswordHash:      user.PasswordHash,
					FirstName:         firstName,
					LastName:          lastName,
					UserType:          user.UserType,
					Nin:               user.Nin,
					IsVerified:        user.IsVerified,
					IsActive:          user.IsActive,
					ProfilePictureUrl: user.ProfilePictureUrl,
					CreatedAt:         user.CreatedAt,
					UpdatedAt:         user.UpdatedAt,
					LastLogin:         user.LastLogin,
				}
				store.EXPECT().
					UpdateUser(gomock.Any(), gomock.Eq(arg)).
					Times(1).
					Return(updatedUser, nil)
			},
			checkResponse: func(t *testing.T, res *pb.UpdateUserResponse, err error) {
				require.NoError(t, err)
				require.NotNil(t, res)
				updatedUser := res.GetUser()
				firstName, lastName := util.SplitFullName(newName)
				require.Equal(t, firstName+"_"+lastName, updatedUser.Username)
				require.Equal(t, newName, updatedUser.FullName)
				require.Equal(t, newEmail, updatedUser.Email)
			},
		},
		{
			name: "UserNotFound",
			req: &pb.UpdateUserRequest{
				Username: user.Email,
				FullName: &newName,
				Email:    &newEmail,
			},
			buildStubs: func(store *mockdb.MockStore) {
				store.EXPECT().
					GetUserByEmail(gomock.Any(), user.Email).
					Times(1).
					Return(db.User{}, db.ErrRecordNotFound)
			},
			checkResponse: func(t *testing.T, res *pb.UpdateUserResponse, err error) {
				require.Error(t, err)
				st, ok := status.FromError(err)
				require.True(t, ok)
				require.Equal(t, codes.NotFound, st.Code())
			},
		},
		{
			name: "InvalidEmail",
			req: &pb.UpdateUserRequest{
				Username: invalidEmail,
				FullName: &newName,
				Email:    &newEmail,
			},
			buildStubs: func(store *mockdb.MockStore) {
				store.EXPECT().
					GetUserByEmail(gomock.Any(), gomock.Any()).
					Times(0)
				store.EXPECT().
					UpdateUser(gomock.Any(), gomock.Any()).
					Times(0)
			},
			checkResponse: func(t *testing.T, res *pb.UpdateUserResponse, err error) {
				require.Error(t, err)
				st, ok := status.FromError(err)
				require.True(t, ok)
				require.Equal(t, codes.InvalidArgument, st.Code())
			},
		},
	}

	for i := range testCases {
		tc := testCases[i]

		t.Run(tc.name, func(t *testing.T) {
			storeCtrl := gomock.NewController(t)
			defer storeCtrl.Finish()
			store := mockdb.NewMockStore(storeCtrl)

			tc.buildStubs(store)
			server := newTestServer(t, store) // Use simplified signature

			res, err := server.UpdateUser(context.Background(), tc.req)
			tc.checkResponse(t, res, err)
		})
	}
}
