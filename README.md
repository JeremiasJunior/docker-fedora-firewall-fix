# 🔥🐳 Fedora Docker + firewalld Configuration Script

A simple script to properly configure **firewalld** and **Docker** to work together on **Fedora Linux** without conflicts.

## 🚨 The Problem

After upgrading to **Fedora 39+**, many users experience Docker networking issues when firewalld is enabled:

- ❌ DNS resolution failures in containers
- ❌ External connectivity problems  
- ❌ Firebase/Google Cloud SDK download errors
- ❌ `ECONNREFUSED` errors when containers try to access the internet
- ⚠️ firewalld warnings: `COMMAND_FAILED: '/usr/sbin/iptables ... DOCKER, DOCKER-ISOLATION`

## 🎯 The Solution

This script configures firewalld and Docker to work together properly by:

1. **🔧 Setting up proper service dependencies** - Docker starts after firewalld
2. **🌐 Configuring the Docker zone** - Allows necessary services (DNS, HTTP, HTTPS)
3. **🔀 Enabling masquerading** - Provides NAT for container internet access
4. **✅ Testing connectivity** - Verifies everything works after setup

## Prerequisites

- **Fedora Linux** (39+ recommended, but works on earlier versions)
- **Docker** installed
- **sudo access**

## Quick Start

1. **Download the script:**
   ```bash
   curl -O https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/setup-firewall-docker.sh
   chmod +x setup-firewall-docker.sh
   ```

2. **Run the script:**
   ```bash
   ./setup-firewall-docker.sh
   ```

3. **Test your containers:**
   ```bash
   docker run --rm alpine:latest nslookup google.com
   ```

## 📖 What the Script Does

### 🔧 **Firewall Configuration**
- Enables and starts firewalld service
- Configures the Docker zone with proper services:
  - `dns` - For container name resolution
  - `http` - For web traffic
  - `https` - For secure web traffic
- Enables masquerading (NAT) for both Docker and public zones

### **Service Dependencies**
- Creates systemd override configuration
- Ensures Docker starts **after** firewalld
- Prevents startup race conditions

### **Validation**
- Reloads all configurations
- Restarts Docker with new settings
- Tests DNS resolution from a container

## Files Created/Modified

- `/etc/systemd/system/docker.service.d/firewalld.conf` - Service dependency configuration
- Firewalld permanent configuration (via `firewall-cmd --permanent`)

## 🔍 Troubleshooting

### If DNS still fails after running the script:

1. **Check Docker zone status:**
   ```bash
   sudo firewall-cmd --info-zone=docker
   ```

2. **Verify masquerading is enabled:**
   ```bash
   sudo firewall-cmd --zone=docker --query-masquerade
   sudo firewall-cmd --zone=public --query-masquerade
   ```

3. **Check service startup order:**
   ```bash
   systemctl show docker.service | grep After
   ```

4. **Test container connectivity:**
   ```bash
   docker run --rm alpine:latest sh -c "ping -c 2 8.8.8.8"
   ```

### If you need to reset:

```bash
# Remove the service override
sudo rm -rf /etc/systemd/system/docker.service.d/firewalld.conf
sudo systemctl daemon-reload

# Reset firewall to defaults  
sudo firewall-cmd --reload
```

## Manual Configuration

If you prefer to configure manually instead of using the script:

<details>
<summary>Click to expand manual steps</summary>

1. **Enable firewalld:**
   ```bash
   sudo systemctl enable --now firewalld
   ```

2. **Configure Docker zone:**
   ```bash
   sudo firewall-cmd --permanent --zone=docker --add-service=dns
   sudo firewall-cmd --permanent --zone=docker --add-service=http  
   sudo firewall-cmd --permanent --zone=docker --add-service=https
   sudo firewall-cmd --permanent --zone=docker --add-masquerade
   ```

3. **Enable public zone masquerading:**
   ```bash
   sudo firewall-cmd --permanent --zone=public --add-masquerade
   ```

4. **Configure service dependency:**
   ```bash
   sudo mkdir -p /etc/systemd/system/docker.service.d
   sudo tee /etc/systemd/system/docker.service.d/firewalld.conf > /dev/null << 'EOF'
   [Unit]
   After=firewalld.service
   Wants=firewalld.service
   EOF
   ```

5. **Apply changes:**
   ```bash
   sudo systemctl daemon-reload
   sudo firewall-cmd --reload
   sudo systemctl restart docker
   ```

</details>

## Why This Matters

### Before this fix:
- Choose between security (firewall) OR Docker functionality
- Wasted time debugging networking issues
- Running with firewall disabled (security risk)

### After this fix:
- Keep firewall enabled for security
- Full Docker functionality with internet access
- No more DNS resolution errors
- Proper enterprise-ready configuration

## 📄 License

MIT License - Feel free to use, modify, and distribute.
