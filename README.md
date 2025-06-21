# 🛠 Raspberry Pi 5 Setup Scripts
This repository contains scripts to automate useful setups on your Raspberry Pi:

## Scripts
### Full Raspberry Pi Testbench setup
- Updates system, installs Docker, Samba (with custom config and user), useful monitoring/network tools, shows system info, and reboots automatically.

Setup CMD
```
git clone https://github.com/FASTPieMan/raspi5-scripts.git && cd raspi5-scripts/Testbench && chmod +x pi-setup.sh && ./pi-setup.sh
```

### Auto htop Setup 
- Installs htop if needed, applies a custom htoprc config, and launches htop.

Setup CMD
```
git clone https://github.com/FASTPieMan/raspi5-scripts.git && cd raspi5-scripts/Htop-prefrences && chmod +x htop-setup.sh && ./htop-setup.sh
```

## ▶️ Quick Start
Install Git (if needed):
```
sudo apt update && sudo apt install -y git
```
Run the desired setup CMD from above.

## ⚙️ Notes
- Run scripts with sudo as needed
- Customize config files before running (e.g. smb.conf, htoprc)
- Scripts may reboot your device (cancel with CTRL+C if needed)

