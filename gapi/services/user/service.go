package user

import (
	"context"

	"github.com/r-scheele/sqr/internal/pb"
)

// Service defines the user service interface
type Service interface {
	// Tenant profile management
	GetTenantProfile(ctx context.Context, req *pb.GetTenantProfileRequest) (*pb.GetTenantProfileResponse, error)
	UpdateTenantProfile(ctx context.Context, req *pb.UpdateTenantProfileRequest) (*pb.UpdateTenantProfileResponse, error)
}
