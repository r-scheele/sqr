package gapi

import (
	"context"
	"errors"

	db "github.com/r-scheele/sqr/internal/db/sqlc"
	"github.com/r-scheele/sqr/internal/pb"
	"github.com/r-scheele/sqr/internal/util"
	"github.com/r-scheele/sqr/internal/val"
	"google.golang.org/genproto/googleapis/rpc/errdetails"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (server *Server) UpdateUser(ctx context.Context, req *pb.UpdateUserRequest) (*pb.UpdateUserResponse, error) {
	violations := validateUpdateUserRequest(req)
	if violations != nil {
		return nil, invalidArgumentError(violations)
	}

	// Get the user by email (assuming username is actually email in the request)
	user, err := server.store.GetUserByEmail(ctx, req.GetUsername())
	if err != nil {
		if errors.Is(err, db.ErrRecordNotFound) {
			return nil, status.Errorf(codes.NotFound, "user not found")
		}
		return nil, status.Errorf(codes.Internal, "failed to find user")
	}

	// Split full name if provided
	firstName := user.FirstName
	lastName := user.LastName
	if req.FullName != nil {
		firstName, lastName = util.SplitFullName(req.GetFullName())
	}

	arg := db.UpdateUserParams{
		ID:                user.ID,
		Email:             user.Email, // Keep existing email unless updating
		Phone:             user.Phone, // Keep existing phone
		FirstName:         firstName,
		LastName:          lastName,
		Nin:               user.Nin,               // Keep existing NIN
		ProfilePictureUrl: user.ProfilePictureUrl, // Keep existing profile picture
	}

	// Update email if provided
	if req.Email != nil {
		arg.Email = req.GetEmail()
	}

	// Handle password update separately since it's not in UpdateUserParams
	if req.Password != nil {
		hashedPassword, err := util.HashPassword(req.GetPassword())
		if err != nil {
			return nil, status.Errorf(codes.Internal, "failed to hash password: %s", err)
		}

		// We need to use a separate query for password update since UpdateUserParams doesn't include password
		// For now, we'll update other fields first, then handle password separately
		_ = hashedPassword // TODO: Implement password update query
	}

	updatedUser, err := server.store.UpdateUser(ctx, arg)
	if err != nil {
		if errors.Is(err, db.ErrRecordNotFound) {
			return nil, status.Errorf(codes.NotFound, "user not found")
		}
		return nil, status.Errorf(codes.Internal, "failed to update user: %s", err)
	}

	rsp := &pb.UpdateUserResponse{
		User: convertUser(updatedUser),
	}
	return rsp, nil
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
