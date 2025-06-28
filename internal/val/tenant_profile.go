package val

import (
	"fmt"
	"time"
)

func ValidateMaxBudget(budget float64) error {
	if budget < 0 {
		return fmt.Errorf("max budget cannot be negative")
	}
	if budget > 100000 {
		return fmt.Errorf("max budget seems unreasonably high")
	}
	return nil
}

func ValidateAnnualIncome(income float64) error {
	if income < 0 {
		return fmt.Errorf("annual income cannot be negative")
	}
	if income > 10000000 {
		return fmt.Errorf("annual income seems unreasonably high")
	}
	return nil
}

func ValidateEmploymentStatus(status string) error {
	validStatuses := []string{
		"employed", "unemployed", "self_employed", "student",
		"retired", "freelancer", "part_time", "contractor",
	}

	for _, validStatus := range validStatuses {
		if status == validStatus {
			return nil
		}
	}
	return fmt.Errorf("must be one of: %v", validStatuses)
}

func ValidateSmokingStatus(status string) error {
	validStatuses := []string{"smoker", "non_smoker", "occasional", "vaper"}

	for _, validStatus := range validStatuses {
		if status == validStatus {
			return nil
		}
	}
	return fmt.Errorf("must be one of: %v", validStatuses)
}

func ValidatePreferredAreas(areas []string) error {
	if len(areas) > 10 {
		return fmt.Errorf("cannot specify more than 10 preferred areas")
	}

	for _, area := range areas {
		if err := ValidateString(area, 2, 100); err != nil {
			return fmt.Errorf("preferred area %s: %v", area, err)
		}
	}
	return nil
}

func ValidateReferences(references []string) error {
	if len(references) > 5 {
		return fmt.Errorf("cannot specify more than 5 references")
	}

	for i, ref := range references {
		if err := ValidateString(ref, 10, 500); err != nil {
			return fmt.Errorf("reference %d: %v", i+1, err)
		}
	}
	return nil
}

func ValidatePreferredMoveInDate(date time.Time) error {
	now := time.Now()
	if date.Before(now.AddDate(0, 0, -1)) { // Allow today but not past dates
		return fmt.Errorf("preferred move-in date cannot be in the past")
	}

	if date.After(now.AddDate(2, 0, 0)) { // Not more than 2 years in future
		return fmt.Errorf("preferred move-in date cannot be more than 2 years in the future")
	}

	return nil
}

func ValidatePetDetails(details string) error {
	if details == "" {
		return nil
	}
	return ValidateString(details, 5, 500)
}

func ValidateEmergencyContact(name, phone string) error {
	if name != "" {
		if err := ValidateFullName(name); err != nil {
			return fmt.Errorf("emergency contact name: %v", err)
		}
	}

	if phone != "" {
		if err := ValidatePhoneNumber(phone); err != nil {
			return fmt.Errorf("emergency contact phone: %v", err)
		}
	}

	return nil
}

func ValidateOccupation(occupation string) error {
	if occupation == "" {
		return nil
	}
	return ValidateString(occupation, 2, 100)
}

func ValidateEmployerInfo(name, contact string) error {
	if name != "" {
		if err := ValidateString(name, 2, 200); err != nil {
			return fmt.Errorf("employer name: %v", err)
		}
	}

	if contact != "" {
		if err := ValidateString(contact, 5, 200); err != nil {
			return fmt.Errorf("employer contact: %v", err)
		}
	}

	return nil
}

func ValidatePreviousAddresses(addresses []string) error {
	if len(addresses) > 5 {
		return fmt.Errorf("cannot specify more than 5 previous addresses")
	}

	for i, addr := range addresses {
		if err := ValidateString(addr, 10, 300); err != nil {
			return fmt.Errorf("previous address %d: %v", i+1, err)
		}
	}
	return nil
}

func ValidateAdditionalNotes(notes string) error {
	if notes == "" {
		return nil
	}
	return ValidateString(notes, 10, 1000)
}
