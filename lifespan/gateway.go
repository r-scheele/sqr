package lifespan

import (
	"context"
	"errors"
	"net/http"

	"github.com/grpc-ecosystem/grpc-gateway/v2/runtime"
	"github.com/r-scheele/sqr/gapi"
	db "github.com/r-scheele/sqr/internal/db/sqlc"
	"github.com/r-scheele/sqr/internal/pb"
	"github.com/r-scheele/sqr/internal/ratelimit"
	"github.com/r-scheele/sqr/internal/util"
	"github.com/r-scheele/sqr/internal/worker"
	"github.com/rakyll/statik/fs"
	"github.com/rs/cors"
	"github.com/rs/zerolog/log"
	"golang.org/x/sync/errgroup"
	"google.golang.org/protobuf/encoding/protojson"
)

func RunGatewayServer(
	ctx context.Context,
	waitGroup *errgroup.Group,
	config util.Config,
	store db.Store,
	taskDistributor worker.TaskDistributor,
	rateLimiter *ratelimit.GRPCRateLimiter,
) {
	server, err := gapi.NewServer(config, store, taskDistributor, rateLimiter)
	if err != nil {
		log.Fatal().Err(err).Msg("cannot create server")
	}

	jsonOption := runtime.WithMarshalerOption(runtime.MIMEWildcard, &runtime.JSONPb{
		MarshalOptions: protojson.MarshalOptions{
			UseProtoNames: true,
		},
		UnmarshalOptions: protojson.UnmarshalOptions{
			DiscardUnknown: true,
		},
	})

	grpcMux := runtime.NewServeMux(jsonOption)

	// Register individual service handlers
	err = pb.RegisterAuthServiceHandlerServer(ctx, grpcMux, server.AuthService())
	if err != nil {
		log.Fatal().Err(err).Msg("cannot register auth service handler")
	}

	err = pb.RegisterUserServiceHandlerServer(ctx, grpcMux, server.UserService())
	if err != nil {
		log.Fatal().Err(err).Msg("cannot register user service handler")
	}

	mux := http.NewServeMux()
	mux.Handle("/", grpcMux)

	statikFS, err := fs.New()
	if err != nil {
		log.Fatal().Err(err).Msg("cannot create statik fs")
	}

	swaggerHandler := http.StripPrefix("/swagger/", http.FileServer(statikFS))
	mux.Handle("/swagger/", swaggerHandler)

	c := cors.New(cors.Options{
		AllowedOrigins: config.AllowedOrigins,
		AllowedMethods: []string{
			http.MethodHead,
			http.MethodOptions,
			http.MethodGet,
			http.MethodPost,
			http.MethodPut,
			http.MethodPatch,
			http.MethodDelete,
		},
		AllowedHeaders: []string{
			"Content-Type",
			"Authorization",
		},
		AllowCredentials: true,
	})
	handler := c.Handler(gapi.HttpLogger(mux))

	httpServer := &http.Server{
		Handler: handler,
		Addr:    config.HTTPServerAddress,
	}

	waitGroup.Go(func() error {
		log.Info().Msgf("start HTTP gateway server at %s", httpServer.Addr)
		err = httpServer.ListenAndServe()
		if err != nil {
			if errors.Is(err, http.ErrServerClosed) {
				return nil
			}
			log.Error().Err(err).Msg("HTTP gateway server failed to serve")
			return err
		}
		return nil
	})

	waitGroup.Go(func() error {
		<-ctx.Done()
		log.Info().Msg("graceful shutdown HTTP gateway server")

		err := httpServer.Shutdown(context.Background())
		if err != nil {
			log.Error().Err(err).Msg("failed to shutdown HTTP gateway server")
			return err
		}

		log.Info().Msg("HTTP gateway server is stopped")
		return nil
	})
}
