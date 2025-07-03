package auth

import (
	"context"
	"errors"

	"github.com/jackc/pgx/v5/pgtype"
	db "github.com/r-scheele/sqr/internal/db/sqlc"
	"github.com/r-scheele/sqr/internal/pb"
	"github.com/r-scheele/sqr/internal/util"
	"github.com/rs/zerolog/log"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (server *Server) ResetPassword(ctx context.Context, req *pb.ResetPasswordRequest) (*pb.ResetPasswordResponse, error) {
	violations := validateResetPasswordRequest(req)
	if violations != nil {
		return nil, invalidArgumentError(violations)
	}

	verification, err := server.store.GetPasswordResetVerification(ctx, req.GetResetToken())
	if err != nil {
		if errors.Is(err, db.ErrRecordNotFound) {
			return nil, status.Errorf(codes.InvalidArgument, "invalid or expired reset token")
		}
		return nil, status.Errorf(codes.Internal, "failed to verify reset token: %s", err)
	}

	hashedPassword, err := util.HashPassword(req.GetNewPassword())
	if err != nil {
		return nil, status.Errorf(codes.Internal, "failed to hash password: %s", err)
	}

	err = server.store.UpdateUserPassword(ctx, db.UpdateUserPasswordParams{
		ID:           verification.UserID,
		PasswordHash: hashedPassword,
	})
	if err != nil {
		return nil, status.Errorf(codes.Internal, "failed to update password: %s", err)
	}

	_, err = server.store.UpdateVerificationStatus(ctx, db.UpdateVerificationStatusParams{
		ID: verification.ID,
		VerificationStatus: db.NullVerificationStatusEnum{
			VerificationStatusEnum: db.VerificationStatusEnumVerified,
			Valid:                  true,
		},
		VerifiedBy: pgtype.Int8{
			Int64: verification.UserID,
			Valid: true,
		},
	})
	if err != nil {
		log.Error().Err(err).Msg("failed to update verification status")
		// Don't fail the request since password was already updated
	}

	log.Info().Int64("user_id", verification.UserID).Msg("password reset completed")

	return &pb.ResetPasswordResponse{
		Message: "Your password has been successfully reset.",
	}, nil
}
