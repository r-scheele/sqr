package auth

import (
	db "github.com/r-scheele/sqr/internal/db/sqlc"
	"github.com/r-scheele/sqr/internal/pb"
	"google.golang.org/protobuf/types/known/timestamppb"
)

func convertUser(user db.User) *pb.User {
	return &pb.User{
		Username:          user.FirstName + "_" + user.LastName, // Create a username from first+last name
		FullName:          user.FirstName + " " + user.LastName,
		Email:             user.Email,
		PasswordChangedAt: timestamppb.New(user.UpdatedAt.Time),
		CreatedAt:         timestamppb.New(user.CreatedAt.Time),
	}
}
