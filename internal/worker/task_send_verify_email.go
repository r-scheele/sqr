package worker

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/hibiken/asynq"
	db "github.com/r-scheele/sqr/internal/db/sqlc"
	"github.com/rs/zerolog/log"
)

const TaskSendVerifyEmail = "task:send_verify_email"

type PayloadSendVerifyEmail struct {
	Username   string `json:"username"`
	Email      string `json:"email"`
	SecretCode string `json:"secret_code"`
}

func (distributor *RedisTaskDistributor) DistributeTaskSendVerifyEmail(
	ctx context.Context,
	payload *PayloadSendVerifyEmail,
	opts ...asynq.Option,
) error {
	jsonPayload, err := json.Marshal(payload)
	if err != nil {
		return fmt.Errorf("failed to marshal task payload: %w", err)
	}

	task := asynq.NewTask(TaskSendVerifyEmail, jsonPayload, opts...)
	info, err := distributor.client.EnqueueContext(ctx, task)
	if err != nil {
		return fmt.Errorf("failed to enqueue task: %w", err)
	}

	log.Info().Str("type", task.Type()).Bytes("payload", task.Payload()).
		Str("queue", info.Queue).Int("max_retry", info.MaxRetry).Msg("enqueued task")
	return nil
}

func (processor *RedisTaskProcessor) ProcessTaskSendVerifyEmail(ctx context.Context, task *asynq.Task) error {
	var payload PayloadSendVerifyEmail
	if err := json.Unmarshal(task.Payload(), &payload); err != nil {
		return fmt.Errorf("failed to unmarshal payload: %w", asynq.SkipRetry)
	}

	user, err := processor.store.GetUserByEmail(ctx, payload.Email)
	if err != nil {
		return fmt.Errorf("failed to get user: %w", err)
	}

	// Create JSON verification data
	verificationData := fmt.Sprintf(`{"secret_code": "%s"}`, payload.SecretCode)

	verificationArg := db.CreateUserVerificationParams{
		UserID:           user.ID,
		VerificationType: db.VerificationTypeEnumEmail,
		VerificationStatus: db.NullVerificationStatusEnum{
			VerificationStatusEnum: db.VerificationStatusEnumPending,
			Valid:                  true,
		},
		VerificationData: []byte(verificationData),
	}

	verification, err := processor.store.CreateUserVerification(ctx, verificationArg)
	if err != nil {
		return fmt.Errorf("failed to create user verification: %w", err)
	}

	subject := "Welcome to Sqr"
	// TODO: replace this URL with an environment variable that points to a front-end page
	verifyUrl := fmt.Sprintf("http://localhost:8080/v1/verify_email?email_id=%d&secret_code=%s",
		verification.ID, payload.SecretCode)
	content := fmt.Sprintf(`Hello %s %s,<br/>
	Thank you for registering with us!<br/>
	Please <a href="%s">click here</a> to verify your email address.<br/>
	`, user.FirstName, user.LastName, verifyUrl)
	to := []string{user.Email}

	err = processor.mailer.SendEmail(subject, content, to, nil, nil, nil)
	if err != nil {
		return fmt.Errorf("failed to send verify email: %w", err)
	}

	log.Info().Str("type", task.Type()).Bytes("payload", task.Payload()).
		Str("email", user.Email).Msg("processed task")
	return nil
}
