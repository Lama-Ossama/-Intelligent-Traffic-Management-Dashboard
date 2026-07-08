# Intelligent Traffic Management Dashboard
## Architecture

![Architecture diagram](docs/architecture/architecture.png)
**Drive Link:** https://drive.google.com/drive/folders/1-Q9L_qYiQUs13soYEqLijQGZFUDaiGQo?usp=sharing

**Team Members:**
- Lama Ossama
- Mariam Yasser
- Nouran Atef
- Mohamed Ossama
- Youssef Mustafa

## Project Overview
Cities face challenges in monitoring traffic congestion and reacting quickly to peak times and incidents. This project provides a real-time traffic monitoring system that collects simulated traffic sensor data and displays insights through a dashboard.

The solution focuses on DevOps practices including containerization, Linux-based automation commands, monitoring, and scalable deployment.

## Project Objectives
- Collect traffic data from simulated IoT sensors or CSV logs.
- Display real-time traffic congestion metrics.
- Detect peak times and traffic situations.
- Deploy services using Docker and Kubernetes.
- Monitor the dashboard service with Prometheus.
- Use Nginx as a reverse proxy.

## Tools & Technologies
- Docker
- Kubernetes
- Prometheus
- Nginx
- Git / GitHub
- Linux commands and Bash-friendly workflows

## Prometheus Monitoring
Prometheus was added as the monitoring part of this DevOps project. The dashboard service exposes a `/metrics` endpoint, and Prometheus scrapes it through the internal Docker Compose network.

This is useful for the final demo because the team can show:
- the application dashboard running on port `3002`
- the Prometheus server running on port `9090`
- live metrics collected from the traffic dashboard container
- the health of the Prometheus scrape target

### Monitoring Files
- `prometheus/prometheus.yml`: Prometheus scrape configuration.
- `docker-compose.yml`: Adds the Prometheus container to the local environment.
- `traffic-dashboard/server.js`: Adds `/health` and `/metrics` endpoints.
- `traffic-dashboard/package.json`: Adds the Prometheus client library for Node.js metrics.

### Metrics Exposed by the Dashboard
The dashboard exports default Node.js process metrics and custom traffic metrics:

- `traffic_dashboard_records_total`: total number of CSV traffic records loaded by the dashboard.
- `traffic_dashboard_vehicles_total`: total vehicle count from the dataset.
- `traffic_dashboard_average_vehicles`: average number of vehicles per traffic record.
- `traffic_dashboard_situation_records{situation="..."}`: number of records for each traffic situation.

### Run Locally on Linux
From the project root, run:

```bash
docker compose up --build
```

Open the application dashboard:

```bash
xdg-open http://localhost:3002
```

Open Prometheus:

```bash
xdg-open http://localhost:9090
```

Check the raw metrics endpoint:

```bash
curl http://localhost:3002/metrics
```

Check Prometheus targets:

```bash
xdg-open http://localhost:9090/targets
```

### Prometheus Demo Queries
Use the Prometheus query page at `http://localhost:9090` and try:

```promql
up{job="traffic-dashboard"}
```

```promql
traffic_dashboard_records_total
```

```promql
traffic_dashboard_vehicles_total
```

```promql
traffic_dashboard_situation_records
```

### Stop the Environment
```bash
docker compose down
```
