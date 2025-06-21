# 🛠 Raspberry Pi Setup Script

This script automatically configures a Raspberry Pi with:

- 🔄 System update and cleanup  
- 🐳 Docker installation  
- 📁 Samba installation and configuration  
- 👤 Samba user creation  
- 🖥 System summary info (IP, MAC, open ports)  
- 🔁 Automatic reboot after 30 seconds  

## 📦 What it does

1. Fully updates and cleans your Raspberry Pi OS  
2. Installs Docker via official script  
3. Installs Samba and applies a custom `smb.conf`  
4. Creates a Samba user with default password  
5. Displays important network/system info  
6. Waits 30 seconds, then reboots  

---

## ▶️ Quick Start

> ⚠️ **This will reboot your Pi after 30 seconds of finishing.**

Copy and paste this into your terminal:

```bash
git clone https://github.com/YOUR-USER/YOUR-REPO.git && cd testbench && chmod +x setup-pi.sh && ./setup.sh
