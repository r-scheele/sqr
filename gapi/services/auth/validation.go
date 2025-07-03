package auth

import (
	"errors"

	"github.com/r-scheele/sqr/internal/pb"
	"github.com/r-scheele/sqr/internal/val"
	"google.golang.org/genproto/googleapis/rpc/errdetails"
)

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

func validateLoginUserRequest(req *pb.LoginUserRequest) (violations []*errdetails.BadRequest_FieldViolation) {
	if err := val.ValidateUsername(req.GetUsername()); err != nil {
		violations = append(violations, fieldViolation("username", err))
	}

	if err := val.ValidatePassword(req.GetPassword()); err != nil {
		violations = append(violations, fieldViolation("password", err))
	}

	return violations
}

func validateUpdateUserRequest(req *pb.UpdateUserRequest) (violations []*errdetails.BadRequest_FieldViolation) {
	if err := val.ValidateEmail(req.GetUsername()); err != nil { // Validate as email since username is email
		violations = append(violations, fieldViolation("username", err))
	}

	if req.Password != nil {
		if err := val.ValidatePassword(req.GetPassword()); err != nil {
			violations = append(violations, fieldViolation("password", err))
		}
	}

	if req.FullName != nil {
		if err := val.ValidateFullName(req.GetFullName()); err != nil {
			violations = append(violations, fieldViolation("full_name", err))
		}
	}

	if req.Email != nil {
		if err := val.ValidateEmail(req.GetEmail()); err != nil {
			violations = append(violations, fieldViolation("email", err))
		}
	}

	return violations
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

func validateRefreshTokenRequest(req *pb.RefreshTokenRequest) (violations []*errdetails.BadRequest_FieldViolation) {
	if err := val.ValidateString(req.GetRefreshToken(), 1, 500); err != nil {
		violations = append(violations, fieldViolation("refresh_token", err))
	}

	return violations
}

func validateLogoutUserRequest(req *pb.LogoutUserRequest) (violations []*errdetails.BadRequest_FieldViolation) {
	if err := val.ValidateString(req.GetRefreshToken(), 1, 500); err != nil {
		violations = append(violations, fieldViolation("refresh_token", err))
	}

	return violations
}

func validateForgotPasswordRequest(req *pb.ForgotPasswordRequest) (violations []*errdetails.BadRequest_FieldViolation) {
	if err := val.ValidateEmail(req.GetEmail()); err != nil {
		violations = append(violations, fieldViolation("email", err))
	}

	return violations
}

func validateResetPasswordRequest(req *pb.ResetPasswordRequest) (violations []*errdetails.BadRequest_FieldViolation) {
	if req.GetResetToken() == "" {
		violations = append(violations, fieldViolation("reset_token", errors.New("reset token is required")))
	}

	if err := val.ValidatePassword(req.GetNewPassword()); err != nil {
		violations = append(violations, fieldViolation("new_password", err))
	}

	if req.GetNewPassword() != req.GetConfirmPassword() {
		violations = append(violations, fieldViolation("confirm_password", errors.New("passwords do not match")))
	}

	return violations
}
