package val

import (
	"fmt"
	"net/mail"
	"regexp"
	"time"
)

var (
	isValidUsername = regexp.MustCompile(`^[a-z0-9_]+$`).MatchString
	isValidFullName = regexp.MustCompile(`^[a-zA-Z\s]+$`).MatchString
	isValidPhone    = regexp.MustCompile(`^\+[1-9]\d{1,14}$`).MatchString
)

func ValidateString(value string, minLength int, maxLength int) error {
	n := len(value)
	if n < minLength || n > maxLength {
		return fmt.Errorf("must contain from %d-%d characters", minLength, maxLength)
	}
	return nil
}

func ValidateUsername(value string) error {
	if err := ValidateString(value, 3, 100); err != nil {
		return err
	}
	if !isValidUsername(value) {
		return fmt.Errorf("must contain only lowercase letters, digits, or underscore")
	}
	return nil
}

func ValidateFullName(value string) error {
	if err := ValidateString(value, 3, 100); err != nil {
		return err
	}
	if !isValidFullName(value) {
		return fmt.Errorf("must contain only letters or spaces")
	}
	return nil
}

func ValidatePassword(value string) error {
	return ValidateString(value, 6, 100)
}

func ValidateEmail(value string) error {
	if err := ValidateString(value, 3, 200); err != nil {
		return err
	}
	if _, err := mail.ParseAddress(value); err != nil {
		return fmt.Errorf("is not a valid email address")
	}
	return nil
}

func ValidateEmailId(value int64) error {
	if value <= 0 {
		return fmt.Errorf("must be a positive integer")
	}
	return nil
}

func ValidateSecretCode(value string) error {
	return ValidateString(value, 32, 128)
}

func ValidatePhoneNumber(value string) error {
	if err := ValidateString(value, 7, 20); err != nil {
		return err
	}
	if !isValidPhone(value) {
		return fmt.Errorf("must be a valid phone number with country code")
	}
	return nil
}

func ValidateUserType(value string) error {
	validTypes := []string{"tenant", "landlord", "inspection_agent", "admin"}
	for _, validType := range validTypes {
		if value == validType {
			return nil
		}
	}
	return fmt.Errorf("must be one of: %v", validTypes)
}

func ValidateDateOfBirth(value time.Time) error {
	now := time.Now()
	age := now.Year() - value.Year()

	if age < 18 {
		return fmt.Errorf("user must be at least 18 years old")
	}

	if age > 120 {
		return fmt.Errorf("invalid date of birth")
	}

	return nil
}

func ValidateGender(value string) error {
	validGenders := []string{"male", "female", "other", "prefer_not_to_say"}
	for _, validGender := range validGenders {
		if value == validGender {
			return nil
		}
	}
	return fmt.Errorf("must be one of: %v", validGenders)
}
