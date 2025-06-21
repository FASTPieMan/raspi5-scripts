#!/bin/bash

set -e

# -----------------------------
# Formatting
# -----------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
TIMESTAMP() { date "+%Y-%m-%d %H:%M:%S"; }

print_status() {
    echo -e "${BLUE}[$(TIMESTAMP)] [INFO]${NC} $1"
}

print_ok() {
    echo -e "${GREEN}[$(TIMESTAMP)] [OK]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[$(TIMESTAMP)] [WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[$(TIMESTAMP)] [ERROR]${NC} $1"
}

# -----------------------------
# System update and cleanup
# -----------------------------
update_system() {
    print_status "Updating and upgrading system..."
    sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt clean
    print_ok "System updated and cleaned"
}

# -----------------------------
# Install Docker
# -----------------------------
install_docker() {
    print_status "Installing Docker..."
    if ! command -v docker &> /dev/null; then
        curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh
        sudo usermod -aG docker $USER
        print_ok "Docker installed and user added to docker group"
    else
        print_warning "Docker is already installed"
    fi
}

# -----------------------------
# Install Samba
# -----------------------------
install_samba() {
    print_status "Installing Samba..."
    if sudo apt install -y samba; then
        print_ok "Samba installed"
    else
        print_error "Failed to install Samba"
        exit 1
    fi
}

# -----------------------------
# Replace Samba Config
# -----------------------------
replace_samba_config() {
    print_status "Replacing Samba configuration..."

    SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
    CONFIG_PATH="$SCRIPT_DIR/smb.conf"

    if [ ! -f "$CONFIG_PATH" ]; then
        print_error "Custom smb.conf not found in script directory!"
        exit 1
    fi

    sudo cp "$CONFIG_PATH" /etc/samba/smb.conf
    sudo systemctl restart smbd
    print_ok "Samba configuration replaced and service restarted"
}

# -----------------------------
# Add Samba user
# -----------------------------
add_samba_user() {
    print_status "Adding Samba user '$USER' with password 'raspberry'..."
    if echo -e "raspberry\nraspberry" | sudo smbpasswd -s -a $USER; then
        sudo smbpasswd -e $USER
        print_ok "Samba user '$USER' added and enabled"
    else
        print_error "Failed to add Samba user '$USER'"
        exit 1
    fi
}

# -----------------------------
# Install extra useful tools
# -----------------------------
install_extra_tools() {
    print_status "Installing additional useful packages..."

    packages=(
      htop nmap tcpdump iftop net-tools traceroute dnsutils curl wget git vim build-essential
      python3 python3-pip nodejs npm docker-compose screen tmux sysstat logwatch fail2ban ufw jq ncdu rsync
      stress stress-ng
    )

    for pkg in "${packages[@]}"; do
        print_status "Installing $pkg..."
        if sudo apt install -y "$pkg"; then
            print_ok "$pkg installed successfully"
        else
            print_error "Failed to install $pkg"
        fi
    done

    print_ok "Additional tools installation completed"
}

# -----------------------------
# Final System Info
# -----------------------------
show_final_info() {
    echo
    echo -e "${GREEN}========== SETUP COMPLETE ==========${NC}"
    echo

    print_status "Gathering system information..."

    HOSTNAME=$(hostname)
    IP_ADDR=$(hostname -I | awk '{print $1}')
    MAC_ADDR=$(ip link show eth0 | awk '/ether/ {print $2}' || echo "Unavailable")
    OPEN_PORTS=$(sudo netstat -tuln | grep LISTEN | awk '{print $4}' | sed 's/.*://g' | sort -n | uniq | tr '\n' ' ')

    echo -e "${BLUE}Hostname:${NC} $HOSTNAME"
    echo -e "${BLUE}IP Address:${NC} $IP_ADDR"
    echo -e "${BLUE}MAC Address:${NC} $MAC_ADDR"
    echo -e "${BLUE}Open Ports:${NC} $OPEN_PORTS"

    echo
    print_ok "System setup is complete!"
    echo

    print_warning "Rebooting in 30 seconds... Press CTRL+C to cancel."
    sleep 30
    sudo reboot
}

# -----------------------------
# Main
# -----------------------------
main() {
    echo
    echo -e "${YELLOW}==== Raspberry Pi Setup Script ====${NC}"
    echo

    update_system
    install_docker
    install_samba
    replace_samba_config
    add_samba_user
    install_extra_tools
    show_final_info
}

main "$@"
