#!/bin/bash

echo "🔧 Setting up firewalld to work properly with Docker on Fedora..."

# Ensure firewalld is running
echo "Starting firewalld..."
sudo systemctl enable firewalld
sudo systemctl start firewalld

# Check current Docker zone configuration
echo "Current Docker zone configuration:"
sudo firewall-cmd --info-zone=docker

# Ensure Docker zone has proper services
echo "Configuring Docker zone..."
sudo firewall-cmd --permanent --zone=docker --add-service=dns
sudo firewall-cmd --permanent --zone=docker --add-service=http
sudo firewall-cmd --permanent --zone=docker --add-service=https

# Enable masquerading for Docker (NAT)
echo "Enabling masquerading for Docker zone..."
sudo firewall-cmd --permanent --zone=docker --add-masquerade

# Enable forwarding in public zone for external access
echo "Enabling masquerading for public zone..."
sudo firewall-cmd --permanent --zone=public --add-masquerade

# Configure Docker service to start after firewalld
echo "Configuring Docker service dependency..."
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo tee /etc/systemd/system/docker.service.d/firewalld.conf > /dev/null << 'EOF'
[Unit]
After=firewalld.service
Wants=firewalld.service
EOF

# Reload systemd daemon
sudo systemctl daemon-reload

# Apply firewall changes
echo "Reloading firewall rules..."
sudo firewall-cmd --reload

# Restart Docker to pick up new configuration
echo "Restarting Docker service..."
sudo systemctl restart docker

echo "✅ Configuration complete!"
echo ""
echo "📋 Summary:"
echo "- firewalld is now properly configured to work with Docker"
echo "- Docker will start after firewalld to avoid conflicts"
echo "- Masquerading is enabled for container internet access"
echo "- DNS, HTTP, and HTTPS services are allowed in Docker zone"
echo ""
echo "🧪 Testing connectivity..."
docker run --rm alpine:latest sh -c "nslookup google.com && echo 'DNS: ✅ OK'" || echo "DNS: ❌ FAILED" 
