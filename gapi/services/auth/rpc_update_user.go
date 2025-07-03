package auth

import (
	"context"
	"errors"

	db "github.com/r-scheele/sqr/internal/db/sqlc"
	"github.com/r-scheele/sqr/internal/pb"
	"github.com/r-scheele/sqr/internal/util"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (server *Server) UpdateUser(ctx context.Context, req *pb.UpdateUserRequest) (*pb.UpdateUserResponse, error) {
	violations := validateUpdateUserRequest(req)
	if violations != nil {
		return nil, invalidArgumentError(violations)
	}

	user, err := server.store.GetUserByEmail(ctx, req.GetUsername())
	if err != nil {
		if errors.Is(err, db.ErrRecordNotFound) {
			return nil, status.Errorf(codes.NotFound, "user not found")
		}
		return nil, status.Errorf(codes.Internal, "failed to find user")
	}

	firstName := user.FirstName
	lastName := user.LastName
	if req.FullName != nil {
		firstName, lastName = util.SplitFullName(req.GetFullName())
	}

	arg := db.UpdateUserParams{
		ID:                user.ID,
		Email:             user.Email,
		Phone:             user.Phone,
		FirstName:         firstName,
		LastName:          lastName,
		Nin:               user.Nin,
		ProfilePictureUrl: user.ProfilePictureUrl,
	}

	if req.Email != nil {
		arg.Email = req.GetEmail()
	}

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
