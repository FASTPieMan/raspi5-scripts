# 🛠 Raspberry Pi Setup Script
This repository contains scripts to automate useful setups on your Raspberry Pi:

## Scripts
### Full Raspberry Pi Setup
Updates system, installs Docker, Samba (with custom config and user), useful monitoring/network tools, shows system info, and reboots automatically.

CMD
```
git clone https://github.com/FASTPieMan/raspi5-scripts.git && cd raspi5-scripts/Testbench && chmod +x pi-setup.sh && ./pi-setup.sh
```



### Auto htop Setup
Installs htop if needed, applies a custom htoprc config, and launches htop.

CMD
```
git clone https://github.com/FASTPieMan/raspi5-scripts.git && cd raspi5-scripts/Htop-prefrences && chmod +x htop-setup.sh && ./htop-setup.sh
```

## ▶️ Quick Start
Clone the repo and run any script you need:
Install Git (if needed):
```
sudo apt update && sudo apt install -y git
```
Run the desired setup script from above.

## ⚙️ Notes
- Run scripts with sudo as needed
- Customize config files before running (e.g. smb.conf, htoprc)
- Scripts may reboot your device (cancel with CTRL+C if needed)

