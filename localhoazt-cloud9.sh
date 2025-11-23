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
print_message "$GREEN" "🚀 Cloud9 Installation Script By Priv8 Tools And Recoded By Localhoazt🌟"
print_message "$BLUE" "================================================="

# ======================================================
# 🔐 INPUTS
# ======================================================
print_message "$YELLOW" "👤 Masukkan Username Cloud9:"
read -p "Username: " USERNAME

print_message "$YELLOW" "🔑 Masukkan Password Cloud9:"
read -p "Password: " PASSWORD

print_message "$YELLOW" "🔌 Masukkan Port Cloud9 (default: 8969):"
read -p "Port: " PORT

if [[ -z "$PORT" ]]; then PORT=8969; fi

print_message "$GREEN" "✔ Username: $USERNAME"
print_message "$GREEN" "✔ Password: $PASSWORD"
print_message "$GREEN" "✔ Port: $PORT"
sleep 2

# ======================================================
# OS CHECK
# ======================================================
print_message "$YELLOW" "🔍 Detecting Linux..."
if [ -f /etc/os-release ]; then
  . /etc/os-release
  OS=$ID
else
  print_message "$RED" "❌ Tidak bisa mendeteksi OS!"
  exit 1
fi

print_message "$BLUE" "🖥 Detected OS: $OS"

if [[ "$OS" != "ubuntu" && "$OS" != "debian" ]]; then
  print_message "$RED" "❌ Hanya support Ubuntu/Debian!"
  exit 1
fi

# ======================================================
# STEP 1: UPDATE SYSTEM
# ======================================================
print_message "$YELLOW" "⚙️ Step 1: Update System"
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y curl git ca-certificates

if [ $? -ne 0 ]; then
  print_message "$RED" "❌ Update system gagal!"
  exit 1
fi
print_message "$GREEN" "✅ System updated."

# ======================================================
# STEP 2: INSTALL DOCKER (OFFICIAL)
# ======================================================
print_message "$YELLOW" "🐳 Step 2: Installing Docker Official..."

# Remove old docker
sudo apt remove -y docker docker-engine docker.io containerd runc

# Install docker official
curl -fsSL https://get.docker.com | sudo bash

# Enable daemon
sudo systemctl enable docker
sudo systemctl start docker

# Fix permission
sudo usermod -aG docker $USER
sudo chmod 666 /var/run/docker.sock

if [ $? -ne 0 ]; then
  print_message "$RED" "❌ Install Docker gagal!"
  exit 1
fi

print_message "$GREEN" "✅ Docker Installed & Running."

# ======================================================
# STEP 3: PULL CLOUD9 IMAGE
# ======================================================
print_message "$YELLOW" "📥 Step 3: Pulling Cloud9 Image..."
sudo docker pull lscr.io/linuxserver/cloud9:latest
if [ $? -ne 0 ]; then
  print_message "$RED" "❌ Pull Cloud9 gagal!"
  exit 1
fi

print_message "$GREEN" "✅ Cloud9 Image Downloaded."

# ======================================================
# STEP 4: RUN CLOUD9
# ======================================================
print_message "$YELLOW" "🚀 Step 4: Running Cloud9 Container..."

sudo docker run -d \
  --name=Localhoazt-Tools \
  -e USERNAME="$USERNAME" \
  -e PASSWORD="$PASSWORD" \
  -p ${PORT}:${PORT} \
  lscr.io/linuxserver/cloud9:latest

if [ $? -ne 0 ]; then
  print_message "$RED" "❌ Gagal menjalankan Cloud9!"
  exit 1
fi

print_message "$GREEN" "✅ Cloud9 Running on Port $PORT"

sleep 10

# ======================================================
# STEP 5: CONFIGURE CLOUD9 THEME
# ======================================================
print_message "$YELLOW" "⚙️ Step 5: Applying Theme..."

sudo docker exec Localhoazt-Tools /bin/bash -c "
  apt update -y && \
  apt install wget php-cli php-curl -y && \
  cd /c9bins/.c9/ && \
  rm -f user.settings && \
  wget https://raw.githubusercontent.com/localhoazt/localhoazt-app/main/user.settings
"

print_message "$GREEN" "✅ Cloud9 Theme Applied."

# ======================================================
# FINAL
# ======================================================
PUBLIC_IP=$(curl -s ifconfig.me)

print_message "$BLUE" "==========================================="
print_message "$GREEN" "🎉 Cloud9 Installed Successfully!"
print_message "$BLUE" "==========================================="
print_message "$YELLOW" "🌍 URL: http://$PUBLIC_IP:$PORT"
print_message "$YELLOW" "👤 Username: $USERNAME"
print_message "$YELLOW" "🔑 Password: $PASSWORD"
print_message "$BLUE" "==========================================="

sudo rm -f cloud9.sh
