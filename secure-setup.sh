#!/bin/bash

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
sudo -u postgres psql -c "CREATE USER n8n WITH PASSWORD 'n8n_secure_password';"
sudo -u postgres psql -c "CREATE DATABASE n8n;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE n8n TO n8n;"
echo "PostgreSQL configuration completed."

# Install n8n globally
npm install -g n8n

# Stop nginx temporarily for certbot
systemctl stop nginx

# Get SSL certificate
certbot certonly --standalone -d n8n.natsdevstudio.com --non-interactive --agree-tos --email natselayron@gmail.com

# Create n8n system service
cat > /etc/systemd/system/n8n.service << EOL
[Unit]
Description=n8n Workflow Automation
After=network.target postgresql.service

[Service]
Type=simple
User=root
Environment=NODE_ENV=production
Environment=N8N_HOST=n8n.natsdevstudio.com
Environment=N8N_PROTOCOL=https
Environment=N8N_PORT=5678
Environment=DB_TYPE=postgresdb
Environment=DB_POSTGRESDB_HOST=localhost
Environment=DB_POSTGRESDB_PORT=5432
Environment=DB_POSTGRESDB_DATABASE=n8n
Environment=DB_POSTGRESDB_USER=n8n
Environment=DB_POSTGRESDB_PASSWORD=n8n_secure_password
Environment=N8N_SSL_CERT=/etc/letsencrypt/live/n8n.natsdevstudio.com/fullchain.pem
Environment=N8N_SSL_KEY=/etc/letsencrypt/live/n8n.natsdevstudio.com/privkey.pem
Environment=GENERIC_TIMEZONE=Asia/Manila
Environment=TZ=Asia/Manila
Environment=N8N_SECURE_COOKIE=true
ExecStart=/usr/bin/n8n start
Restart=always

[Install]
WantedBy=multi-user.target
EOL

# Configure Nginx
cat > /etc/nginx/sites-available/n8n << EOL
server {
    listen 80;
    listen [::]:80;
    server_name n8n.natsdevstudio.com;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name n8n.natsdevstudio.com;

    ssl_certificate /etc/letsencrypt/live/n8n.natsdevstudio.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/n8n.natsdevstudio.com/privkey.pem;

    # SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:50m;
    ssl_stapling on;
    ssl_stapling_verify on;
    add_header Strict-Transport-Security "max-age=31536000" always;

    location / {
        proxy_pass http://localhost:5678;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header Host \$host;
        proxy_set_header Connection '';
        proxy_http_version 1.1;
        proxy_buffering off;
        proxy_read_timeout 120s;
        proxy_redirect off;
        proxy_send_timeout 120s;
        client_max_body_size 100M;
    }
}
EOL

# Enable n8n site and remove default
ln -sf /etc/nginx/sites-available/n8n /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Enable and start services
systemctl daemon-reload
systemctl enable postgresql
systemctl start postgresql
systemctl enable n8n
systemctl start n8n
systemctl enable nginx
systemctl start nginx

# Print status
echo "Setup completed! Please check https://n8n.natsdevstudio.com"
echo "PostgreSQL is running on port 5432"
echo "n8n is running on port 5678 (proxied through Nginx)"
systemctl status n8n --no-pager
systemctl status nginx --no-pager 