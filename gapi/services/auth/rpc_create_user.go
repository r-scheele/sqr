package auth

import (
	"context"
	"encoding/json"
	"time"

	"github.com/hibiken/asynq"
	db "github.com/r-scheele/sqr/internal/db/sqlc"
	"github.com/r-scheele/sqr/internal/pb"
	"github.com/r-scheele/sqr/internal/util"
	"github.com/r-scheele/sqr/internal/worker"
	"github.com/rs/zerolog/log"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (server *Server) CreateUser(ctx context.Context, req *pb.CreateUserRequest) (*pb.CreateUserResponse, error) {
	violations := validateCreateUserRequest(req)
	if violations != nil {
		return nil, InvalidArgumentError(violations)
	}

	hashedPassword, err := util.HashPassword(req.GetPassword())
	if err != nil {
		return nil, status.Errorf(codes.Internal, "failed to hash password: %s", err)
	}

	firstName, lastName := util.SplitFullName(req.GetFullName())

	arg := db.CreateUserTxParams{
		CreateUserParams: db.CreateUserParams{
			Email:        req.GetEmail(),
			Phone:        req.GetPhoneNumber(),
			PasswordHash: hashedPassword,
			FirstName:    firstName,
			LastName:     lastName,
			UserType:     db.UserTypeEnum(req.GetUserType()),
		},
		AfterCreate: func(user db.User) error {

			secretCode := util.RandomString(32)

			verificationData := map[string]string{
				"secret_code": secretCode,
				"email":       user.Email,
			}
			verificationJSON, err := json.Marshal(verificationData)
			if err != nil {
				log.Error().Err(err).Msg("failed to marshal verification data")
				return err
			}

			_, err = server.store.CreateUserVerification(ctx, db.CreateUserVerificationParams{
				UserID:           user.ID,
				VerificationType: db.VerificationTypeEnumEmail,
				VerificationData: verificationJSON,
			})
			if err != nil {
				log.Error().Err(err).Msg("failed to create user verification")
				return err
			}

			taskPayload := &worker.PayloadSendVerifyEmail{
				Username:   user.FirstName + " " + user.LastName,
				SecretCode: secretCode,
			}
			opts := []asynq.Option{
				asynq.MaxRetry(10),
				asynq.ProcessIn(10 * time.Second),
				asynq.Queue(worker.QueueCritical),
			}

			return server.taskDistributor.DistributeTaskSendVerifyEmail(ctx, taskPayload, opts...)
		},
	}

	if req.GetProfilePictureUrl() != "" {
		arg.ProfilePictureUrl.Valid = true
		arg.ProfilePictureUrl.String = req.GetProfilePictureUrl()
	}

	txResult, err := server.store.CreateUserTx(ctx, arg)
	if err != nil {
		if db.ErrorCode(err) == db.UniqueViolation {
			return nil, status.Error(codes.AlreadyExists, err.Error())
		}
		return nil, status.Errorf(codes.Internal, "failed to create user: %s", err)
	}

	rsp := &pb.CreateUserResponse{
		User: convertUser(txResult.User),
	}
	return rsp, nil
}
