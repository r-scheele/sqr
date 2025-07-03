package auth

import (
	"context"
	"errors"

	db "github.com/r-scheele/sqr/internal/db/sqlc"
	"github.com/r-scheele/sqr/internal/pb"
	"github.com/r-scheele/sqr/internal/token"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (server *Server) LogoutUser(ctx context.Context, req *pb.LogoutUserRequest) (*pb.LogoutUserResponse, error) {
	violations := validateLogoutUserRequest(req)
	if violations != nil {
		return nil, InvalidArgumentError(violations)
	}

	_, err := server.tokenMaker.VerifyToken(req.GetRefreshToken(), token.TokenTypeRefreshToken)
	if err != nil {
		return nil, status.Errorf(codes.Unauthenticated, "invalid refresh token")
	}

	session, err := server.store.GetUserSessionByToken(ctx, req.GetRefreshToken())
	if err != nil {
		if errors.Is(err, db.ErrRecordNotFound) {
			return nil, status.Errorf(codes.NotFound, "session not found")
		}
		return nil, status.Errorf(codes.Internal, "failed to get session")
	}

	if !session.IsActive.Bool || !session.IsActive.Valid {
		return nil, status.Errorf(codes.Unauthenticated, "session is already inactive")
	}

	err = server.store.DeactivateSession(ctx, req.GetRefreshToken())
	if err != nil {
		return nil, status.Errorf(codes.Internal, "failed to deactivate session: %v", err)
	}

	rsp := &pb.LogoutUserResponse{
		Message: "Successfully logged out",
	}
	return rsp, nil
}
