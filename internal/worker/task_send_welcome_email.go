package worker

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/hibiken/asynq"
	"github.com/rs/zerolog/log"
)

const TaskSendWelcomeEmail = "task:send_welcome_email"

type PayloadSendWelcomeEmail struct {
	Username string `json:"username"`
	Email    string `json:"email"`
}

func (distributor *RedisTaskDistributor) DistributeTaskSendWelcomeEmail(
	ctx context.Context,
	payload *PayloadSendWelcomeEmail,
	opts ...asynq.Option,
) error {
	jsonPayload, err := json.Marshal(payload)
	if err != nil {
		return fmt.Errorf("failed to marshal task payload: %w", err)
	}

	task := asynq.NewTask(TaskSendWelcomeEmail, jsonPayload, opts...)
	info, err := distributor.client.EnqueueContext(ctx, task)
	if err != nil {
		return fmt.Errorf("failed to enqueue task: %w", err)
	}

	log.Info().Str("type", task.Type()).Bytes("payload", task.Payload()).
		Str("queue", info.Queue).Int("max_retry", info.MaxRetry).Msg("enqueued task")
	return nil
}

func (processor *RedisTaskProcessor) ProcessTaskSendWelcomeEmail(ctx context.Context, task *asynq.Task) error {
	var payload PayloadSendWelcomeEmail
	if err := json.Unmarshal(task.Payload(), &payload); err != nil {
		return fmt.Errorf("failed to unmarshal payload: %w", asynq.SkipRetry)
	}

	subject := "Welcome to Sqr - Your Email is Verified!"
	content := fmt.Sprintf(`Hello %s,<br/>
	Congratulations! Your email has been successfully verified.<br/>
	Welcome to Sqr! We're excited to have you on board.<br/>
	You can now access all features of your account.<br/>
	<br/>
	If you have any questions, feel free to contact our support team.<br/>
	<br/>
	Best regards,<br/>
	The Sqr Team
	`, payload.Username)
	to := []string{payload.Email}

	err := processor.mailer.SendEmail(subject, content, to, nil, nil, nil)
	if err != nil {
		return fmt.Errorf("failed to send welcome email: %w", err)
	}

	log.Info().Str("type", task.Type()).Bytes("payload", task.Payload()).
		Str("email", payload.Email).Msg("processed task")
	return nil
}
