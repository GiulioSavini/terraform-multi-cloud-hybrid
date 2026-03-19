#!/bin/bash
set -euxo pipefail

# Variables from Terraform template
PROJECT="${project}"
ENVIRONMENT="${environment}"

# System updates
dnf update -y
dnf install -y nginx openssl jq amazon-cloudwatch-agent

# Generate self-signed SSL certificate
mkdir -p /etc/nginx/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/server.key \
  -out /etc/nginx/ssl/server.crt \
  -subj "/C=IT/ST=Italy/L=Milan/O=$PROJECT/OU=$ENVIRONMENT/CN=$(hostname)"

# NGINX configuration with SSL
cat > /etc/nginx/conf.d/default.conf << 'NGINX_CONF'
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
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "DENY" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    location / {
        root /usr/share/nginx/html;
        index index.html;
    }

    location /health {
        access_log off;
        return 200 '{"status":"healthy","service":"nginx","timestamp":"$time_iso8601"}';
        add_header Content-Type application/json;
    }

    location /nginx_status {
        stub_status;
        allow 10.0.0.0/8;
        deny all;
    }
}
NGINX_CONF

# Custom index page
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id || echo "unknown")
AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone || echo "unknown")

cat > /usr/share/nginx/html/index.html << EOF
<!DOCTYPE html>
<html>
<head><title>$PROJECT - $ENVIRONMENT</title></head>
<body>
<h1>$PROJECT - $ENVIRONMENT</h1>
<p>Instance: $INSTANCE_ID</p>
<p>AZ: $AZ</p>
<p>Cloud: AWS</p>
</body>
</html>
EOF

# Enable and start NGINX
systemctl enable nginx
systemctl start nginx

# CloudWatch Agent configuration
cat > /opt/aws/amazon-cloudwatch-agent/etc/config.json << 'CW_CONF'
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "root"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/nginx/access.log",
            "log_group_name": "/aws/ec2/nginx/access",
            "log_stream_name": "{instance_id}",
            "retention_in_days": 30
          },
          {
            "file_path": "/var/log/nginx/error.log",
            "log_group_name": "/aws/ec2/nginx/error",
            "log_stream_name": "{instance_id}",
            "retention_in_days": 30
          }
        ]
      }
    }
  },
  "metrics": {
    "namespace": "Custom/NGINX",
    "metrics_collected": {
      "cpu": { "measurement": ["cpu_usage_idle", "cpu_usage_user", "cpu_usage_system"] },
      "disk": { "measurement": ["used_percent"] },
      "mem": { "measurement": ["mem_used_percent"] }
    }
  }
}
CW_CONF

systemctl enable amazon-cloudwatch-agent
systemctl start amazon-cloudwatch-agent

echo "User data script completed successfully"
