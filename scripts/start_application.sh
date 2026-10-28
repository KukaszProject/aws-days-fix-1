#!/usr/bin/env bash
set -euo pipefail

APP_DIR="/var/www/app"
VENV_DIR="$APP_DIR/venv"

# Create systemd service file
cat > /etc/systemd/system/flask-app.service << EOF
[Unit]
Description=Flask Application
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=$APP_DIR
Environment="PATH=$VENV_DIR/bin"
# Update ExecStart to use gunicorn and bind to 0.0.0.0:8000
ExecStart=$VENV_DIR/bin/gunicorn --workers 3 --bind 0.0.0.0:8000 application:app
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Set permissions
chown -R ec2-user:ec2-user "$APP_DIR"

# Start service
systemctl daemon-reload
systemctl enable flask-app.service
systemctl restart flask-app.service