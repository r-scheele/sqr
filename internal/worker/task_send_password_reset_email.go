package worker

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/hibiken/asynq"
	"github.com/rs/zerolog/log"
)

const TaskSendPasswordResetEmail = "task:send_password_reset_email"

type PayloadSendPasswordResetEmail struct {
	Username   string `json:"username"`
	Email      string `json:"email"`
	ResetToken string `json:"reset_token"`
}

func (distributor *RedisTaskDistributor) DistributeTaskSendPasswordResetEmail(
	ctx context.Context,
	payload *PayloadSendPasswordResetEmail,
	opts ...asynq.Option,
) error {
	jsonPayload, err := json.Marshal(payload)
	if err != nil {
		return fmt.Errorf("failed to marshal task payload: %w", err)
	}

	task := asynq.NewTask(TaskSendPasswordResetEmail, jsonPayload, opts...)
	info, err := distributor.client.EnqueueContext(ctx, task)
	if err != nil {
		return fmt.Errorf("failed to enqueue task: %w", err)
	}

	log.Info().Str("type", task.Type()).Bytes("payload", task.Payload()).
		Str("queue", info.Queue).Int("max_retry", info.MaxRetry).Msg("enqueued task")
	return nil
}

func (processor *RedisTaskProcessor) ProcessTaskSendPasswordResetEmail(ctx context.Context, task *asynq.Task) error {
	var payload PayloadSendPasswordResetEmail
	if err := json.Unmarshal(task.Payload(), &payload); err != nil {
		return fmt.Errorf("failed to unmarshal payload: %w", asynq.SkipRetry)
	}

	user, err := processor.store.GetUserByEmail(ctx, payload.Email)
	if err != nil {
		return fmt.Errorf("failed to get user: %w", err)
	}

	// Send the password reset email
	subject := "Reset Your Password - SQR"
	resetURL := fmt.Sprintf("https://sqr.com/reset-password?token=%s", payload.ResetToken)
	content := fmt.Sprintf(`
		<h1>Reset Your Password</h1>
		<p>Hello %s,</p>
		<p>You have requested to reset your password for your SQR account.</p>
		<p>Click the link below to reset your password:</p>
		<a href="%s">Reset Password</a>
		<p>This link will expire in 1 hour.</p>
		<p>If you did not request this password reset, please ignore this email.</p>
		<br>
		<p>Best regards,<br>The SQR Team</p>
	`, payload.Username, resetURL)

	to := []string{user.Email}
	err = processor.mailer.SendEmail(subject, content, to, nil, nil, nil)
	if err != nil {
		return fmt.Errorf("failed to send password reset email to [%s]: %w", user.Email, err)
	}

	log.Info().Str("type", task.Type()).Str("email", user.Email).
		Msg("sent password reset email")
	return nil
}
