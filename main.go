package main

import (
	"context"
	"os"
	"os/signal"
	"syscall"

	_ "github.com/golang-migrate/migrate/v4/database/postgres"
	_ "github.com/golang-migrate/migrate/v4/source/file"
	"github.com/hibiken/asynq"
	"github.com/jackc/pgx/v5/pgxpool"
	_ "github.com/r-scheele/sqr/doc/statik"
	cache "github.com/r-scheele/sqr/internal/cache"
	db "github.com/r-scheele/sqr/internal/db/sqlc"
	"github.com/r-scheele/sqr/internal/ratelimit"
	"github.com/r-scheele/sqr/internal/util"
	"github.com/r-scheele/sqr/internal/worker"
	"github.com/r-scheele/sqr/lifespan"
	"github.com/redis/go-redis/v9"
	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
	"golang.org/x/sync/errgroup"
)

var interruptSignals = []os.Signal{
	os.Interrupt,
	syscall.SIGTERM,
	syscall.SIGINT,
}

func main() {
	config, err := util.LoadConfig(".")
	if err != nil {
		log.Fatal().Err(err).Msg("cannot load config")
	}

	if config.Environment == "development" {
		log.Logger = log.Output(zerolog.ConsoleWriter{Out: os.Stderr})
	}

	ctx, stop := signal.NotifyContext(context.Background(), interruptSignals...)
	defer stop()

	connPool, err := pgxpool.New(ctx, config.DBSource)
	if err != nil {
		log.Fatal().Err(err).Msg("cannot connect to db")
	}

	lifespan.RunDBMigration(config.MigrationURL, config.DBSource)

	store := db.NewStore(connPool)

	cacheManager, err := cache.NewCacheManager(config)
	if err != nil {
		log.Fatal().Err(err).Msg("cannot create cache manager")
	}

	defer cacheManager.Close()

	cachedStore := db.NewCachedStore(store.(*db.SQLStore), cacheManager)

	redisOpt := asynq.RedisClientOpt{
		Addr: config.RedisAddress,
	}

	taskDistributor := worker.NewRedisTaskDistributor(redisOpt)

	redisClient := redis.NewClient(&redis.Options{
		Addr: config.RedisAddress,
	})
	limiter := ratelimit.NewRedisLimiter(redisClient, "rate_limit:", config)
	rateLimiter := ratelimit.NewGRPCRateLimiter(limiter, config)

	waitGroup, ctx := errgroup.WithContext(ctx)
	lifespan.RunTaskProcessor(ctx, waitGroup, config, redisOpt, store)
	lifespan.RunGatewayServer(ctx, waitGroup, config, cachedStore, taskDistributor, rateLimiter)
	lifespan.RunGrpcServer(ctx, waitGroup, config, cachedStore, taskDistributor, rateLimiter)

	err = waitGroup.Wait()
	if err != nil {
		log.Fatal().Err(err).Msg("error from wait group")
	}
}
