#!/bin/bash

print_message() {
  local COLOR=$1
  local MESSAGE=$2
  local RESET="\033[0m"
  echo -e "${COLOR}${MESSAGE}${RESET}"
}

GREEN="\033[1;32m"
BLUE="\033[1;34m"
YELLOW="\033[1;33m"
RED="\033[1;31m"

print_message "$BLUE" "================================================="
print_message "$GREEN" "🚀 Cloud9 Installation Script By Priv8 Tools and Recoded By localhoazt🌟"
print_message "$BLUE" "================================================="

# ======================================================
# 🔐 INPUT USERNAME, PASSWORD, PORT
# ======================================================
print_message "$YELLOW" "👤 Masukkan Username Cloud9:"
read -p "Username: " USERNAME

print_message "$YELLOW" "🔑 Masukkan Password Cloud9:"
read -p "Password: " PASSWORD

print_message "$YELLOW" "🔌 Masukkan Port Cloud9 (default: 8969):"
read -p "Port: " PORT

if [[ -z "$PORT" ]]; then
  PORT=8969
fi

print_message "$GREEN" "✔ Username: $USERNAME"
print_message "$GREEN" "✔ Password: $PASSWORD"
print_message "$GREEN" "✔ Port: $PORT"
sleep 2

# ======================================================
# OS CHECK
# ======================================================
print_message "$YELLOW" "🔍 Detecting Linux distribution..."
if [ -f /etc/os-release ]; then
  . /etc/os-release
  OS=$ID
else
  print_message "$RED" "❌ Unable to detect Linux distribution. Exiting..."
  exit 1
fi

print_message "$BLUE" "🖥️ Detected OS: $OS"

if [[ "$OS" != "ubuntu" && "$OS" != "debian" ]]; then
  print_message "$RED" "❌ Unsupported OS: $OS. Only Ubuntu/Debian supported."
  exit 1
fi

# ======================================================
# STEP 1: UPDATE SYSTEM
# ======================================================
print_message "$YELLOW" "⚙️ Step 1: Updating system..."
sudo apt update -y && sudo apt upgrade -y && sudo apt install git curl -y
if [ $? -ne 0 ]; then
  print_message "$RED" "❌ Failed to update system."
  exit 1
fi
print_message "$GREEN" "✅ System updated."

# ======================================================
# STEP 2: INSTALL DOCKER PROPERLY
# ======================================================
print_message "$YELLOW" "🐳 Step 2: Installing Docker (Official Repo)..."

# Remove docker snap if exists
if snap list | grep -q docker; then
  print_message "$YELLOW" "⚠ Found Docker SNAP version. Removing..."
  sudo snap remove docker
fi

# Install Docker official
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Enable docker daemon
sudo systemctl enable docker
sudo systemctl start docker

# Add user to docker group
sudo usermod -aG docker $USER

if [ $? -ne 0 ]; then
  print_message "$RED" "❌ Failed to install Docker."
  exit 1
fi

print_message "$GREEN" "✅ Docker installed and service running."
sleep 3

# ======================================================
# STEP 3: PULL CLOUD9 IMAGE
# ======================================================
print_message "$YELLOW" "📥 Step 3: Pulling Cloud9 Docker image..."
sudo docker pull lscr.io/linuxserver/cloud9
if [ $? -ne 0 ]; then
  print_message "$RED" "❌ Failed to pull Cloud9 image."
  exit 1
fi
print_message "$GREEN" "✅ Cloud9 image pulled."

# ======================================================
# STEP 4: RUN CLOUD9
# ======================================================
print_message "$YELLOW" "🚀 Step 4: Running Cloud9 Server..."
sudo docker run -d \
  --name=Localhoazt-Tools \
  -e USERNAME="$USERNAME" \
  -e PASSWORD="$PASSWORD" \
  -p ${PORT}:${PORT} \
  lscr.io/linuxserver/cloud9:latest

if [ $? -ne 0 ]; then
  print_message "$RED" "❌ Failed to start Cloud9 container."
  exit 1
fi

print_message "$GREEN" "✅ Cloud9 container running on port $PORT."

print_message "$YELLOW" "⏳ Waiting 1 minute..."
sleep 60

# ======================================================
# STEP 5: CONFIGURE CLOUD9
# ======================================================
print_message "$YELLOW" "⚙️ Step 5: Configuring Cloud9 container..."
sudo docker exec Localhoazt-Tools /bin/bash -c "
  apt update -y && \
  apt upgrade -y && \
  apt install wget php-cli php-curl -y && \
  cd /c9bins/.c9/ && \
  rm -rf user.settings && \
  wget https://raw.githubusercontent.com/localhoazt/localhoazt-app/main/user.settings
"

if [ $? -ne 0 ]; then
  print_message "$RED" "❌ Failed to configure Cloud9."
  exit 1
fi
print_message "$GREEN" "✅ Cloud9 configured."

# ======================================================
# STEP 6: RESTART CONTAINER
# ======================================================
print_message "$YELLOW" "♻ Restarting Cloud9 container..."
sudo docker restart Localhoazt-Tools
if [ $? -ne 0 ]; then
  print_message "$RED" "❌ Failed to restart Cloud9."
  exit 1
fi
print_message "$GREEN" "✅ Cloud9 container restarted."

# ======================================================
# FINAL OUTPUT
# ======================================================
PUBLIC_IP=$(curl -s ifconfig.me)

print_message "$BLUE" "==========================================="
print_message "$GREEN" "🎉 Cloud9 Setup Completed Successfully 🎉"
print_message "$BLUE" "==========================================="
print_message "$YELLOW" "🌍 Access Cloud9: http://$PUBLIC_IP:$PORT"
print_message "$YELLOW" "👤 Username: $USERNAME"
print_message "$YELLOW" "🔑 Password: $PASSWORD"
print_message "$YELLOW" "==========================================="

sudo rm -rf install-cloud9.sh c9.sh get-docker.sh
