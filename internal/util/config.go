package util

import (
	"time"

	"github.com/spf13/viper"
)

// Config stores all configuration of the application.
// The values are read by viper from a config file or environment variable.
type Config struct {
	Environment    string   `mapstructure:"ENVIRONMENT"`
	AllowedOrigins []string `mapstructure:"ALLOWED_ORIGINS"`
	DBSource       string   `mapstructure:"DB_SOURCE"`
	MigrationURL   string   `mapstructure:"MIGRATION_URL"`

	HTTPServerAddress    string        `mapstructure:"HTTP_SERVER_ADDRESS"`
	GRPCServerAddress    string        `mapstructure:"GRPC_SERVER_ADDRESS"`
	TokenSymmetricKey    string        `mapstructure:"TOKEN_SYMMETRIC_KEY"`
	AccessTokenDuration  time.Duration `mapstructure:"ACCESS_TOKEN_DURATION"`
	RefreshTokenDuration time.Duration `mapstructure:"REFRESH_TOKEN_DURATION"`

	RedisAddress      string        `mapstructure:"REDIS_ADDRESS"`
	RedisPassword     string        `mapstructure:"REDIS_PASSWORD"`
	RedisDB           int           `mapstructure:"REDIS_DB"`
	RedisMaxRetries   int           `mapstructure:"REDIS_MAX_RETRIES"`
	RedisPoolSize     int           `mapstructure:"REDIS_POOL_SIZE"`
	RedisDialTimeout  time.Duration `mapstructure:"REDIS_DIAL_TIMEOUT"`
	RedisReadTimeout  time.Duration `mapstructure:"REDIS_READ_TIMEOUT"`
	RedisWriteTimeout time.Duration `mapstructure:"REDIS_WRITE_TIMEOUT"`

	CacheEnabled    bool          `mapstructure:"CACHE_ENABLED"`
	CacheType       string        `mapstructure:"CACHE_TYPE"`
	CachePrefix     string        `mapstructure:"CACHE_PREFIX"`
	CacheDefaultTTL time.Duration `mapstructure:"CACHE_DEFAULT_TTL"`

	MemoryCacheSize            int           `mapstructure:"MEMORY_CACHE_SIZE"`
	MemoryCacheTTL             time.Duration `mapstructure:"MEMORY_CACHE_TTL"`
	MemoryCacheCleanUpInterval time.Duration `mapstructure:"MEMORY_CACHE_CLEANUP_INTERVAL"`

	EmailSenderName     string `mapstructure:"EMAIL_SENDER_NAME"`
	EmailSenderAddress  string `mapstructure:"EMAIL_SENDER_ADDRESS"`
	EmailSenderPassword string `mapstructure:"EMAIL_SENDER_PASSWORD"`

	RateLimitEnabled      bool          `mapstructure:"RATE_LIMIT_ENABLED"`
	RateLimitDefaultRPS   int           `mapstructure:"RATE_LIMIT_DEFAULT_RPS"`
	RateLimitDefaultBurst int           `mapstructure:"RATE_LIMIT_DEFAULT_BURST"`
	RateLimitWindow       time.Duration `mapstructure:"RATE_LIMIT_WINDOW"`
	RateLimitStorage      string        `mapstructure:"RATE_LIMIT_STORAGE"`       // redis, memory
	RateLimitDefaultLimit int64         `mapstructure:"RATE_LIMIT_DEFAULT_LIMIT"` // Default limit for rate limiting
}

// LoadConfig reads configuration from file or environment variables.
func LoadConfig(path string) (config Config, err error) {
	viper.AddConfigPath(path)
	viper.SetConfigName("app")
	viper.SetConfigType("env")

	viper.AutomaticEnv()

	err = viper.ReadInConfig()
	if err != nil {
		return
	}

	err = viper.Unmarshal(&config)
	return
}
