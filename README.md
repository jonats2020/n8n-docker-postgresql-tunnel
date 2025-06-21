# Budget DIY n8n Workflow Setup for ~$7/month Total Hosting Costs*

![n8n Banner](https://img.5xcamp.us/i/eacda81d-496e-4d9c-ac0c-242081ce79d9.png)

This repository contains the setup configuration for deploying n8n (workflow automation tool) as a subdomain on a Namecheap domain using a Hostinger VPS.

## 💰 Cost Breakdown (2025 Pricing)

**Total Monthly Cost: ~$7/month***

### Hostinger KVM 1 VPS
- **Promotional**: ~$5-9/month (first 24 months)
- **Regular**: ~$9-10/month (renewal rate)
- Specifications: 1 vCPU, 4GB RAM, 50GB NVMe, 4TB bandwidth

### Namecheap Domain (.com)
- **First Year**: $6.49 (~$0.54/month)
- **Renewal**: $16.88/year (~$1.41/month)

**Pricing varies significantly based on promotional offers, billing cycles, and renewal rates. The $7/month estimate assumes promotional pricing. Always check current provider websites for exact pricing.*

## Overview

This implementation provides a production-ready n8n instance with:
- **Domain**: n8n.website.com (subdomain of Namecheap domain)
- **Hosting**: Hostinger VPS
- **SSL**: Let's Encrypt certificates for HTTPS
- **Database**: PostgreSQL for data persistence
- **Architecture**: Direct Node.js deployment (no Docker overhead)

## Architecture

- **n8n**: Running directly on Node.js as a systemd service
- **Database**: PostgreSQL 16 running locally
- **SSL/TLS**: Let's Encrypt certificates managed by certbot
- **Port**: 443 (HTTPS direct, no reverse proxy)
- **Timezone**: Asia/Manila

## Setup Components

### 1. VPS Configuration
- **Provider**: Hostinger
- **Plan**: KVM 1 (~$5-10/month depending on promotion)
- **OS**: Ubuntu 24.04 LTS
- **Specifications**:
  - 1 vCPU
  - 4GB RAM
  - 50GB NVMe Storage
  - 4TB Bandwidth
- **Firewall**: UFW configured for SSH, HTTP, HTTPS

### 2. Domain Configuration
- **Registrar**: Namecheap
- **Domain**: website.com
- **Subdomain**: n8n.website.com
- **DNS**: A record pointing to VPS IP

### 3. n8n Configuration
- **Version**: Latest stable (1.97.1+)
- **Database**: PostgreSQL with dedicated user and database
- **SSL**: Direct HTTPS handling (no reverse proxy)
- **Data Directory**: `/root/.n8n/`
- **Service**: Systemd service with auto-restart

## Files

### `secure-setup.sh` - All-in-One Setup Script
This is the main installation script that handles the complete setup process automatically. The script reads configuration from a `.env` file, making it customizable for different domains and settings.

**System Setup:**
- Updates Ubuntu packages and installs security updates
- Configures UFW firewall (allows SSH, HTTP, HTTPS)
- Installs essential packages (curl, wget, git, certbot)

**Node.js Installation:**
- Adds NodeSource repository for Node.js 18.x LTS
- Installs Node.js and npm

**PostgreSQL Setup:**
- Installs PostgreSQL 16 and creates dedicated database
- Creates n8n user with proper permissions
- Handles existing database cleanup if needed

**SSL Certificate:**
- Obtains Let's Encrypt SSL certificate for your domain
- Configures automatic renewal

**n8n Installation:**
- Installs n8n globally via npm
- Creates systemd service for automatic startup
- Configures environment variables for production use
- Sets up proper SSL and database connections

**Service Management:**
- Enables and starts all services (PostgreSQL, n8n)
- Configures automatic restart on failure

### `env.example` - Configuration Template
Contains all the configuration variables needed for the setup:
- `DOMAIN` - Your main domain (e.g., website.com)
- `SUBDOMAIN` - Subdomain for n8n (e.g., n8n)
- `SSL_EMAIL` - Email for Let's Encrypt certificates
- `DB_PASSWORD` - Secure password for PostgreSQL database
- `TIMEZONE` - Server timezone (optional, defaults to Asia/Manila)

### `README.md` 
This documentation file explaining the setup and architecture.

## Installation Process

### Step 1: Prepare Configuration
1. Clone this repository to your VPS
2. Copy the configuration template:
   ```bash
   cp env.example .env
   ```
3. Edit `.env` with your actual values:
   ```bash
   nano .env
   ```
   Update:
   - `DOMAIN=yourdomain.com`
   - `SUBDOMAIN=n8n` (or your preferred subdomain)
   - `SSL_EMAIL=your-email@example.com`
   - `DB_PASSWORD=your_secure_password`

### Step 2: DNS Configuration
Set up an A record in your domain's DNS settings:
- **Name**: n8n (or your chosen subdomain)
- **Type**: A
- **Value**: Your VPS IP address

### Step 3: Run Setup Script
Execute the setup script:
```bash
chmod +x secure-setup.sh
./secure-setup.sh
```

The script will:
- Show your configuration and ask for confirmation
- Automatically handle all installation and configuration steps
- Provide status updates throughout the process

## Key Features

- **Resource Efficient**: No Docker overhead, direct Node.js deployment
- **Secure**: HTTPS with Let's Encrypt certificates, UFW firewall
- **Reliable**: PostgreSQL for data persistence, systemd for service management
- **Auto-Renewal**: Certbot handles SSL certificate renewal automatically
- **Production Ready**: Proper logging, restart policies, and error handling
- **Configurable**: Easy setup via environment file
- **Automated**: Single script handles entire installation process

## Access

The n8n instance will be accessible at: https://[subdomain].[domain]

Example: https://n8n.website.com

## Maintenance

- **SSL Renewal**: Automatic via certbot
- **Service Management**: `systemctl {start|stop|restart|status} n8n`
- **Database**: Standard PostgreSQL maintenance practices
- **Updates**: Update n8n via `npm update -g n8n` and restart service
- **Logs**: View logs with `journalctl -u n8n -f`

## Security Considerations

- UFW firewall configured to allow only necessary ports
- PostgreSQL configured with dedicated user and database
- SSL/TLS encryption for all connections
- Regular security updates via apt
- Secure database passwords via environment configuration

This setup provides a cost-effective, efficient solution for running n8n workflows with proper security and reliability measures in place.

## Need Help?

If you need assistance with the setup, customization, or have questions about n8n workflow automation, feel free to reach out for consultation:

📧 **Contact**: hello@natsdevstudio.com

I can help with:
- Custom n8n workflow development
- VPS setup and optimization
- Domain and SSL configuration
- Troubleshooting and maintenance