package gapi

import (
	"context"
	"encoding/json"
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

func (server *Server) CreateUser(ctx context.Context, req *pb.CreateUserRequest) (*pb.CreateUserResponse, error) {
	violations := validateCreateUserRequest(req)
	if violations != nil {
		return nil, invalidArgumentError(violations)
	}

	hashedPassword, err := util.HashPassword(req.GetPassword())
	if err != nil {
		return nil, status.Errorf(codes.Internal, "failed to hash password: %s", err)
	}

	// Split full name into first and last name
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
			// Generate verification secret code
			secretCode := util.RandomString(32)

			// Prepare verification data as JSON
			verificationData := map[string]string{
				"secret_code": secretCode,
				"email":       user.Email,
			}
			verificationJSON, err := json.Marshal(verificationData)
			if err != nil {
				log.Error().Err(err).Msg("failed to marshal verification data")
				return err
			}

			// Create user verification record for email verification
			_, err = server.store.CreateUserVerification(ctx, db.CreateUserVerificationParams{
				UserID:           user.ID,
				VerificationType: db.VerificationTypeEnumEmail,
				VerificationData: verificationJSON,
			})
			if err != nil {
				log.Error().Err(err).Msg("failed to create user verification")
				return err
			}

			// Send verification email
			taskPayload := &worker.PayloadSendVerifyEmail{
				Username:   user.FirstName + " " + user.LastName, // Use full name as display name
				Email:      user.Email,
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

	// Set optional fields if provided
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

// validateCreateUserRequest validates the create user request
func validateCreateUserRequest(req *pb.CreateUserRequest) (violations []*errdetails.BadRequest_FieldViolation) {
	if err := val.ValidatePassword(req.GetPassword()); err != nil {
		violations = append(violations, fieldViolation("password", err))
	}

	if err := val.ValidateFullName(req.GetFullName()); err != nil {
		violations = append(violations, fieldViolation("full_name", err))
	}

	if err := val.ValidateEmail(req.GetEmail()); err != nil {
		violations = append(violations, fieldViolation("email", err))
	}

	if req.GetPhoneNumber() != "" {
		if err := val.ValidatePhoneNumber(req.GetPhoneNumber()); err != nil {
			violations = append(violations, fieldViolation("phone_number", err))
		}
	}

	if err := val.ValidateUserType(req.GetUserType()); err != nil {
		violations = append(violations, fieldViolation("user_type", err))
	}

	if req.GetDateOfBirth() != nil {
		dob := req.GetDateOfBirth().AsTime()
		if err := val.ValidateDateOfBirth(dob); err != nil {
			violations = append(violations, fieldViolation("date_of_birth", err))
		}
	}

	if req.GetGender() != "" {
		if err := val.ValidateGender(req.GetGender()); err != nil {
			violations = append(violations, fieldViolation("gender", err))
		}
	}

	return violations
}
