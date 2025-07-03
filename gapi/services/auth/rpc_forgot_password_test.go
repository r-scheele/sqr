package auth

import (
	"context"
	"database/sql"
	"testing"

	"github.com/golang/mock/gomock"
	mockdb "github.com/r-scheele/sqr/internal/db/mock"
	db "github.com/r-scheele/sqr/internal/db/sqlc"
	"github.com/r-scheele/sqr/internal/pb"
	"github.com/r-scheele/sqr/internal/util"
	mockwk "github.com/r-scheele/sqr/internal/worker/mock"
	"github.com/stretchr/testify/require"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func TestForgotPasswordAPI(t *testing.T) {
	user, _ := randomUser(t, util.TenantRole)

	testCases := []struct {
		name          string
		req           *pb.ForgotPasswordRequest
		buildStubs    func(store *mockdb.MockStore, taskDistributor *mockwk.MockTaskDistributor)
		checkResponse func(t *testing.T, res *pb.ForgotPasswordResponse, err error)
	}{
		{
			name: "OK",
			req: &pb.ForgotPasswordRequest{
				Email: user.Email,
			},
			buildStubs: func(store *mockdb.MockStore, taskDistributor *mockwk.MockTaskDistributor) {
				store.EXPECT().
					GetUserByEmail(gomock.Any(), gomock.Eq(user.Email)).
					Times(1).
					Return(user, nil)

				store.EXPECT().
					CreateUserVerification(gomock.Any(), gomock.Any()).
					Times(1).
					Return(db.UserVerification{}, nil)

				taskDistributor.EXPECT().
					DistributeTaskSendPasswordResetEmail(gomock.Any(), gomock.Any(), gomock.Any()).
					Times(1).
					Return(nil)
			},
			checkResponse: func(t *testing.T, res *pb.ForgotPasswordResponse, err error) {
				require.NoError(t, err)
				require.NotNil(t, res)
				require.Contains(t, res.GetMessage(), "password reset link has been sent")
			},
		},
		{
			name: "UserNotFound",
			req: &pb.ForgotPasswordRequest{
				Email: user.Email,
			},
			buildStubs: func(store *mockdb.MockStore, taskDistributor *mockwk.MockTaskDistributor) {
				store.EXPECT().
					GetUserByEmail(gomock.Any(), gomock.Eq(user.Email)).
					Times(1).
					Return(db.User{}, db.ErrRecordNotFound)

				store.EXPECT().
					CreateUserVerification(gomock.Any(), gomock.Any()).
					Times(0)

				taskDistributor.EXPECT().
					DistributeTaskSendPasswordResetEmail(gomock.Any(), gomock.Any(), gomock.Any()).
					Times(0)
			},
			checkResponse: func(t *testing.T, res *pb.ForgotPasswordResponse, err error) {
				require.NoError(t, err)
				require.NotNil(t, res)
				// For security, same message even if user doesn't exist
				require.Contains(t, res.GetMessage(), "password reset link has been sent")
			},
		},
		{
			name: "InvalidEmail",
			req: &pb.ForgotPasswordRequest{
				Email: "invalid-email",
			},
			buildStubs: func(store *mockdb.MockStore, taskDistributor *mockwk.MockTaskDistributor) {
				store.EXPECT().
					GetUserByEmail(gomock.Any(), gomock.Any()).
					Times(0)

				store.EXPECT().
					CreateUserVerification(gomock.Any(), gomock.Any()).
					Times(0)

				taskDistributor.EXPECT().
					DistributeTaskSendPasswordResetEmail(gomock.Any(), gomock.Any(), gomock.Any()).
					Times(0)
			},
			checkResponse: func(t *testing.T, res *pb.ForgotPasswordResponse, err error) {
				require.Error(t, err)
				st, ok := status.FromError(err)
				require.True(t, ok)
				require.Equal(t, codes.InvalidArgument, st.Code())
			},
		},
		{
			name: "InternalError",
			req: &pb.ForgotPasswordRequest{
				Email: user.Email,
			},
			buildStubs: func(store *mockdb.MockStore, taskDistributor *mockwk.MockTaskDistributor) {
				store.EXPECT().
					GetUserByEmail(gomock.Any(), gomock.Eq(user.Email)).
					Times(1).
					Return(db.User{}, sql.ErrConnDone)

				store.EXPECT().
					CreateUserVerification(gomock.Any(), gomock.Any()).
					Times(0)

				taskDistributor.EXPECT().
					DistributeTaskSendPasswordResetEmail(gomock.Any(), gomock.Any(), gomock.Any()).
					Times(0)
			},
			checkResponse: func(t *testing.T, res *pb.ForgotPasswordResponse, err error) {
				require.Error(t, err)
				st, ok := status.FromError(err)
				require.True(t, ok)
				require.Equal(t, codes.Internal, st.Code())
			},
		},
	}

	for i := range testCases {
		tc := testCases[i]

		t.Run(tc.name, func(t *testing.T) {
			storeCtrl := gomock.NewController(t)
			defer storeCtrl.Finish()
			store := mockdb.NewMockStore(storeCtrl)

			taskCtrl := gomock.NewController(t)
			defer taskCtrl.Finish()
			taskDistributor := mockwk.NewMockTaskDistributor(taskCtrl)

			tc.buildStubs(store, taskDistributor)
			server := newTestServerWithTaskDistributor(t, store, taskDistributor)

			res, err := server.ForgotPassword(context.Background(), tc.req)
			tc.checkResponse(t, res, err)
		})
	}
}
