package lifespan

import (
	"github.com/golang-migrate/migrate"
	"github.com/rs/zerolog/log"
)

func RunDBMigration(migrationURL string, dbSource string) {
	migration, err := migrate.New(migrationURL, dbSource)
	if err != nil {
		log.Fatal().Err(err).Msg("cannot create new migrate instance")
	}

	version, dirty, err := migration.Version()
	if err != nil && err != migrate.ErrNilVersion {
		log.Fatal().Err(err).Msg("failed to get migration version")
	}

	if !dirty && err == nil {
		log.Info().Msgf("current migration version: %d", version)
		return
	}

	if err = migration.Up(); err != nil && err != migrate.ErrNoChange {
		log.Fatal().Err(err).Msg("failed to run migrate up")
	}

	log.Info().Msg("db migrated successfully")
}
