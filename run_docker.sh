#!/bin/bash

# Load environment variables
if [ -f .env ]; then
  export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
else
  echo "Warning: .env file not found. Using default values."
  export POSTGRES_USER=n8n
  export POSTGRES_PASSWORD=n8n
  export POSTGRES_DB=n8n
fi

# Stop and remove existing containers
docker stop n8n postgres || true
docker rm n8n postgres || true

# Create volumes if they don't exist
docker volume create n8n_data
docker volume create postgres_data

# Start PostgreSQL container
docker run -d \
  --name postgres \
  -e POSTGRES_USER="${POSTGRES_USER}" \
  -e POSTGRES_PASSWORD="${POSTGRES_PASSWORD}" \
  -e POSTGRES_DB="${POSTGRES_DB}" \
  -e POSTGRES_NON_ROOT_USER="${POSTGRES_USER}" \
  -e POSTGRES_NON_ROOT_PASSWORD="${POSTGRES_PASSWORD}" \
  -v postgres_data:/var/lib/postgresql/data \
  -p 5432:5432 \
  postgres:15-alpine

# Wait for PostgreSQL to be ready
sleep 10

# Start n8n container
docker run -d \
 --name n8n \
 --link postgres:postgres \
 -p 5678:5678 \
 -e DB_TYPE=postgresdb \
 -e DB_POSTGRESDB_DATABASE="${POSTGRES_DB}" \
 -e DB_POSTGRESDB_HOST=postgres \
 -e DB_POSTGRESDB_PORT=5432 \
 -e DB_POSTGRESDB_USER="${POSTGRES_USER}" \
 -e DB_POSTGRESDB_SCHEMA=public \
 -e DB_POSTGRESDB_PASSWORD="${POSTGRES_PASSWORD}" \
 -e GENERIC_TIMEZONE="Asia/Manila" \
 -e TZ="Asia/Manila" \
 -e NODE_ENV=production \
 -e N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=false \
 -v n8n_data:/home/node/.n8n \
 docker.n8n.io/n8nio/n8n \
 start --tunnel

# Show the logs
echo "Waiting for n8n to start..."
sleep 5
docker logs n8n