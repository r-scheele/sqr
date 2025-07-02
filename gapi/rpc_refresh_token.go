package gapi

import (
	"context"
	"errors"

	db "github.com/r-scheele/sqr/internal/db/sqlc"
	"github.com/r-scheele/sqr/internal/pb"
	"github.com/r-scheele/sqr/internal/token"
	"github.com/r-scheele/sqr/internal/val"
	"google.golang.org/genproto/googleapis/rpc/errdetails"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/types/known/timestamppb"
)

func (server *Server) RefreshToken(ctx context.Context, req *pb.RefreshTokenRequest) (*pb.RefreshTokenResponse, error) {
	violations := validateRefreshTokenRequest(req)
	if violations != nil {
		return nil, invalidArgumentError(violations)
	}

	// Verify the refresh token
	refreshPayload, err := server.tokenMaker.VerifyToken(req.GetRefreshToken(), token.TokenTypeRefreshToken)
	if err != nil {
		return nil, status.Errorf(codes.Unauthenticated, "invalid refresh token")
	}

	// Get session from database to ensure it's still valid
	session, err := server.store.GetUserSessionByToken(ctx, req.GetRefreshToken())
	if err != nil {
		if errors.Is(err, db.ErrRecordNotFound) {
			return nil, status.Errorf(codes.Unauthenticated, "session not found")
		}
		return nil, status.Errorf(codes.Internal, "failed to get session")
	}

	// Check if session is still active
	if !session.IsActive.Bool || !session.IsActive.Valid {
		return nil, status.Errorf(codes.Unauthenticated, "session is no longer active")
	}

	// Get user details to get the role for the new token
	user, err := server.store.GetUserByID(ctx, session.UserID)
	if err != nil {
		if errors.Is(err, db.ErrRecordNotFound) {
			return nil, status.Errorf(codes.NotFound, "user not found")
		}
		return nil, status.Errorf(codes.Internal, "failed to get user")
	}

	// Create a new access token
	accessToken, accessPayload, err := server.tokenMaker.CreateToken(
		refreshPayload.Username,
		string(user.UserType),
		server.config.AccessTokenDuration,
		token.TokenTypeAccessToken,
	)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "failed to create access token")
	}

	// Update session activity (extend expiration if needed)
	err = server.store.UpdateSessionActivity(ctx, db.UpdateSessionActivityParams{
		SessionToken: req.GetRefreshToken(),
		ExpiresAt:    refreshPayload.ExpiredAt, // Keep the same expiration
	})
	if err != nil {
		// Log this error but don't fail the request
		// The token refresh can still succeed even if we can't update the session
	}

	rsp := &pb.RefreshTokenResponse{
		AccessToken:          accessToken,
		AccessTokenExpiresAt: timestamppb.New(accessPayload.ExpiredAt),
	}
	return rsp, nil
}

func validateRefreshTokenRequest(req *pb.RefreshTokenRequest) (violations []*errdetails.BadRequest_FieldViolation) {
	if err := val.ValidateString(req.GetRefreshToken(), 1, 500); err != nil {
		violations = append(violations, fieldViolation("refresh_token", err))
	}

	return violations
}
