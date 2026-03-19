#!/bin/bash
set -euxo pipefail

# Install packages
apt-get update
apt-get install -y nginx openssl jq

# Generate self-signed SSL cert
mkdir -p /etc/nginx/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/server.key \
  -out /etc/nginx/ssl/server.crt \
  -subj "/C=IT/ST=Italy/L=Milan/O=HybridLZ/CN=$(hostname)"

# NGINX config
cat > /etc/nginx/sites-available/default << 'NGINX_CONF'
server {
    listen 80;
    server_name _;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name _;

    ssl_certificate /etc/nginx/ssl/server.crt;
    ssl_certificate_key /etc/nginx/ssl/server.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "DENY" always;

    location / {
        root /var/www/html;
        index index.html;
    }

    location /health {
        access_log off;
        return 200 '{"status":"healthy","cloud":"gcp"}';
        add_header Content-Type application/json;
    }
}
NGINX_CONF

# Instance metadata
INSTANCE_NAME=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/name || echo "unknown")
ZONE=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/zone | awk -F/ '{print $NF}' || echo "unknown")

cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html>
<head><title>GCP - Hybrid Landing Zone</title></head>
<body>
<h1>GCP Compute Engine</h1>
<p>Instance: $INSTANCE_NAME</p>
<p>Zone: $ZONE</p>
<p>Cloud: GCP</p>
</body>
</html>
EOF

systemctl enable nginx
systemctl restart nginx
