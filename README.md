# Rails Backend with LangChain & Gemini AI

Ruby on Rails API application integrated with LangChain and Google Gemini for AI-powered features, using PostgreSQL with pgvector for vector storage.

## 🚀 Quick Start

### Prerequisites

- Docker & Docker Compose
- Git
- (Optional) Make for easier commands

### Initial Setup

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd backend_rails_with_langchain
   ```

2. **Setup environment variables**

   ```bash
   # Using Make (recommended)
   make setup

   # Or manually
   cp .env.example .env
   ```

3. **Configure your API keys**

   Edit `.env` and add your Google Gemini API key:

   ```env
   GEMINI_API_KEY=your_actual_api_key_here
   ```

   Get your API key at: [Google AI Studio](https://makersuite.google.com/app/apikey)

4. **Configure VSCode (Optional but Recommended)**

   ```bash
   # Copy VSCode settings template
   cp -r .vscode.example .vscode
   ```

   This will configure VSCode to use RuboCop inside Docker automatically.
   See [.vscode.example/README.md](.vscode.example/README.md) for details.

5. **Start the application**

   ```bash
   # Using Make
   make start

   # Or using Docker Compose directly
   docker-compose up -d
   ```

6. **Access the application**

   The API will be available at: `http://localhost:8000`## 📚 Documentation

- **[Environment Variables Guide](docs/ENVIRONMENT_VARIABLES.md)** - Complete reference for all environment variables

## 🛠️ Available Commands

### Using Make (Recommended)

```bash
make help              # Show all available commands
make setup             # Initial setup
make start             # Start containers
make stop              # Stop containers
make restart           # Restart containers
make logs              # View all logs
make logs-app          # View app logs only
make shell             # Open shell in app container
make console           # Open Rails console
make db-migrate        # Run migrations
make db-seed           # Seed database
make db-reset          # Reset database
make test              # Run tests
make validate-env      # Validate environment variables
```

### Using Docker Compose Directly

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f app

# Run Rails commands
docker-compose exec app rails console
docker-compose exec app rails db:migrate

# Run tests
docker-compose exec app rails test

# Open shell
docker-compose exec app bash
```

## 🗄️ Database Management

### Migrations

```bash
# Using Make
make db-migrate

# Or using Docker Compose
docker-compose exec app rails db:migrate
```

### Seeding

```bash
# Using Make
make db-seed

# Or using Docker Compose
docker-compose exec app rails db:seed
```

### Reset Database

```bash
# Using Make
make db-reset

# Or using Docker Compose
docker-compose exec app rails db:reset
```

### PostgreSQL Shell

```bash
# Using Make
make db-shell

# Or using Docker Compose
docker-compose exec db_postgresql psql -U postgres -d langchain_searcher_development
```

## 🧪 Testing

```bash
# Using Make
make test

# Or using Docker Compose
docker-compose exec app rails test

# For specific tests
docker-compose exec app rails test test/models/client_test.rb
```

## 🏗️ Development

### Generate Rails Resources

```bash
docker-compose exec app rails g scaffold Post title:string content:text
docker-compose exec app rails g model Comment post:references content:text
docker-compose exec app rails g controller api/v1/posts
```

### Rails Console

```bash
# Using Make
make console

# Or using Docker Compose
docker-compose exec app rails console
```

### Run Rubocop

```bash
# Using Make
make rubocop

# Fix issues automatically
make rubocop-fix

# Or using Docker Compose
docker-compose exec app bin/rubocop
docker-compose exec app bin/rubocop -A
```

## 📦 Features

- **AI Integration**: Google Gemini API for AI-powered features
- **Vector Search**: PostgreSQL with pgvector extension
- **LangChain**: Integration with LangChain for advanced AI workflows
- **File Uploads**: Active Storage for file management
- **Background Jobs**: Solid Queue for background processing
- **Caching**: Solid Cache for performance optimization

## 🐳 Docker Management

### Clean All Docker Resources

```bash
# Using Make
make clean

# Or manually
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)
docker rmi -f $(docker images -aq)
docker system prune -a --volumes -f
docker network rm $(docker network ls -q)
```

### Rebuild Images

```bash
# Using Make
make build

# Or using Docker Compose
docker-compose build --no-cache
```

### Force Database Recreation

```bash
FORCE_DB_CREATE=true FORCE_DB_SEED=true docker-compose up --build
```

## ⚙️ Environment Configuration

### Required Variables

- `GEMINI_API_KEY` - Your Google Gemini API key (required)
- `POSTGRES_PASSWORD` - Database password

### Optional Variables (with defaults)

- `RAILS_ENV` - Rails environment (default: `development`)
- `APPLICATION_NAME` - App name (default: `langchain_searcher`)
- `DB_HOST` - Database host (default: `db_postgresql`)
- `DB_PORT` - Database port (default: `5432`)
- `PORT` - Server port (default: `8000`)

See [Environment Variables Documentation](docs/ENVIRONMENT_VARIABLES.md) for complete reference.

### Validate Environment

```bash
# Using Make
make validate-env

# Or directly
./bin/validate-env
```

## 🚨 Troubleshooting

### Port Already in Use

If port 8000 is already in use, change it in `.env`:

```env
PORT=8001
```

Then restart: `make restart`

### Database Connection Issues

1. Check if PostgreSQL is running: `docker-compose ps`
2. Verify credentials in `.env` match `config/database.yml`
3. Try resetting the database: `make db-reset`

### Missing API Key Error

Ensure `GEMINI_API_KEY` is set in `.env` and restart the application.

## 📋 Project Structure

```plaintext
.
├── app/
│   ├── controllers/     # API controllers
│   ├── models/          # ActiveRecord models
│   ├── services/        # Business logic services
│   └── jobs/            # Background jobs
├── config/              # Application configuration
├── db/                  # Database migrations and seeds
├── docs/                # Documentation
├── bin/                 # Executable scripts
├── .env                 # Environment variables (git-ignored)
├── .env.example         # Environment variables template
├── docker-compose.yml   # Docker services configuration
├── Dockerfile           # Docker image definition
├── Gemfile              # Ruby dependencies
└── Makefile            # Make commands
```

## 🤝 Contributing

1. Create a feature branch
2. Make your changes
3. Run tests: `make test`
4. Run linter: `make rubocop`
5. Submit a pull request

## 📝 License

This project is licensed under the MIT License.

## 🔗 Resources

- [Ruby on Rails Guides](https://guides.rubyonrails.org/)
- [LangChain Documentation](https://ruby.langchain.io/)
- [Google Gemini API](https://ai.google.dev/)
- [pgvector Documentation](https://github.com/pgvector/pgvector)
- [Docker Documentation](https://docs.docker.com/)

