package gapi

import (
	"context"
	"time"

	"github.com/hibiken/asynq"
	db "github.com/r-scheele/sqr/internal/db/sqlc"
	"github.com/r-scheele/sqr/internal/pb"
	"github.com/r-scheele/sqr/internal/val"
	"github.com/r-scheele/sqr/internal/worker"
	"google.golang.org/genproto/googleapis/rpc/errdetails"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (server *Server) VerifyEmail(ctx context.Context, req *pb.VerifyEmailRequest) (*pb.VerifyEmailResponse, error) {
	violations := validateVerifyEmailRequest(req)
	if violations != nil {
		return nil, invalidArgumentError(violations)
	}

	arg := db.VerifyEmailTxParams{
		EmailID:    req.GetEmailId(),
		SecretCode: req.GetSecretCode(),
		AfterVerify: func(user db.User) error {

			taskPayload := &worker.PayloadSendWelcomeEmail{
				Username: user.FirstName + " " + user.LastName, // Use full name as display name
				Email:    user.Email,
			}
			opts := []asynq.Option{
				asynq.MaxRetry(10),
				asynq.ProcessIn(10 * time.Second),
				asynq.Queue(worker.QueueCritical),
			}

			return server.taskDistributor.DistributeTaskSendWelcomeEmail(ctx, taskPayload, opts...)
		},
	}

	result, err := server.store.VerifyEmailTx(ctx, arg)
	if err != nil {
		if err == db.ErrRecordNotFound {
			return nil, status.Errorf(codes.NotFound, "verification record not found")
		}

		switch err.Error() {
		case "verification record is not for email":
			return nil, status.Errorf(codes.InvalidArgument, "verification record is not for email")
		case "invalid secret code":
			return nil, status.Errorf(codes.InvalidArgument, "invalid secret code")
		default:
			return nil, status.Errorf(codes.Internal, "failed to verify email: %v", err)
		}
	}

	rsp := &pb.VerifyEmailResponse{
		IsVerified: result.User.IsVerified.Bool,
	}
	return rsp, nil
}

func validateVerifyEmailRequest(req *pb.VerifyEmailRequest) (violations []*errdetails.BadRequest_FieldViolation) {
	if err := val.ValidateEmailId(req.GetEmailId()); err != nil {
		violations = append(violations, fieldViolation("email_id", err))
	}

	if err := val.ValidateSecretCode(req.GetSecretCode()); err != nil {
		violations = append(violations, fieldViolation("secret_code", err))
	}

	return violations
}
