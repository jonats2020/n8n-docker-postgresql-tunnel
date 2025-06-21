# n8n Workflow Automation Setup

![n8n Banner](https://img.5xcamp.us/i/eacda81d-496e-4d9c-ac0c-242081ce79d9.png)

This repository contains the setup configuration for deploying n8n (workflow automation tool) as a subdomain on a Namecheap domain using a Hostinger VPS.

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
- **Plan**: KVM 1 (₱549/month)
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

- `secure-setup.sh` - Main setup script for VPS configuration
- `README.md` - This documentation

## Installation Process

1. **VPS Setup**: Fresh Ubuntu 24.04 installation on Hostinger VPS
2. **Domain Configuration**: DNS A record pointing to VPS IP
3. **Security**: UFW firewall configuration
4. **Dependencies**: Node.js 18.x, PostgreSQL 16, certbot
5. **SSL**: Let's Encrypt certificate generation
6. **Database**: PostgreSQL user and database creation
7. **n8n**: Global npm installation and systemd service setup

## Key Features

- **Resource Efficient**: No Docker overhead, direct Node.js deployment
- **Secure**: HTTPS with Let's Encrypt certificates, UFW firewall
- **Reliable**: PostgreSQL for data persistence, systemd for service management
- **Auto-Renewal**: Certbot handles SSL certificate renewal automatically
- **Production Ready**: Proper logging, restart policies, and error handling

## Access

The n8n instance is accessible at: https://n8n.website.com

## Maintenance

- **SSL Renewal**: Automatic via certbot
- **Service Management**: `systemctl {start|stop|restart|status} n8n`
- **Database**: Standard PostgreSQL maintenance practices
- **Updates**: Update n8n via `npm update -g n8n` and restart service

## Security Considerations

- UFW firewall configured to allow only necessary ports
- PostgreSQL configured with dedicated user and database
- SSL/TLS encryption for all connections
- Regular security updates via apt

This setup provides a cost-effective, efficient solution for running n8n workflows with proper security and reliability measures in place.
