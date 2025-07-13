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
GRAFANA_ADMIN_USER="admin"
GRAFANA_ADMIN_PASS="admin123"  # change this to your preferred password
GRAFANA_PORT=3000
PROMETHEUS_SCRAPE_INTERVAL="5s"
GRAFANA_API_URL="http://localhost:${GRAFANA_PORT}"
DASHBOARD_IDS=(1860 193 10578)

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
# Wait for Grafana API to be ready
# -----------------------------
wait_for_grafana() {
    print_status "Waiting for Grafana to be ready on port ${GRAFANA_PORT}..."

    for i in {1..30}; do
        if curl -s "${GRAFANA_API_URL}/api/health" | grep -q '"database":"ok"'; then
            print_ok "Grafana is ready."
            return 0
        else
            print_status "Waiting for Grafana... (${i}/30)"
            sleep 2
        fi
    done

    print_error "Grafana did not become ready in time."
    exit 1
}

# -----------------------------
# Configure Grafana: set datasource + import dashboards
# -----------------------------
configure_grafana() {
    print_status "Configuring Grafana datasource and dashboards..."

    # Base64 encode admin creds for basic auth
    AUTH_HEADER="Authorization: Basic $(echo -n "${GRAFANA_ADMIN_USER}:${GRAFANA_ADMIN_PASS}" | base64)"

    # Add Prometheus data source
    print_status "Adding Prometheus data source..."
    curl -s -X POST "${GRAFANA_API_URL}/api/datasources" \
        -H "Content-Type: application/json" \
        -H "${AUTH_HEADER}" \
        -d '{
            "name":"Prometheus",
            "type":"prometheus",
            "access":"proxy",
            "url":"http://prometheus:9090",
            "isDefault":true
        }' | grep -q '"message":"Datasource added"' && print_ok "Prometheus datasource added." || print_warning "Datasource may already exist or failed."

    # Import dashboards by ID
    for id in "${DASHBOARD_IDS[@]}"; do
        print_status "Importing dashboard ID ${id}..."
        DASHBOARD_JSON=$(curl -s "https://grafana.com/api/dashboards/${id}/revisions/latest/download")
        if [ -z "$DASHBOARD_JSON" ]; then
            print_warning "Failed to fetch dashboard ${id} JSON."
            continue
        fi

        # Prepare import payload
        IMPORT_PAYLOAD=$(jq -n \
            --argjson dashboard "$DASHBOARD_JSON" \
            --arg datasource "Prometheus" \
            '{
                "dashboard": $dashboard,
                "overwrite": true,
                "inputs": [
                    {
                        "name": "DS_PROMETHEUS",
                        "type": "datasource",
                        "pluginId": "prometheus",
                        "value": $datasource
                    }
                ]
            }')

        # Import dashboard
        RESPONSE=$(curl -s -X POST "${GRAFANA_API_URL}/api/dashboards/import" \
            -H "Content-Type: application/json" \
            -H "${AUTH_HEADER}" \
            -d "$IMPORT_PAYLOAD")

        if echo "$RESPONSE" | grep -q '"status":"success"'; then
            print_ok "Dashboard ID ${id} imported successfully."
        else
            print_warning "Failed to import dashboard ID ${id}. Response: $RESPONSE"
        fi
    done
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
    echo -e "Grafana is preconfigured with Prometheus datasource and dashboards:"
    echo -e " - Node Exporter Full (ID 1860)"
    echo -e " - Docker Metrics (ID 193)"
    echo -e " - Raspberry Pi Metrics (ID 10578)"
    echo
}

# -----------------------------
# Main
# -----------------------------
main() {
    print_status "Starting Grafana + Prometheus + Node Exporter + cAdvisor setup for Raspberry Pi 5..."

    check_requirements
    create_prometheus_config
    create_docker_compose
    start_stack

    wait_for_grafana
    configure_grafana

    print_summary
}

main "$@"
