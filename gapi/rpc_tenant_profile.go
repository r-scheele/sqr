package gapi

import (
	"context"
	"errors"

	"github.com/jackc/pgx/v5/pgtype"
	db "github.com/r-scheele/sqr/internal/db/sqlc"
	"github.com/r-scheele/sqr/internal/pb"
	"github.com/r-scheele/sqr/internal/util"
	"github.com/r-scheele/sqr/internal/val"
	"google.golang.org/genproto/googleapis/rpc/errdetails"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

var (
	ErrInvalidUserID = errors.New("must be a positive integer")
)

func (server *Server) GetTenantProfile(ctx context.Context, req *pb.GetTenantProfileRequest) (*pb.GetTenantProfileResponse, error) {

	authPayload, err := server.authorizeUser(ctx, []string{util.TenantRole, util.AdminRole})
	if err != nil {
		return nil, unauthenticatedError(err)
	}

	authUser, err := server.store.GetUserByEmail(ctx, authPayload.Username)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "failed to get authenticated user: %s", err)
	}

	if authUser.ID != req.GetUserId() && authUser.UserType != db.UserTypeEnumAdmin {
		return nil, status.Errorf(codes.PermissionDenied, "cannot access other user's profile")
	}

	targetUser, err := server.store.GetUserByID(ctx, req.GetUserId())
	if err != nil {
		return nil, status.Errorf(codes.NotFound, "user not found")
	}

	if targetUser.UserType != db.UserTypeEnumTenant {
		return nil, status.Errorf(codes.InvalidArgument, "user is not a tenant")
	}

	profile, err := server.store.GetTenantProfileByUserID(ctx, req.GetUserId())
	if err != nil {
		if err == db.ErrRecordNotFound {
			return nil, status.Errorf(codes.NotFound, "tenant profile not found")
		}
		return nil, status.Errorf(codes.Internal, "failed to get tenant profile: %s", err)
	}

	rsp := &pb.GetTenantProfileResponse{
		Profile: convertTenantProfile(profile),
	}

	return rsp, nil
}

func (server *Server) UpdateTenantProfile(ctx context.Context, req *pb.UpdateTenantProfileRequest) (*pb.UpdateTenantProfileResponse, error) {

	violations := validateUpdateTenantProfileRequest(req)
	if violations != nil {
		return nil, invalidArgumentError(violations)
	}

	authPayload, err := server.authorizeUser(ctx, []string{util.TenantRole})
	if err != nil {
		return nil, unauthenticatedError(err)
	}

	authUser, err := server.store.GetUserByEmail(ctx, authPayload.Username)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "failed to get authenticated user: %s", err)
	}

	if authUser.ID != req.GetUserId() {
		return nil, status.Errorf(codes.PermissionDenied, "cannot update other user's profile")
	}

	if authUser.UserType != db.UserTypeEnumTenant {
		return nil, status.Errorf(codes.InvalidArgument, "user is not a tenant")
	}

	arg := db.UpdateTenantProfileParams{
		UserID: req.GetUserId(),
	}

	if req.MaxBudget != nil {
		arg.BudgetMax = pgtype.Numeric{Valid: true}
		arg.BudgetMax.Scan(req.GetMaxBudget())
	}

	if len(req.PreferredAreas) > 0 {

		locations := ""
		for i, area := range req.PreferredAreas {
			if i > 0 {
				locations += ", "
			}
			locations += area
		}
		arg.PreferredLocations = pgtype.Text{String: locations, Valid: true}
	}

	if req.AnnualIncome != nil {

		monthlyIncome := req.GetAnnualIncome() / 12
		arg.MonthlyIncome = pgtype.Numeric{Valid: true}
		arg.MonthlyIncome.Scan(monthlyIncome)
	}

	if len(req.References) > 0 {

		references := ""
		for i, ref := range req.References {
			if i > 0 {
				references += "\n"
			}
			references += ref
		}
		arg.References = pgtype.Text{String: references, Valid: true}
	}

	if req.PetOwner != nil {
		arg.PetFriendly = pgtype.Bool{Bool: req.GetPetOwner(), Valid: true}
	}

	if req.Occupation != nil {
		arg.Occupation = pgtype.Text{String: req.GetOccupation(), Valid: true}
	}

	if req.EmployerName != nil {
		arg.Employer = pgtype.Text{String: req.GetEmployerName(), Valid: true}
	}

	if len(req.PreviousAddresses) > 0 {
		// Take the first previous address for now
		arg.PreviousAddress = pgtype.Text{String: req.PreviousAddresses[0], Valid: true}
	}

	if req.MaxBudget != nil {

		if req.GetMaxBudget() > 3000 {
			arg.BedroomsMin = pgtype.Int4{Int32: 2, Valid: true}
			arg.BedroomsMax = pgtype.Int4{Int32: 4, Valid: true}
		} else if req.GetMaxBudget() > 1500 {
			arg.BedroomsMin = pgtype.Int4{Int32: 1, Valid: true}
			arg.BedroomsMax = pgtype.Int4{Int32: 3, Valid: true}
		} else {
			arg.BedroomsMin = pgtype.Int4{Int32: 1, Valid: true}
			arg.BedroomsMax = pgtype.Int4{Int32: 2, Valid: true}
		}

		budgetMin := req.GetMaxBudget() * 0.8
		arg.BudgetMin = pgtype.Numeric{Valid: true}
		arg.BudgetMin.Scan(budgetMin)
	}

	profile, err := server.store.UpdateTenantProfile(ctx, arg)
	if err != nil {
		if err == db.ErrRecordNotFound {
			return nil, status.Errorf(codes.NotFound, "tenant profile not found")
		}
		return nil, status.Errorf(codes.Internal, "failed to update tenant profile: %s", err)
	}

	rsp := &pb.UpdateTenantProfileResponse{
		Profile: convertTenantProfile(profile),
	}

	return rsp, nil
}

func validateUpdateTenantProfileRequest(req *pb.UpdateTenantProfileRequest) (violations []*errdetails.BadRequest_FieldViolation) {
	if req.GetUserId() <= 0 {
		violations = append(violations, fieldViolation("user_id", ErrInvalidUserID))
	}

	if req.MaxBudget != nil {
		if err := val.ValidateMaxBudget(req.GetMaxBudget()); err != nil {
			violations = append(violations, fieldViolation("max_budget", err))
		}
	}

	if len(req.PreferredAreas) > 0 {
		if err := val.ValidatePreferredAreas(req.PreferredAreas); err != nil {
			violations = append(violations, fieldViolation("preferred_areas", err))
		}
	}

	if req.AnnualIncome != nil {
		if err := val.ValidateAnnualIncome(req.GetAnnualIncome()); err != nil {
			violations = append(violations, fieldViolation("annual_income", err))
		}
	}

	if len(req.References) > 0 {
		if err := val.ValidateReferences(req.References); err != nil {
			violations = append(violations, fieldViolation("references", err))
		}
	}

	if req.Occupation != nil {
		if err := val.ValidateOccupation(req.GetOccupation()); err != nil {
			violations = append(violations, fieldViolation("occupation", err))
		}
	}

	if req.EmployerName != nil {
		if err := val.ValidateEmployerInfo(req.GetEmployerName(), ""); err != nil {
			violations = append(violations, fieldViolation("employer_name", err))
		}
	}

	if len(req.PreviousAddresses) > 0 {
		if err := val.ValidatePreviousAddresses(req.PreviousAddresses); err != nil {
			violations = append(violations, fieldViolation("previous_addresses", err))
		}
	}

	return violations
}
