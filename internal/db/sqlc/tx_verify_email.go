package db

import (
	"context"
	"encoding/json"
	"errors"

	"github.com/jackc/pgx/v5/pgtype"
	"github.com/rs/zerolog/log"
)

type VerifyEmailTxParams struct {
	EmailID     int64
	SecretCode  string
	AfterVerify func(user User) error
}

type VerifyEmailTxResult struct {
	User         User
	Verification UserVerification
}

func (store *SQLStore) VerifyEmailTx(ctx context.Context, arg VerifyEmailTxParams) (VerifyEmailTxResult, error) {
	var result VerifyEmailTxResult

	err := store.execTx(ctx, func(q *Queries) error {
		var err error

		// Get the verification record by ID
		result.Verification, err = q.GetUserVerificationByID(ctx, arg.EmailID)
		if err != nil {
			if errors.Is(err, ErrRecordNotFound) {
				log.Error().Int64("email_id", arg.EmailID).Msg("verification record not found")
				return ErrRecordNotFound
			}
			log.Error().Err(err).Int64("email_id", arg.EmailID).Msg("failed to get verification record")
			return err
		}

		// Check if this is an email verification
		if result.Verification.VerificationType != VerificationTypeEnumEmail {
			log.Error().
				Int64("email_id", arg.EmailID).
				Str("verification_type", string(result.Verification.VerificationType)).
				Msg("verification record is not for email")
			return errors.New("verification record is not for email")
		}

		// Parse verification data to check secret code
		var verificationData map[string]string
		if err := json.Unmarshal(result.Verification.VerificationData, &verificationData); err != nil {
			log.Error().Err(err).Int64("email_id", arg.EmailID).Msg("failed to parse verification data")
			return err
		}

		storedSecretCode, exists := verificationData["secret_code"]
		if !exists || storedSecretCode != arg.SecretCode {
			log.Error().
				Int64("email_id", arg.EmailID).
				Bool("secret_code_exists", exists).
				Msg("invalid secret code")
			return errors.New("invalid secret code")
		}

		// Update verification status to verified
		_, err = q.UpdateVerificationStatus(ctx, UpdateVerificationStatusParams{
			ID: result.Verification.ID,
			VerificationStatus: NullVerificationStatusEnum{
				VerificationStatusEnum: VerificationStatusEnumVerified,
				Valid:                  true,
			},
			VerifiedBy: pgtype.Int8{Valid: false}, // Self-verified, no verifier
		})
		if err != nil {
			log.Error().Err(err).Int64("verification_id", result.Verification.ID).Msg("failed to update verification status")
			return err
		}

		// Update user's is_verified field
		err = q.UpdateUserVerificationStatus(ctx, UpdateUserVerificationStatusParams{
			ID: result.Verification.UserID,
			IsVerified: pgtype.Bool{
				Bool:  true,
				Valid: true,
			},
		})
		if err != nil {
			log.Error().Err(err).Int64("user_id", result.Verification.UserID).Msg("failed to update user verification status")
			return err
		}

		// Get updated user record
		result.User, err = q.GetUserByID(ctx, result.Verification.UserID)
		if err != nil {
			log.Error().Err(err).Int64("user_id", result.Verification.UserID).Msg("failed to get updated user")
			return err
		}

		log.Info().
			Int64("user_id", result.User.ID).
			Int64("verification_id", result.Verification.ID).
			Msg("email verification completed successfully")

		return nil
	})

	if err != nil {
		return result, err
	}

	// Only call AfterVerify callback if the transaction was successful
	if arg.AfterVerify != nil {
		if err := arg.AfterVerify(result.User); err != nil {
			log.Error().Err(err).Int64("user_id", result.User.ID).Msg("failed to execute after verify callback")
			// Note: We don't return this error as the verification itself was successful
			// The welcome email failure shouldn't roll back the verification
		}
	}

	return result, nil
}
