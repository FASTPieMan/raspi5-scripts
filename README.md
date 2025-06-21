# 🛠 Raspberry Pi Setup Script


## This script automatically configures a Raspberry Pi with:
- 🔄 System update and cleanup
- 🐳 Docker installation
- 📁 Samba installation and configuration (with custom smb.conf)
- 👤 Samba user creation (default password: raspberry)
- 🛠 Installation of extra useful tools for monitoring, networking, and stress testing
- 🖥 System summary info (IP, MAC address, open ports)
- 🔁 Automatic reboot after 30 seconds


## 📦 What it does
- Fully updates and cleans your Raspberry Pi OS
- Installs Docker using the official installation script
- Installs Samba and replaces the default config with a custom smb.conf
- Adds a Samba user matching your current username, with default password raspberry
- Installs extra useful tools like htop, nmap, stress, screen, tmux, and more
- Displays key system and network information after setup completes
- Waits 30 seconds, then automatically reboots the device

## ▶️ Quick Start
⚠️ Warning: This script will automatically reboot your Raspberry Pi 30 seconds after completing. Please save all your work before running it!

Install Git (if not already installed):
```bash
sudo apt update && sudo apt install -y git
```

Copy this command and wait for the install to complete:
```bash
git clone https://github.com/FASTPieMan/testbench.git && cd testbench && chmod +x setup-pi.sh && ./setup-pi.sh
```

## 🔧 Extra Tools Installed
- Network and monitoring: htop, nmap, tcpdump, iftop, traceroute, dnsutils, net-tools
- Development essentials: build-essential, python3, python3-pip, nodejs, npm
- Terminal multiplexers: screen, tmux
- System utilities: sysstat, logwatch, fail2ban, ufw, jq, ncdu, rsync
- Stress testing: stress, stress-ng


## 📋 Samba Configuration
Replaces /etc/samba/smb.conf with a custom config included in the repo

Shares include:
[homes] — your home directory with read-write access
[admin] — root / directory with read-only access

Samba user is your current Linux user with password raspberry

## ⚙️ Notes
Run script with sudo privileges (the script uses sudo internally)
Script will reboot after setup; press CTRL+C to cancel reboot if needed
Customize Samba shares by editing the smb.conf file before running the script
