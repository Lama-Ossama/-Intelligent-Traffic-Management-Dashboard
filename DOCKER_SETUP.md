# Intelligent Traffic Management Dashboard — Docker Setup

## Overview
This project consists of two services:
- **Traffic Collector** (Python): Data ingestion service that reads CSV traffic data
- **Traffic Dashboard** (Node.js): Web dashboard that displays traffic statistics

Both services are containerized and orchestrated using Docker Compose.

---

## Prerequisites
- Docker (v20.10+)
- Docker Compose (v1.29+)
- Windows WSL 2 or Linux/Mac

---

## Quick Start

### 1. Build and Start Services

```bash
docker-compose up --build
```

This will:
- Build the traffic-collector image
- Build the traffic-dashboard image
- Start both services and connect them via a bridge network

### 2. Access the Dashboard

Open your browser and navigate to:
```
http://localhost:3002
```

You should see the Intelligent Traffic Management Dashboard with live traffic data.

---

## Services

### Traffic Collector (Python)
- **Container Name:** `traffic-collector`
- **Image:** Python 3.9 Slim
- **Function:** Reads CSV data and prints traffic records every 2 seconds
- **Network:** `traffic-network`
- **Restart Policy:** Unless stopped

### Traffic Dashboard (Node.js)
- **Container Name:** `traffic-dashboard`
- **Image:** Node.js 20 Alpine
- **Port:** 3002 (exposed to host)
- **Function:** Express server that reads CSV and serves a web dashboard
- **Network:** `traffic-network`
- **Depends On:** `traffic-collector`
- **Restart Policy:** Unless stopped

---

## Commands

### View running containers
```bash
docker-compose ps
```

### View logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f traffic-dashboard
docker-compose logs -f traffic-collector
```

### Stop services
```bash
docker-compose down
```

### Stop and remove volumes
```bash
docker-compose down -v
```

### Rebuild services
```bash
docker-compose up --build
```

### Run single service
```bash
docker-compose up traffic-dashboard
```

---

## File Structure
```
.
├── docker-compose.yml                 # Docker Compose orchestration
├── traffic-collector/
│   ├── dockerfile                     # Python collector image
│   ├── app.py                         # Data collector script
│   ├── Traffic.csv                    # Traffic data source
│   └── .dockerignore
├── traffic-dashboard/
│   ├── Dockerfile                     # Node.js dashboard image
│   ├── server.js                      # Express server
│   ├── package.json                   # Node dependencies
│   ├── views/
│   │   └── index.ejs                  # HTML template
│   ├── public/
│   │   └── style.css                  # Dashboard styles
│   ├── data/
│   │   └── Traffic.csv                # Data for dashboard
│   └── .dockerignore
└── README.md
```

---

## Environment Variables

### traffic-collector
- `PYTHONUNBUFFERED=1` (enabled in docker-compose.yml)

### traffic-dashboard
- `NODE_ENV=production`
- `PORT=3002`

---

## Network

Both services communicate via a custom bridge network named `traffic-network`:
- Traffic Collector: Internal service, no exposed ports
- Traffic Dashboard: Port 3002 exposed to host

---

## Next Steps: Kubernetes

After testing locally with Docker Compose, you can migrate to Kubernetes:

1. Push images to a Docker registry (Docker Hub, ECR, GCR, etc.)
2. Create Kubernetes Deployment manifests for each service
3. Create Kubernetes Services for network exposure
4. Use ConfigMaps for environment variables
5. Use PersistentVolumes for data storage

Example structure:
```
k8s/
├── traffic-collector-deployment.yaml
├── traffic-collector-service.yaml
├── traffic-dashboard-deployment.yaml
├── traffic-dashboard-service.yaml
├── configmap.yaml
└── ingress.yaml
```

---

## Troubleshooting

### Services not connecting
```bash
# Check network
docker network ls
docker network inspect traffic-network

# Verify containers are on the same network
docker-compose ps
```

### Port already in use
```bash
# Change port in docker-compose.yml
ports:
  - "3003:3002"  # Map to different host port
```

### Permission denied
```bash
# Run with sudo if needed
sudo docker-compose up --build
```

### CSV file not found
Ensure `Traffic.csv` exists in both:
- `traffic-collector/Traffic.csv`
- `traffic-dashboard/data/Traffic.csv`

---

## Performance Tips

- Use `.dockerignore` to exclude unnecessary files
- Layer caching: Install dependencies before copying source code
- Use Alpine images for smaller image sizes
- Set resource limits in docker-compose.yml if needed

---

## Support

For issues or questions, check logs:
```bash
docker-compose logs traffic-dashboard
docker-compose logs traffic-collector
```
