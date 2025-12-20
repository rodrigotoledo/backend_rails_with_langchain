.PHONY: help setup start stop restart logs shell db-shell validate-env clean build

# Default target
help:
	@echo "Available commands:"
	@echo "  make setup          - Initial setup (copy .env, install dependencies)"
	@echo "  make start          - Start all Docker containers"
	@echo "  make stop           - Stop all Docker containers"
	@echo "  make restart        - Restart all Docker containers"
	@echo "  make logs           - View logs from all containers"
	@echo "  make logs-app       - View logs from app container only"
	@echo "  make logs-db        - View logs from database container only"
	@echo "  make shell          - Open shell in app container"
	@echo "  make db-shell       - Open PostgreSQL shell"
	@echo "  make validate-env   - Validate environment variables"
	@echo "  make clean          - Remove containers and volumes"
	@echo "  make build          - Rebuild Docker images"
	@echo "  make db-create      - Create database"
	@echo "  make db-migrate     - Run database migrations"
	@echo "  make db-seed        - Seed database"
	@echo "  make db-reset       - Reset database (drop, create, migrate, seed)"
	@echo "  make test           - Run tests"
	@echo "  make console        - Open Rails console"

# Initial setup
setup:
	@if [ ! -f .env ]; then \
		echo "Creating .env file from .env.example..."; \
		cp .env.example .env; \
		echo "✅ .env file created. Please update it with your values."; \
	else \
		echo "⚠️  .env file already exists."; \
	fi
	@echo "Installing dependencies..."
	@docker-compose build

# Start containers
start:
	@echo "Starting Docker containers..."
	@docker-compose up -d
	@echo "✅ Containers started. App available at http://localhost:8000"

# Stop containers
stop:
	@echo "Stopping Docker containers..."
	@docker-compose down

# Restart containers
restart: stop start

# View logs
logs:
	@docker-compose logs -f

logs-app:
	@docker-compose logs -f app

logs-db:
	@docker-compose logs -f db_postgresql

# Open shell in app container
shell:
	@docker-compose exec app /bin/bash

# Open PostgreSQL shell
db-shell:
	@docker-compose exec db_postgresql psql -U postgres -d langchain_searcher_development

# Validate environment variables
validate-env:
	@if [ -f .env ]; then \
		echo "Checking .env file..."; \
		./bin/validate-env; \
	else \
		echo "❌ .env file not found. Run 'make setup' first."; \
		exit 1; \
	fi

# Clean up containers and volumes
clean:
	@echo "⚠️  This will remove all containers and volumes. Press Ctrl+C to cancel."
	@sleep 3
	@docker-compose down -v
	@echo "✅ Cleanup complete"

# Rebuild images
build:
	@echo "Rebuilding Docker images..."
	@docker-compose build --no-cache

# Database commands
db-create:
	@docker-compose exec app bin/rails db:create

db-migrate:
	@docker-compose exec app bin/rails db:migrate

db-seed:
	@docker-compose exec app bin/rails db:seed

db-reset:
	@docker-compose exec app bin/rails db:reset

# Run tests
test:
	@docker-compose exec app bin/rails test

# Open Rails console
console:
	@docker-compose exec app bin/rails console

# Install gems
bundle:
	@docker-compose exec app bundle install

# Run rubocop
rubocop:
	@docker-compose exec app bin/rubocop

# Fix rubocop issues
rubocop-fix:
	@docker-compose exec app bin/rubocop -A
