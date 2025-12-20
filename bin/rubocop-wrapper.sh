#!/bin/bash
# RuboCop wrapper script for VSCode
# This script runs RuboCop inside the Docker container

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Check if running inside container
if [ -f /.dockerenv ]; then
    # Already inside container, run rubocop directly
    exec bundle exec rubocop "$@"
else
    # Outside container, run via docker-compose
    cd "$PROJECT_ROOT"

    # Check if container is running
    if docker-compose ps app | grep -q "Up"; then
        # Container is running, use exec
        docker-compose exec -T app bundle exec rubocop "$@"
    else
        # Container not running, use run
        docker-compose run --rm -T app bundle exec rubocop "$@"
    fi
fi
