#!/bin/bash

# Load configuration from .env file
if [ ! -f .env ]; then
    echo "Error: .env file not found!"
    echo "Please copy env.example to .env and configure your settings:"
    echo "cp env.example .env"
    echo "Then edit .env with your domain, email, and other settings."
    exit 1
fi

# Source the .env file
source .env

# Validate required variables
if [ -z "$DOMAIN" ] || [ -z "$SUBDOMAIN" ] || [ -z "$SSL_EMAIL" ] || [ -z "$DB_PASSWORD" ]; then
    echo "Error: Missing required configuration in .env file!"
    echo "Please ensure DOMAIN, SUBDOMAIN, SSL_EMAIL, and DB_PASSWORD are set."
    exit 1
fi

# Set defaults for optional variables
TIMEZONE=${TIMEZONE:-"Asia/Manila"}
FULL_DOMAIN="${SUBDOMAIN}.${DOMAIN}"

echo "Starting n8n setup with the following configuration:"
echo "Domain: $FULL_DOMAIN"
echo "SSL Email: $SSL_EMAIL"
echo "Timezone: $TIMEZONE"
echo "Database Password: [HIDDEN]"
echo ""
read -p "Continue with setup? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Setup cancelled."
    exit 1
fi

# Update system
apt-get update && apt-get upgrade -y

# Install essential packages
apt-get install -y curl wget git ufw certbot nginx postgresql postgresql-contrib

# Configure firewall
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow http
ufw allow https
echo "y" | ufw enable

# Install Node.js 18.x LTS
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

# Configure PostgreSQL - handle existing user/database
echo "Configuring PostgreSQL..."
sudo -u postgres psql -c "DROP DATABASE IF EXISTS n8n;"
sudo -u postgres psql -c "DROP USER IF EXISTS n8n;"
sudo -u postgres psql -c "CREATE USER n8n WITH PASSWORD '$DB_PASSWORD';"
sudo -u postgres psql -c "CREATE DATABASE n8n;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE n8n TO n8n;"
sudo -u postgres psql -c "ALTER USER n8n CREATEDB;"
sudo -u postgres psql -c "ALTER DATABASE n8n OWNER TO n8n;"
sudo -u postgres psql -d n8n -c "GRANT ALL ON SCHEMA public TO n8n;"
echo "PostgreSQL configuration completed."

# Install n8n globally
npm install -g n8n

# Stop nginx temporarily for certbot
systemctl stop nginx

# Get SSL certificate
certbot certonly --standalone -d $FULL_DOMAIN --non-interactive --agree-tos --email $SSL_EMAIL

# Create n8n system service
cat > /etc/systemd/system/n8n.service << EOL
[Unit]
Description=n8n Workflow Automation
After=network.target postgresql.service

[Service]
Type=simple
User=root
Environment=NODE_ENV=production
Environment=N8N_HOST=$FULL_DOMAIN
Environment=N8N_PROTOCOL=https
Environment=N8N_PORT=443
Environment=N8N_SSL_CERT=/etc/letsencrypt/live/$FULL_DOMAIN/fullchain.pem
Environment=N8N_SSL_KEY=/etc/letsencrypt/live/$FULL_DOMAIN/privkey.pem
Environment=DB_TYPE=postgresdb
Environment=DB_POSTGRESDB_HOST=localhost
Environment=DB_POSTGRESDB_PORT=5432
Environment=DB_POSTGRESDB_DATABASE=n8n
Environment=DB_POSTGRESDB_USER=n8n
Environment=DB_POSTGRESDB_PASSWORD=$DB_PASSWORD
Environment=GENERIC_TIMEZONE=$TIMEZONE
Environment=TZ=$TIMEZONE
Environment=N8N_SECURE_COOKIE=true
ExecStart=/usr/bin/n8n start
Restart=always

[Install]
WantedBy=multi-user.target
EOL

# Enable and start services
systemctl daemon-reload
systemctl enable postgresql
systemctl start postgresql
systemctl enable n8n
systemctl start n8n

# Print status
echo "Setup completed! Please check https://$FULL_DOMAIN"
echo "PostgreSQL is running on port 5432"
echo "n8n is running on port 443 with direct HTTPS"
systemctl status n8n --no-pager
echo ""
echo "If you see any issues, check the logs with:"
echo "journalctl -u n8n -f" 