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
    sudo apt install -y samba
    print_ok "Samba installed"
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
    print_status "Adding Samba user '$USER'..."
    echo -e "raspberry\nraspberry" | sudo smbpasswd -s -a $USER
    sudo smbpasswd -e $USER
    print_ok "Samba user '$USER' added and enabled"
}

# -----------------------------
# Install Extra Tools
# -----------------------------
install_extra_tools() {
    echo
    read -rp "Do you want to install extra useful tools (network, dev, monitoring, stress)? (y/n): " install_extra
    if [[ "$install_extra" =~ ^[Yy]$ ]]; then
        declare -A tools=(
            [htop]="Interactive process viewer"
            [nmap]="Network scanner"
            [tcpdump]="Network packet capture"
            [python3]="Python 3 interpreter"
            [python3-pip]="Python 3 package manager"
        )

        for pkg in "${!tools[@]}"; do
            echo "Installing $pkg (${tools[$pkg]})..."
            if sudo apt install -y "$pkg"; then
                echo -e "\e[32m[$(date "+%Y-%m-%d %H:%M:%S")] [OK]\e[0m $pkg installed successfully"
            else
                echo -e "\e[31m[$(date "+%Y-%m-%d %H:%M:%S")] [ERROR]\e[0m Failed to install $pkg"
            fi
        done
    else
        echo "Skipping extra tools installation."
    fi
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
