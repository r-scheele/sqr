
# ✅ Development Roadmap

## 🧰 Environment Setup
- [ ] Install Go  
- [ ] Install and configure VSCode  
- [ ] Install Docker    
- [ ] Install `make`  
- [ ] Install `sqlc`

## 🗄️ Working with Database (PostgreSQL)
- [x] Design DB schema and generate SQL with dbdiagram.io  [Link](https://dbdiagram.io/d/sqr-684e830f3cc77757c8ecac1b)
- [x] Use Docker + Postgres + TablePlus to create schema  
- [x] Write & run DB migrations in Golang  
- [ ] Generate CRUD code & compare db/sql, gorm, sqlx, sqlc  
- [ ] Write unit tests for CRUD with random data  
- [ ] Implement DB transaction cleanly  
- [ ] Handle transaction locks & deadlocks  
- [ ] Avoid deadlocks via query ordering  
- [ ] Understand transaction isolation & read phenomena  
- [ ] Setup GitHub Actions for automated DB tests  

## 🌐 Building RESTful HTTP JSON API (Gin)
- [ ] Implement RESTful API with Gin  
- [ ] Load config with Viper (file + env)  
- [ ] Mock DB for API tests, achieve 100% coverage  
- [ ] Transfer money API with custom validation  
- [ ] Add users table with constraints in PostgreSQL  
- [ ] Handle DB errors in Go  
- [ ] Hash passwords securely with Bcrypt  
- [ ] Write stronger tests using custom `gomock` matcher  
- [ ] JWT vs PASETO for authentication  
- [ ] Create/verify JWT & PASETO tokens  
- [ ] Implement login API returning token  
- [ ] Implement auth middleware + authorization rules  

## ☁️ Deployment (Kubernetes + AWS)
- [ ] Build minimal Docker image (multi-stage)  
- [ ] Connect containers using Docker network  
- [ ] Write `docker-compose` with `wait-for.sh`  
- [ ] Create free-tier AWS account  
- [ ] Auto build/push Docker image to ECR with GitHub Actions  
- [ ] Create production DB on AWS RDS  
- [ ] Store/retrieve secrets with AWS Secrets Manager  
- [ ] Understand Kubernetes architecture, create EKS cluster  
- [ ] Connect to EKS cluster using `kubectl` & `k9s`  
- [ ] Deploy web app to EKS cluster  
- [ ] Register domain and setup DNS (Route53)  
- [ ] Use Ingress to route traffic to services  
- [ ] Setup TLS certificates with Let's Encrypt  
- [ ] Auto deploy to Kubernetes with GitHub Actions  

## 🚀 Advanced Backend Topics (gRPC + Sessions)
- [ ] Manage user sessions with refresh tokens  
- [ ] Generate DB docs & SQL dumps from DBML  
- [ ] Intro to gRPC  
- [ ] Define gRPC APIs, generate code with Protobuf  
- [ ] Run gRPC server & call APIs  
- [ ] Implement create/login user via gRPC  
- [ ] Use gRPC Gateway to serve HTTP + gRPC  
- [ ] Extract info from gRPC metadata  
- [ ] Auto generate & serve Swagger docs  
- [ ] Embed static frontend files in Go binary  
- [ ] Validate gRPC params & respond clearly  
- [ ] Run DB migrations in Go code  
- [ ] Partial update DB with SQLC nullable params  
- [ ] gRPC update API with optional params  
- [ ] Add auth to protect gRPC APIs  
- [ ] Structured logs for gRPC APIs  
- [ ] Write HTTP logger middleware  

## ⚙️ Async Processing (Asynq + Redis)
- [ ] Background worker with Asynq + Redis  
- [ ] Integrate async worker to server  
- [ ] Send async tasks within DB transactions  
- [ ] Handle Asynq errors & log  
- [ ] Add delay to async tasks (where useful)  
- [ ] Send emails using Gmail in Go  
- [ ] Skip tests in Go, use test flags in VSCode  
- [ ] Design DB + send email for verification  
- [ ] Implement email verification API  
- [ ] Unit test gRPC API with mock DB + Redis  
- [ ] Test gRPC APIs with authentication  

## 🔐 Stability & Security
- [ ] Configure `sqlc` v2 for Go + PostgreSQL  
- [ ] Switch DB driver from `lib/pq` to `pgx`  
- [ ] Handle DB errors using PGX  
- [ ] Docker compose: volume + port mapping  
- [ ] Install & use binary Go packages  
- [ ] Implement Role-Based Access Control (RBAC)  
- [ ] Grant EKS access to Postgres & Redis via SG  
- [ ] Deploy gRPC + HTTP servers to EKS  
- [ ] Optimize AWS usage (save money!)  
- [ ] Graceful shutdown of servers + workers  
- [ ] Go 1.22 loop fix explanation  
- [ ] Setup CORS policy (Go + VueJS)  
- [ ] Upgrade JWT package to v5  
