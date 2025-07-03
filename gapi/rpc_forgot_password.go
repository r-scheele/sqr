package gapi

import (
	"context"
	"encoding/json"
	"errors"
	"time"

	"github.com/hibiken/asynq"
	db "github.com/r-scheele/sqr/internal/db/sqlc"
	"github.com/r-scheele/sqr/internal/pb"
	"github.com/r-scheele/sqr/internal/util"
	"github.com/r-scheele/sqr/internal/val"
	"github.com/r-scheele/sqr/internal/worker"
	"github.com/rs/zerolog/log"
	"google.golang.org/genproto/googleapis/rpc/errdetails"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (server *Server) ForgotPassword(ctx context.Context, req *pb.ForgotPasswordRequest) (*pb.ForgotPasswordResponse, error) {
	violations := validateForgotPasswordRequest(req)
	if violations != nil {
		return nil, invalidArgumentError(violations)
	}

	user, err := server.store.GetUserByEmail(ctx, req.GetEmail())
	if err != nil {
		if errors.Is(err, db.ErrRecordNotFound) {
			return &pb.ForgotPasswordResponse{
				Message: "If an account with that email exists, a password reset link has been sent.",
			}, nil
		}
		return nil, status.Errorf(codes.Internal, "failed to get user: %s", err)
	}

	resetToken := util.RandomString(32)

	verificationData := map[string]interface{}{
		"secret_code": resetToken,
		"email":       user.Email,
		"user_id":     user.ID,
	}
	verificationJSON, err := json.Marshal(verificationData)
	if err != nil {
		log.Error().Err(err).Msg("failed to marshal verification data")
		return nil, status.Errorf(codes.Internal, "failed to process request")
	}

	_, err = server.store.CreateUserVerification(ctx, db.CreateUserVerificationParams{
		UserID:           user.ID,
		VerificationType: db.VerificationTypeEnumPasswordReset,
		VerificationData: verificationJSON,
	})
	if err != nil {
		log.Error().Err(err).Msg("failed to create password reset verification")
		return nil, status.Errorf(codes.Internal, "failed to process request")
	}

	taskPayload := &worker.PayloadSendPasswordResetEmail{
		Username:   user.FirstName + " " + user.LastName,
		Email:      user.Email,
		ResetToken: resetToken,
	}
	opts := []asynq.Option{
		asynq.MaxRetry(10),
		asynq.ProcessIn(10 * time.Second),
		asynq.Queue(worker.QueueCritical),
	}

	err = server.taskDistributor.DistributeTaskSendPasswordResetEmail(ctx, taskPayload, opts...)
	if err != nil {
		log.Error().Err(err).Msg("failed to distribute send password reset email task")
		return nil, status.Errorf(codes.Internal, "failed to process request")
	}

	log.Info().Str("email", user.Email).Msg("password reset requested")

	return &pb.ForgotPasswordResponse{
		Message: "If an account with that email exists, a password reset link has been sent.",
	}, nil
}

func validateForgotPasswordRequest(req *pb.ForgotPasswordRequest) (violations []*errdetails.BadRequest_FieldViolation) {
	if err := val.ValidateEmail(req.GetEmail()); err != nil {
		violations = append(violations, fieldViolation("email", err))
	}

	return violations
}
