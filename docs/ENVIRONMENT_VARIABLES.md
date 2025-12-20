# Environment Variables Documentation

This document describes all environment variables used in the application.

## Quick Start

1. Copy the example file:
   ```bash
   cp .env.example .env
   ```

2. Update the `.env` file with your specific values, especially:
   - `GEMINI_API_KEY` - Your Google Gemini API key
   - `GOOGLE_API_KEY` - Your Google API key (if different)
   - Database passwords (if deploying to production)

## Configuration Categories

### Rails Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `RAILS_ENV` | `development` | Rails environment (development, test, production) |
| `RAILS_MAX_THREADS` | `5` | Maximum number of threads for Puma server |

### Application Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `APPLICATION_NAME` | `langchain_searcher` | Application name used for database naming and container naming |

### PostgreSQL Database Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `DB_HOST` | `db_postgresql` | Database host (use `localhost` for local dev, `db_postgresql` for Docker) |
| `DB_PORT` | `5432` | PostgreSQL port |
| `POSTGRES_USER` | `postgres` | PostgreSQL superuser username |
| `POSTGRES_PASSWORD` | `postgres` | PostgreSQL superuser password |
| `DB_USERNAME` | `postgres` | Database connection username |
| `DB_PASSWORD` | `postgres` | Database connection password |
| `DATABASE_URL` | - | Optional full database URL (overrides individual settings) |

**Note:** In development, `DB_USERNAME`/`DB_PASSWORD` and `POSTGRES_USER`/`POSTGRES_PASSWORD` are typically the same.

### Server Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `8000` | Port where Rails server listens |
| `BINDING` | `0.0.0.0` | Server binding address (`0.0.0.0` for Docker, `localhost` for local) |

### Docker Development Options

| Variable | Default | Description |
|----------|---------|-------------|
| `FORCE_DB_CREATE` | `false` | Force database creation on container startup |
| `FORCE_DB_SEED` | `false` | Force database seeding on container startup |

### API Keys & External Services

| Variable | Default | Description |
|----------|---------|-------------|
| `GEMINI_API_KEY` | - | **Required** - Google Gemini API key for AI features. Get yours at [Google AI Studio](https://makersuite.google.com/app/apikey) |
| `GOOGLE_API_KEY` | - | Google API key (if different from Gemini key) |

### Optional Services

| Variable | Default | Description |
|----------|---------|-------------|
| `REDIS_URL` | - | Redis connection URL (format: `redis://redis:6379/0`) |
| `SECRET_KEY_BASE` | - | Secret key for production (generate with `rails secret`) |

## Environment-Specific Configuration

### Development (Local without Docker)

```env
RAILS_ENV=development
DB_HOST=localhost
DB_PORT=5432
BINDING=localhost
PORT=3000
```

### Development (Docker)

```env
RAILS_ENV=development
DB_HOST=db_postgresql
DB_PORT=5432
BINDING=0.0.0.0
PORT=8000
```

### Production

```env
RAILS_ENV=production
RAILS_LOG_TO_STDOUT=true
RAILS_SERVE_STATIC_FILES=true
SECRET_KEY_BASE=<generate-with-rails-secret>
DB_HOST=<your-production-db-host>
POSTGRES_PASSWORD=<strong-password>
WEB_CONCURRENCY=2
```

## Generating Secrets

For production deployments, generate a secure `SECRET_KEY_BASE`:

```bash
rails secret
```

Copy the output to your production `.env` file.

## Docker Compose Integration

All variables in `.env` are automatically loaded by Docker Compose. The `docker-compose.yml` file uses these variables with sensible defaults:

- `${VARIABLE_NAME:-default_value}` syntax provides fallback values
- Container names include `APPLICATION_NAME` for easy identification
- Health checks ensure services are ready before dependencies start

## Security Best Practices

1. **Never commit `.env` to version control** - it's in `.gitignore`
2. **Keep `.env.example` updated** - but with placeholder values only
3. **Use strong passwords** in production
4. **Rotate API keys** regularly
5. **Use environment-specific credentials** - don't reuse dev credentials in production
6. **Store production secrets** in a secure vault (AWS Secrets Manager, HashiCorp Vault, etc.)

## Troubleshooting

### Database Connection Issues

If you can't connect to the database:

1. Verify `DB_HOST` matches your setup (`localhost` vs `db_postgresql`)
2. Ensure PostgreSQL is running: `docker-compose ps`
3. Check credentials match in both `.env` and `config/database.yml`

### Port Conflicts

If port `8000` is already in use:

1. Change `PORT` in `.env` to an available port (e.g., `8001`)
2. Restart containers: `docker-compose down && docker-compose up`

### Missing API Keys

If you see Gemini-related errors:

1. Ensure `GEMINI_API_KEY` is set in `.env`
2. Verify the key is valid at [Google AI Studio](https://makersuite.google.com/)
3. Restart the application to load new environment variables

## Additional Resources

- [Rails Environment Variables Guide](https://guides.rubyonrails.org/configuring.html)
- [Docker Compose Environment Variables](https://docs.docker.com/compose/environment-variables/)
- [PostgreSQL Docker Hub](https://hub.docker.com/_/postgres)
- [pgvector Documentation](https://github.com/pgvector/pgvector)
