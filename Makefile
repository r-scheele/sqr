DB_URL=postgresql://root:secret@localhost:5432/sqr?sslmode=disable

network:
	docker network create sqr-network

postgres:
	docker run --name postgres --network sqr-network -p 5432:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=secret -d postgres:14-alpine

mysql:
	docker run --name mysql8 -p 3306:3306  -e MYSQL_ROOT_PASSWORD=secret -d mysql:8

createdb:
	docker exec -it postgres createdb --username=root --owner=root sqr

dropdb:
	docker exec -it postgres dropdb sqr

migrateup:
	migrate -path internal/db/migration -database "$(DB_URL)" -verbose up

migrateup1:
	migrate -path internal/db/migration -database "$(DB_URL)" -verbose up 1

migratedown:
	migrate -path internal/db/migration -database "$(DB_URL)" -verbose down

migratedown1:
	migrate -path internal/db/migration -database "$(DB_URL)" -verbose down 1

new_migration:
	migrate create -ext sql -dir internal/db/migration -seq $(name)

db_docs:
	dbdocs build doc/db.dbml

db_schema:
	dbml2sql --postgres -o doc/schema.sql doc/db.dbml

sqlc:
	sqlc generate

test:
	go test -v -cover -short ./...

server:
	go run main.go

mock:
	@command -v mockgen >/dev/null 2>&1 || { echo "mockgen is not installed. Run: go install github.com/golang/mock/mockgen@latest"; exit 1; }
	mockgen -package mockdb -destination internal/db/mock/store.go github.com/r-scheele/sqr/internal/db/sqlc Store
	mockgen -package mockwk -destination internal/worker/mock/distributor.go github.com/r-scheele/sqr/internal/worker TaskDistributor

proto:
	rm -f internal/pb/*.go
	rm -f doc/swagger/*.swagger.json
	protoc --proto_path=internal/proto --go_out=internal/pb --go_opt=paths=source_relative \
	--go-grpc_out=internal/pb --go-grpc_opt=paths=source_relative \
	--grpc-gateway_out=internal/pb --grpc-gateway_opt=paths=source_relative \
	--openapiv2_out=doc/swagger --openapiv2_opt=allow_merge=true,merge_file_name=sqr \
	internal/proto/*.proto
	statik -src=./doc/swagger -dest=./doc

evans:
	evans --host localhost --port 9090 -r repl

redis:
	docker run --name redis -p 6379:6379 -d redis:7-alpine

.PHONY: network postgres createdb dropdb migrateup migratedown migrateup1 migratedown1 new_migration db_docs db_schema sqlc test server mock proto evans redis
