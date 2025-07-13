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
# Configurable vars
# -----------------------------
GRAFANA_ADMIN_PASS="admin123"  # change this to your preferred password
GRAFANA_PORT=3000
PROMETHEUS_SCRAPE_INTERVAL="5s"

# -----------------------------
# Check Docker & Docker Compose
# -----------------------------
check_requirements() {
    print_status "Checking if Docker is installed..."
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    print_ok "Docker is installed."

    print_status "Checking if Docker Compose is installed..."
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    print_ok "Docker Compose is installed."
}

# -----------------------------
# Create prometheus.yml config
# -----------------------------
create_prometheus_config() {
    print_status "Creating prometheus.yml configuration file..."

    cat > prometheus.yml <<EOF
global:
  scrape_interval: ${PROMETHEUS_SCRAPE_INTERVAL}

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
EOF

    print_ok "prometheus.yml created with scrape_interval=${PROMETHEUS_SCRAPE_INTERVAL}."
}

# -----------------------------
# Create docker-compose.yml file
# -----------------------------
create_docker_compose() {
    print_status "Creating docker-compose.yml..."

    cat > docker-compose.yml <<EOF
version: "3"

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
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_ADMIN_PASS}
    ports:
      - "${GRAFANA_PORT}:3000"
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
EOF

    print_ok "docker-compose.yml created."
}

# -----------------------------
# Start docker compose stack
# -----------------------------
start_stack() {
    print_status "Starting Docker Compose stack..."
    if command -v docker-compose &> /dev/null; then
        docker-compose up -d
    else
        docker compose up -d
    fi
    print_ok "Docker containers started."
}

# -----------------------------
# Summary & Access URLs
# -----------------------------
print_summary() {
    echo
    echo -e "${YELLOW}==== Setup Complete! ====${NC}"
    echo -e "Access your services at:"
    echo -e "Prometheus: ${GREEN}http://<your-pi-ip>:9090${NC}"
    echo -e "Grafana:    ${GREEN}http://<your-pi-ip>:${GRAFANA_PORT} (admin / ${GRAFANA_ADMIN_PASS})${NC}"
    echo -e "Node Exporter: port 9100"
    echo -e "cAdvisor:   ${GREEN}http://<your-pi-ip>:8080${NC}"
    echo
}

# -----------------------------
# Main
# -----------------------------
main() {
    print_status "Starting Grafana + Prometheus + Node Exporter + cAdvisor setup..."

    check_requirements
    create_prometheus_config
    create_docker_compose
    start_stack

    print_summary
}

main "$@"
