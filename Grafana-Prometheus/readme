Perfect. Here's a step-by-step guide to setting up Grafana + Prometheus + Node Exporter (and optionally cAdvisor) on your Raspberry Pi 5 running CasaOS, using Docker Compose. This is lightweight, works great on Pi 5, and gives you slick monitoring dashboards for your system and containers.

🧩 What You'll Get
Service	Purpose	Port
Prometheus	Collect system/container metrics	9090
Grafana	View metrics in dashboards	3000
Node Exporter	Report system stats (CPU, RAM)	9100
cAdvisor (optional)	Report Docker stats	8080

⚙️ Step 1: Create a Folder on Your Pi
SSH into your Pi or use CasaOS’s terminal.

Create a folder for your setup:

bash
Copy
Edit
mkdir -p ~/monitoring-stack && cd ~/monitoring-stack
📝 Step 2: Create docker-compose.yml
Run:

bash
Copy
Edit
nano docker-compose.yml
Paste this full content:

yaml
Copy
Edit
version: '3'

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    ports:
      - "9090:9090"
    restart: unless-stopped

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"
    volumes:
      - grafana_data:/var/lib/grafana
    restart: unless-stopped

  node-exporter:
    image: prom/node-exporter:latest
    container_name: node-exporter
    ports:
      - "9100:9100"
    restart: unless-stopped

  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    container_name: cadvisor
    ports:
      - "8080:8080"
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
    restart: unless-stopped

volumes:
  prometheus_data:
  grafana_data:
Press Ctrl+O, then Enter to save. Press Ctrl+X to exit.

📄 Step 3: Create prometheus.yml Configuration
bash
Copy
Edit
nano prometheus.yml
Paste this content:

yaml
Copy
Edit
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']

  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']
Save and exit with Ctrl+O, Enter, then Ctrl+X.

🚀 Step 4: Start Everything
Run:

bash
Copy
Edit
docker compose up -d
Check that containers are running:

bash
Copy
Edit
docker ps
You should see grafana, prometheus, node-exporter, and cadvisor running.

🌐 Step 5: Access the Web Interfaces
Service	URL
Prometheus	http://<your-pi-ip>:9090
Grafana	http://<your-pi-ip>:3000 (login: admin / admin)
cAdvisor	http://<your-pi-ip>:8080

Change the default Grafana password when prompted.

📊 Step 6: Connect Prometheus to Grafana
In Grafana: Gear (⚙️) > Data Sources > Add data source

Choose Prometheus

Set the URL to: http://prometheus:9090

Click Save & Test

You should see Data source is working.

📥 Step 7: Import Dashboards
Go to + > Import, and paste these Dashboard IDs:

Dashboard Type	Import ID
Node Exporter Full	1860
Docker Stats (cAdvisor)	193
Raspberry Pi Monitoring	10578

You can find more dashboards at: https://grafana.com/grafana/dashboards

✅ Step 8: (Optional) Enable CasaOS Shortcuts
If you want to open Grafana and Prometheus from the CasaOS UI:

Go to CasaOS.

Click “Add App” → “Custom Install”.

Enter:

App Name: Grafana

URL: http://<your-pi-ip>:3000

Icon: Auto-detected or upload one

Repeat for Prometheus or cAdvisor.

🧼 Step 9: (Optional) Auto-Start on Boot
If you want your services to auto-start:

bash
Copy
Edit
cd ~/monitoring-stack
docker compose restart
They already use restart: unless-stopped, so they should auto-start after a reboot.

🧠 Summary
You now have:

Prometheus collecting stats

Node Exporter sending system metrics

cAdvisor tracking Docker containers

Grafana giving you slick dashboards

And it all runs beautifully on a Raspberry Pi 5 with CasaOS + Docker.

If you’d like, I can send you:

A .zip with these config files

A CasaOS-importable app JSON

Help adding temperature sensors (Pi thermals, etc.)
