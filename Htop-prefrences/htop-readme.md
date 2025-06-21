# ⚙️ Auto htop Setup Script

## Sets up and launches htop with a custom config:
- 🧰 Installs htop (if not already installed)
- ⚙️ Applies a custom htoprc config
- 🚀 Launches htop after setup

## ▶️ Quick Start
Install Git (if needed):

```
sudo apt update && sudo apt install -y git
```

Run setup:
```
git clone https://github.com/FASTPieMan/raspi5-scripts.git && cd raspi5-scripts/Htop-prefrences && chmod +x htop-setup.sh && ./htop-setup.sh
```

## 🗂 htop Config
Looks for htoprc in the script directory

Copies it to ~/.config/htop/htoprc

## ⚠️ Notes
- Run from the directory containing htoprc

- Script exits if the config file is missing
