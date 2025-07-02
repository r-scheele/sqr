package gapi

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

func TestResetPasswordAPI(t *testing.T) {
	user, _ := randomUser(t, util.TenantRole)
	newPassword := util.RandomString(8)
	resetToken := util.RandomString(32)

	verification := db.UserVerification{
		ID:                 1,
		UserID:             user.ID,
		VerificationType:   db.VerificationTypeEnumPasswordReset,
		VerificationStatus: db.NullVerificationStatusEnum{VerificationStatusEnum: db.VerificationStatusEnumPending, Valid: true},
	}

	testCases := []struct {
		name          string
		req           *pb.ResetPasswordRequest
		buildStubs    func(store *mockdb.MockStore, taskDistributor *mockwk.MockTaskDistributor)
		checkResponse func(t *testing.T, res *pb.ResetPasswordResponse, err error)
	}{
		{
			name: "OK",
			req: &pb.ResetPasswordRequest{
				ResetToken:      resetToken,
				NewPassword:     newPassword,
				ConfirmPassword: newPassword,
			},
			buildStubs: func(store *mockdb.MockStore, taskDistributor *mockwk.MockTaskDistributor) {
				store.EXPECT().
					GetPasswordResetVerification(gomock.Any(), gomock.Eq(resetToken)).
					Times(1).
					Return(verification, nil)

				store.EXPECT().
					UpdateUserPassword(gomock.Any(), gomock.Any()).
					Times(1).
					Return(nil)

				store.EXPECT().
					UpdateVerificationStatus(gomock.Any(), gomock.Any()).
					Times(1).
					Return(db.UserVerification{}, nil)
			},
			checkResponse: func(t *testing.T, res *pb.ResetPasswordResponse, err error) {
				require.NoError(t, err)
				require.NotNil(t, res)
				require.Contains(t, res.GetMessage(), "successfully reset")
			},
		},
		{
			name: "InvalidToken",
			req: &pb.ResetPasswordRequest{
				ResetToken:      "invalid-token",
				NewPassword:     newPassword,
				ConfirmPassword: newPassword,
			},
			buildStubs: func(store *mockdb.MockStore, taskDistributor *mockwk.MockTaskDistributor) {
				store.EXPECT().
					GetPasswordResetVerification(gomock.Any(), gomock.Eq("invalid-token")).
					Times(1).
					Return(db.UserVerification{}, db.ErrRecordNotFound)

				store.EXPECT().
					UpdateUserPassword(gomock.Any(), gomock.Any()).
					Times(0)

				store.EXPECT().
					UpdateVerificationStatus(gomock.Any(), gomock.Any()).
					Times(0)
			},
			checkResponse: func(t *testing.T, res *pb.ResetPasswordResponse, err error) {
				require.Error(t, err)
				st, ok := status.FromError(err)
				require.True(t, ok)
				require.Equal(t, codes.InvalidArgument, st.Code())
				require.Contains(t, st.Message(), "invalid or expired reset token")
			},
		},
		{
			name: "PasswordMismatch",
			req: &pb.ResetPasswordRequest{
				ResetToken:      resetToken,
				NewPassword:     newPassword,
				ConfirmPassword: "different-password",
			},
			buildStubs: func(store *mockdb.MockStore, taskDistributor *mockwk.MockTaskDistributor) {
				store.EXPECT().
					GetPasswordResetVerification(gomock.Any(), gomock.Any()).
					Times(0)

				store.EXPECT().
					UpdateUserPassword(gomock.Any(), gomock.Any()).
					Times(0)

				store.EXPECT().
					UpdateVerificationStatus(gomock.Any(), gomock.Any()).
					Times(0)
			},
			checkResponse: func(t *testing.T, res *pb.ResetPasswordResponse, err error) {
				require.Error(t, err)
				st, ok := status.FromError(err)
				require.True(t, ok)
				require.Equal(t, codes.InvalidArgument, st.Code())
			},
		},
		{
			name: "WeakPassword",
			req: &pb.ResetPasswordRequest{
				ResetToken:      resetToken,
				NewPassword:     "123", // Too short
				ConfirmPassword: "123",
			},
			buildStubs: func(store *mockdb.MockStore, taskDistributor *mockwk.MockTaskDistributor) {
				store.EXPECT().
					GetPasswordResetVerification(gomock.Any(), gomock.Any()).
					Times(0)

				store.EXPECT().
					UpdateUserPassword(gomock.Any(), gomock.Any()).
					Times(0)

				store.EXPECT().
					UpdateVerificationStatus(gomock.Any(), gomock.Any()).
					Times(0)
			},
			checkResponse: func(t *testing.T, res *pb.ResetPasswordResponse, err error) {
				require.Error(t, err)
				st, ok := status.FromError(err)
				require.True(t, ok)
				require.Equal(t, codes.InvalidArgument, st.Code())
			},
		},
		{
			name: "InternalError",
			req: &pb.ResetPasswordRequest{
				ResetToken:      resetToken,
				NewPassword:     newPassword,
				ConfirmPassword: newPassword,
			},
			buildStubs: func(store *mockdb.MockStore, taskDistributor *mockwk.MockTaskDistributor) {
				store.EXPECT().
					GetPasswordResetVerification(gomock.Any(), gomock.Eq(resetToken)).
					Times(1).
					Return(verification, nil)

				store.EXPECT().
					UpdateUserPassword(gomock.Any(), gomock.Any()).
					Times(1).
					Return(sql.ErrConnDone)

				store.EXPECT().
					UpdateVerificationStatus(gomock.Any(), gomock.Any()).
					Times(0)
			},
			checkResponse: func(t *testing.T, res *pb.ResetPasswordResponse, err error) {
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

			res, err := server.ResetPassword(context.Background(), tc.req)
			tc.checkResponse(t, res, err)
		})
	}
}
