package user

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

func convertTenantProfile(profile db.TenantProfile) *pb.TenantProfile {
	pbProfile := &pb.TenantProfile{
		UserId:                      profile.UserID,
		Username:                    "",         // We'll need to get this from the user table
		MaxBudget:                   0,          // We'll map this from BudgetMax
		PreferredAreas:              []string{}, // We'll parse from PreferredLocations
		EmploymentStatus:            "employed", // Default, we'll need to derive this
		AnnualIncome:                0,          // We'll calculate from MonthlyIncome
		References:                  []string{}, // We'll parse from References text
		PetOwner:                    profile.PetFriendly.Bool,
		SmokingStatus:               "non_smoker", // Default, not in current schema
		ProfileCompletionPercentage: calculateTenantProfileCompletion(profile),
		CreatedAt:                   timestamppb.New(profile.CreatedAt.Time),
		UpdatedAt:                   timestamppb.New(profile.UpdatedAt.Time),
	}

	// Map BudgetMax to MaxBudget
	if profile.BudgetMax.Valid {
		budgetMax, _ := profile.BudgetMax.Float64Value()
		pbProfile.MaxBudget = budgetMax.Float64
	}

	// Calculate annual income from monthly income
	if profile.MonthlyIncome.Valid {
		monthlyIncome, _ := profile.MonthlyIncome.Float64Value()
		pbProfile.AnnualIncome = monthlyIncome.Float64 * 12
	}

	// Parse preferred locations (assuming comma-separated)
	if profile.PreferredLocations.Valid && profile.PreferredLocations.String != "" {
		// Simple parsing - you might want to use JSON if the format is more complex
		pbProfile.PreferredAreas = []string{profile.PreferredLocations.String}
	}

	// Parse references (assuming comma-separated or newline-separated)
	if profile.References.Valid && profile.References.String != "" {
		pbProfile.References = []string{profile.References.String}
	}

	// Handle occupation
	if profile.Occupation.Valid {
		pbProfile.Occupation = profile.Occupation.String
		if profile.Occupation.String != "" {
			pbProfile.EmploymentStatus = "employed"
		}
	}

	// Handle employer as employer name
	if profile.Employer.Valid {
		pbProfile.EmployerName = profile.Employer.String
	}

	// Handle previous address
	if profile.PreviousAddress.Valid {
		pbProfile.PreviousAddresses = []string{profile.PreviousAddress.String}
	}

	return pbProfile
}

func calculateTenantProfileCompletion(profile db.TenantProfile) int32 {
	totalFields := 10 // Total number of profile fields in current schema
	completedFields := 0

	// Check required fields based on current schema
	if profile.BudgetMin.Valid {
		completedFields++
	}
	if profile.BudgetMax.Valid {
		completedFields++
	}
	if profile.PreferredLocations.Valid && profile.PreferredLocations.String != "" {
		completedFields++
	}
	if profile.BedroomsMin.Valid {
		completedFields++
	}
	if profile.BedroomsMax.Valid {
		completedFields++
	}
	if profile.Occupation.Valid && profile.Occupation.String != "" {
		completedFields++
	}
	if profile.Employer.Valid && profile.Employer.String != "" {
		completedFields++
	}
	if profile.MonthlyIncome.Valid {
		completedFields++
	}
	if profile.References.Valid && profile.References.String != "" {
		completedFields++
	}
	if profile.PetFriendly.Valid {
		completedFields++
	}

	return int32((completedFields * 100) / totalFields)
}
