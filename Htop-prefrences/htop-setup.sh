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
# Install htop
# -----------------------------
install_htop() {
    print_status "Installing htop..."
    if ! command -v htop &> /dev/null; then
        sudo apt update && sudo apt install -y htop
        print_ok "htop installed"
    else
        print_warning "htop is already installed"
    fi
}

# -----------------------------
# Apply Custom htop Config
# -----------------------------
apply_htop_config() {
    print_status "Applying custom htop configuration..."

    SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
    CONFIG_FILE="$SCRIPT_DIR/htoprc"

    if [ ! -f "$CONFIG_FILE" ]; then
        print_error "Custom htoprc not found in script directory!"
        exit 1
    fi

    mkdir -p ~/.config/htop
    cp "$CONFIG_FILE" ~/.config/htop/htoprc
    print_ok "Custom htop config applied"
}

# -----------------------------
# Launch htop
# -----------------------------
launch_htop() {
    print_status "Launching htop with custom configuration..."
    sleep 10
    htop
}

# -----------------------------
# Main
# -----------------------------
main() {
    echo
    echo -e "${YELLOW}==== Auto htop Setup ====${NC}"
    echo

    install_htop
    apply_htop_config
    launch_htop
}

main "$@"
