# 🛠 Raspberry Pi Setup Script

## Automates Raspberry Pi setup with:
- 🔄 System update & cleanup
- 🐳 Docker installation
- 📁 Samba setup (custom config, user: your-username, pass: raspberry)
- 🧰 Extra tools: htop, nmap, stress, tmux, etc.
- 🖥 System info summary (IP, MAC, open ports)
- 🔁 Auto reboot after 30 seconds

## ▶️ Quick Start
Install Git (if needed):

```
sudo apt update && sudo apt install -y git
```

Run setup:
```
git clone https://github.com/FASTPieMan/raspi5-scripts.git && cd raspi5-scripts/Testbench && chmod +x pi-setup.sh && ./pi-setup.sh
```

## 📦 Samba Config
Replaces /etc/samba/smb.conf
### Shares:
[homes] – RW access to home dir
[admin] – RO access to /
User: your Linux user | Pass: raspberry

## ⚙️ Notes
- Auto reboots after setup (CTRL+C to cancel)
- Customize smb.conf before running to change shares
