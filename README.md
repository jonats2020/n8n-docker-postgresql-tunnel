# n8n Docker Setup

This repository contains a Docker-based setup for running n8n with PostgreSQL database persistence.

## Installation Guide

### Installing Docker

#### macOS

1. Install Homebrew (if not already installed):

   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. Install Docker Desktop:

   ```bash
   brew install --cask docker
   ```

3. Start Docker Desktop:
   - Open Docker Desktop from your Applications folder
   - Wait for Docker to complete its initialization

#### Ubuntu/Debian

1. Update package index and install prerequisites:

   ```bash
   sudo apt-get update
   sudo apt-get install -y ca-certificates curl gnupg lsb-release
   ```

2. Add Docker's official GPG key:

   ```bash
   sudo mkdir -p /etc/apt/keyrings
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
   ```

3. Set up Docker repository:

   ```bash
   echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
   ```

4. Install Docker:

   ```bash
   sudo apt-get update
   sudo apt-get install -y docker-ce docker-ce-cli containerd.io
   ```

5. Add your user to the docker group:
   ```bash
   sudo usermod -aG docker $USER
   newgrp docker
   ```

#### Windows

1. Download Docker Desktop for Windows from the [official website](https://www.docker.com/products/docker-desktop)
2. Run the installer
3. Follow the installation wizard
4. Start Docker Desktop from the Start menu
5. Wait for Docker to complete its initialization

### Verifying Docker Installation

Run this command to verify Docker is installed correctly:

```bash
docker --version
docker run hello-world
```

## Project Setup

1. Clone this repository:

   ```bash
   git clone <repository-url>
   cd n8n
   ```

2. Copy the example environment file and set your credentials:

   ```bash
   cp .env.example .env
   ```

3. Edit the `.env` file with your secure credentials:

   ```env
   POSTGRES_USER=your_username
   POSTGRES_PASSWORD=your_secure_password
   POSTGRES_DB=your_database_name
   ```

4. Make the script executable:
   ```bash
   chmod +x run_docker.sh
   ```

## Prerequisites

- Docker installed on your system (see Installation Guide above)
- Basic understanding of terminal commands
- Minimum system requirements:
  - 2GB RAM
  - 2 CPU cores
  - 10GB free disk space

## Container Information

The setup consists of two Docker containers:

1. **PostgreSQL Container**

   - Name: `postgres`
   - Version: PostgreSQL 15 (Alpine)
   - Port: 5432
   - Database: Configured via environment variables
   - Data Location: Docker volume `postgres_data`

2. **n8n Container**
   - Name: `n8n`
   - Version: Latest
   - Port: 5678
   - Web Interface: http://localhost:5678
   - Data Location: Docker volume `n8n_data`
   - Timezone: Asia/Manila

## Running the Application

Start both containers:

```bash
./run_docker.sh
```

## Managing the Containers

### Stopping the Containers

```bash
docker stop n8n postgres
```

### Starting Existing Containers

```bash
docker start postgres
sleep 10  # Wait for PostgreSQL to be ready
docker start n8n
```

### Viewing Logs

For n8n logs:

```bash
docker logs n8n
```

For PostgreSQL logs:

```bash
docker logs postgres
```

Follow logs in real-time by adding `-f`:

```bash
docker logs -f n8n
```

### Checking Container Status

```bash
docker ps  # Shows running containers
docker ps -a  # Shows all containers, including stopped ones
```

## Data Persistence

The setup uses Docker volumes for data persistence:

- `n8n_data`: Stores n8n workflows and credentials
- `postgres_data`: Stores PostgreSQL database data

These volumes ensure your data persists even after container restarts.

## Security Notes

1. Never commit the `.env` file to version control
2. Use strong, unique passwords in your `.env` file
3. The `.env.example` file is safe to commit as it contains no real credentials
4. Consider using a secrets management solution for production deployments

## Troubleshooting

1. If PostgreSQL fails to start:

   ```bash
   docker logs postgres  # Check PostgreSQL logs for errors
   ```

2. If n8n can't connect to PostgreSQL:

   ```bash
   # Restart the containers in correct order
   docker stop n8n postgres
   docker start postgres
   sleep 10
   docker start n8n
   ```

3. To reset everything and start fresh:

   ```bash
   # Stop and remove containers
   docker stop n8n postgres
   docker rm n8n postgres

   # Remove volumes (WARNING: This will delete all data!)
   docker volume rm n8n_data postgres_data

   # Start fresh
   ./run_docker.sh
   ```

## Important Notes

- The n8n web interface is accessible at `http://localhost:5678`
- All times in n8n are set to Philippines timezone (Asia/Manila)
- Database credentials are managed through environment variables
- Both containers are configured to restart automatically unless explicitly stopped

## Terminal Commands Quick Reference

```bash
# Start everything
./run_docker.sh

# Stop everything
docker stop n8n postgres

# View container status
docker ps

# View logs
docker logs n8n
docker logs postgres

# Restart individual containers
docker restart postgres
docker restart n8n

# Remove containers (data persists in volumes)
docker rm n8n postgres

# Remove volumes (WARNING: Deletes all data!)
docker volume rm n8n_data postgres_data
```
