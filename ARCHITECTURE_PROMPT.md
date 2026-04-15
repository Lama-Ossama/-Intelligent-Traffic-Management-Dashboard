# Intelligent Traffic Management Dashboard - Architecture & Flow Prompt

## 🎯 Project Overview

You are an expert in creating comprehensive system architecture diagrams and flowcharts. Create a detailed visual representation of the "Intelligent Traffic Management Dashboard" DevOps project that shows:

1. **Data Flow**: How data moves through the entire system
2. **Component Relationships**: How different services interact
3. **File Organization**: Where each file/folder fits in the architecture
4. **Technology Stack**: Tools and languages used in each layer
5. **Deployment Pipeline**: From development to production to Kubernetes

---

## 📊 System Architecture Details

### **Layer 1: Data Source**
- **File**: `traffic-collector/Traffic.csv`
- **Purpose**: Contains historical traffic data (timestamps, vehicle counts, traffic situations)
- **Format**: CSV with columns: Time, Date, Day of the week, CarCount, BikeCount, BusCount, TruckCount, Total, Traffic Situation

### **Layer 2: Data Collection & Processing (Backend Service 1)**
- **Component Name**: Traffic Collector
- **Technology**: Python 3.9
- **Main File**: `traffic-collector/app.py`
- **Dockerfile**: `traffic-collector/Dockerfile`
- **Purpose**: 
  - Reads Traffic.csv row by row
  - Sends each row to Dashboard API every 2 seconds (simulating real-time sensor data)
  - Acts as data producer
- **Container Image**: `mohamedosama2004/traffic-collector:latest`
- **Port**: Internal (no external exposure)

### **Layer 3: Dashboard & API (Backend Service 2)**
- **Component Name**: Traffic Dashboard
- **Technology**: Node.js 16 + Express.js
- **Main Files**: 
  - `traffic-dashboard/server.js` (Express API server)
  - `traffic-dashboard/package.json` (Dependencies)
- **Dockerfile**: `traffic-dashboard/Dockerfile`
- **Purpose**:
  - Receives live traffic data from Collector
  - Stores data in memory (last 50-100 records)
  - Provides REST API endpoints
  - Computes statistics and analytics
- **Container Image**: `mohamedosama2004/traffic-dashboard:latest`
- **Port**: 3002 (exposed externally)
- **API Endpoints**:
  - `GET /` - HTML Dashboard UI
  - `GET /api/traffic` - All traffic records (CSV data)
  - `GET /api/traffic/live` - Current live records
  - `POST /api/traffic/live` - Receive new data from Collector

### **Layer 4: Frontend UI (Presentation Layer)**
- **Files**:
  - `traffic-dashboard/views/index.ejs` (HTML Template)
  - `traffic-dashboard/public/style.css` (Styling)
- **Technology**: EJS templates, HTML5, CSS3
- **Purpose**: 
  - Displays real-time traffic dashboard
  - Shows statistics cards (total records, total vehicles, avg vehicles, peak traffic)
  - Traffic situation breakdown (Low, Normal, High, Heavy)
  - Paginated table (100 records per page)
  - Auto-refresh every 3 seconds
- **Features**:
  - Responsive design
  - Real-time updates
  - Pagination controls

### **Layer 5: Container & Orchestration**

#### **Docker Setup (Local Development)**
- **File**: `docker-compose.yml`
- **Purpose**: Defines multi-container setup for local development
- **Services**: traffic-collector, traffic-dashboard
- **Networks**: Internal bridge network

#### **Docker Production Setup**
- **File**: `docker-compose.prod.yml`
- **Purpose**: Production-ready configuration
- **Features**: 
  - Environment variables from .env
  - Health checks
  - Restart policies
  - Resource limits
  - Logging configuration

#### **Kubernetes Configuration**
- **Folder**: `k8s/`
- **Files**:
  - `01-namespace.yaml` - Creates isolated namespace "traffic-system"
  - `02-secrets-configmap.yaml` - Configuration & Docker credentials
  - `03-traffic-collector.yaml` - Collector Deployment + Service
  - `04-traffic-dashboard.yaml` - Dashboard Deployment + Service + HPA
  - `kustomization.yaml` - Simplifies K8s deployment
- **Key Features**:
  - **Deployments**: Manage pods and replicas
  - **Services**: Expose pods (ClusterIP for Collector, LoadBalancer for Dashboard)
  - **Health Checks**: 
    - Liveness Probe (detect dead pods → restart)
    - Readiness Probe (detect unhealthy pods → remove from LB)
  - **Auto-Scaling**: HorizontalPodAutoscaler (scale Dashboard 2-5 replicas based on CPU/Memory)
  - **Pod Restart**: Auto-restart failed pods
  - **Resource Limits**: CPU and Memory constraints

### **Layer 6: CI/CD Pipeline (Automation)**
- **File**: `.github/workflows/ci-cd.yml`
- **Platform**: GitHub Actions
- **Purpose**: Automated testing, building, and deployment
- **Jobs**:
  1. **Test & Build**:
     - Build Docker images
     - Run containers
     - Execute health checks
     - Test API endpoints
  2. **Build & Push to Docker Hub**:
     - Triggered on main branch push
     - Push images with tags: `latest` + commit SHA
     - Requires: DOCKER_HUB_USERNAME, DOCKER_HUB_TOKEN secrets
  3. **Code Quality**:
     - Python syntax check
     - Node.js dependencies validation
     - JavaScript syntax check

### **Layer 7: Documentation & Configuration**

#### **Setup & Deployment Guides**
- `CI_CD_SETUP.md` - GitHub Actions configuration guide
- `KUBERNETES_SETUP.md` - K8s deployment instructions
- `KUBERNETES_MONITORING.md` - Pod monitoring and troubleshooting
- `DOCKER_SETUP.md` - Docker configuration
- `LOCAL_TEST_STEPS.md` - Local testing procedures
- `README_CI_CD.md` - Project overview and architecture

#### **Root Configuration Files**
- `README.md` - Main project documentation
- `.github/workflows/` - CI/CD automation
- `.dockerignore` - Files to exclude from Docker builds
- `k8s/` - Kubernetes manifests directory

---

## 🔄 Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                       DATA FLOW                                 │
└─────────────────────────────────────────────────────────────────┘

CSV File (Traffic.csv)
       ↓
   [Python App]
   (traffic-collector/app.py)
       ├─ Reads row every 2 seconds
       └─ Sends HTTP POST request
            ↓
   [Express Server]
   (traffic-dashboard/server.js)
       ├─ Receives POST /api/traffic/live
       ├─ Stores in memory
       └─ Computes statistics
            ↓
   [EJS Template]
   (index.ejs)
       ├─ Renders HTML
       └─ Displays in browser
            ↓
   [Auto-refresh JavaScript]
       └─ Polls /api/traffic/live every 3 seconds
            ↓
   [Browser Display]
       └─ Shows live dashboard
```

---

## 🐳 Container Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                  DOCKER COMPOSE (Local)                          │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────────────────┐    ┌─────────────────────────────┐ │
│  │  traffic-collector      │    │  traffic-dashboard          │ │
│  │  Container              │    │  Container                  │ │
│  ├─────────────────────────┤    ├─────────────────────────────┤ │
│  │ Image: python:3.9-slim  │    │ Image: node:16-alpine       │ │
│  │ Port: Internal          │    │ Port: 3002:3002 (exposed)   │ │
│  │ Volumes: Traffic.csv    │    │ Volumes: data/, logs/       │ │
│  └─────────────────────────┘    └─────────────────────────────┘ │
│           ↓ (HTTP POST)                        ↑                 │
│    Sends data every 2 sec        Receives & stores in memory    │
│                                                                  │
│           ┌─────────────────────────────────────────┐            │
│           │      Docker Network: bridge             │            │
│           │   (traffic-collector talks to          │            │
│           │    traffic-dashboard via service name) │            │
│           └─────────────────────────────────────────┘            │
└──────────────────────────────────────────────────────────────────┘
```

---

## ☸️ Kubernetes Architecture

```
┌────────────────────────────────────────────────────────────────────┐
│                  KUBERNETES CLUSTER                                │
├────────────────────────────────────────────────────────────────────┤
│                                                                    │
│  Namespace: traffic-system                                         │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │                                                              │  │
│  │  ┌──────────────────────┐  ┌──────────────────────────────┐ │  │
│  │  │ Deployment:          │  │ Deployment:                  │ │  │
│  │  │ traffic-collector    │  │ traffic-dashboard            │ │  │
│  │  ├──────────────────────┤  ├──────────────────────────────┤ │  │
│  │  │ Replicas: 1          │  │ Replicas: 2 (min) → 5 (max) │ │  │
│  │  │ Pod: collector-xxx   │  │ Pod: dashboard-yyy           │ │  │
│  │  │ Pod: collector-zzz   │  │ Pod: dashboard-www           │ │  │
│  │  │                      │  │                              │ │  │
│  │  │ Health Checks:       │  │ Health Checks:               │ │  │
│  │  │ - Liveness Probe     │  │ - Liveness Probe (HTTP GET) │ │  │
│  │  │ - Readiness Probe    │  │ - Readiness Probe (HTTP)    │ │  │
│  │  │                      │  │ - Startup Probe             │ │  │
│  │  │ Auto-Restart: YES    │  │ Auto-Restart: YES            │ │  │
│  │  └──────────────────────┘  └──────────────────────────────┘ │  │
│  │           ↓                           ↓                       │  │
│  │  ┌──────────────────────┐  ┌──────────────────────────────┐ │  │
│  │  │ Service: ClusterIP   │  │ Service: LoadBalancer        │ │  │
│  │  │ Port: 3001           │  │ Port: 3002                   │ │  │
│  │  │ (Internal only)      │  │ (External access)            │ │  │
│  │  └──────────────────────┘  └──────────────────────────────┘ │  │
│  │                                      ↓                       │  │
│  │                    ┌──────────────────────────────┐          │  │
│  │                    │ HorizontalPodAutoscaler      │          │  │
│  │                    │ Min: 2, Max: 5               │          │  │
│  │                    │ CPU target: 70%              │          │  │
│  │                    │ Memory target: 80%           │          │  │
│  │                    └──────────────────────────────┘          │  │
│  │                                                              │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

---

## 🚀 CI/CD Pipeline Flow

```
Developer commits code
        ↓
   [GitHub Push]
        ↓
[GitHub Actions Triggered]
        ├─ Checkout code
        ├─ Build Docker images (docker compose build)
        ├─ Run containers
        ├─ Test APIs (curl http://localhost:3002/)
        ├─ Stop containers
        ├─ Code quality checks (Python & Node.js syntax)
        └─ If all pass:
             ├─ Login to Docker Hub
             ├─ Push traffic-collector:latest + SHA
             └─ Push traffic-dashboard:latest + SHA
                      ↓
            [Docker Hub Repository]
            (Public images available)
                      ↓
            [Kubernetes] (can pull images)
            kubectl apply -f k8s/
                      ↓
            [Production Deployment]
            (Auto-running & auto-scaling)
```

---

## 📁 File Structure & Purposes

```
-Intelligent-Traffic-Management-Dashboard/
│
├── 📂 .github/workflows/
│   └── ci-cd.yml                          # GitHub Actions pipeline
│       ├─ Test & Build job
│       ├─ Push to Docker Hub job
│       └─ Code quality job
│
├── 📂 traffic-collector/
│   ├── app.py                             # Python data producer
│   ├── Dockerfile                         # Container definition
│   ├── Traffic.csv                        # Sample data
│   └── .dockerignore
│
├── 📂 traffic-dashboard/
│   ├── server.js                          # Express API server
│   ├── package.json                       # Node dependencies
│   ├── Dockerfile                         # Container definition
│   ├── .dockerignore
│   ├── 📂 views/
│   │   └── index.ejs                      # HTML template
│   ├── 📂 public/
│   │   └── style.css                      # Frontend styling
│   └── 📂 data/
│       └── Traffic.csv                    # Data file
│
├── 📂 k8s/
│   ├── 01-namespace.yaml                  # K8s namespace
│   ├── 02-secrets-configmap.yaml          # Configuration
│   ├── 03-traffic-collector.yaml          # Collector deployment
│   ├── 04-traffic-dashboard.yaml          # Dashboard deployment + HPA
│   └── kustomization.yaml                 # K8s manifest tool
│
├── docker-compose.yml                     # Local dev setup
├── docker-compose.prod.yml                # Production setup
│
├── 📂 Documentation/
│   ├── README.md                          # Main documentation
│   ├── CI_CD_SETUP.md                     # GitHub Actions guide
│   ├── KUBERNETES_SETUP.md                # K8s deployment guide
│   ├── KUBERNETES_MONITORING.md           # Pod monitoring guide
│   ├── DOCKER_SETUP.md                    # Docker setup
│   ├── LOCAL_TEST_STEPS.md                # Local testing
│   └── README_CI_CD.md                    # CI/CD overview
│
└── Configuration files
    ├── .dockerignore (in each service)
    └── .gitignore
```

---

## 🔗 File Relationships & Dependencies

```
Traffic.csv (Source Data)
    ↓ (read by)
app.py (Traffic Collector)
    ↓ (sends HTTP POST)
server.js (Express API)
    ↓ (uses)
index.ejs + style.css (Frontend)
    ↓ (displayed in)
Browser (User Interface)

---

Dockerfile (collector) → Creates → traffic-collector:latest (Docker image)
Dockerfile (dashboard) → Creates → traffic-dashboard:latest (Docker image)

---

docker-compose.yml → Orchestrates → Local containers (Development)
docker-compose.prod.yml → Orchestrates → Production containers

---

ci-cd.yml → Automates → Build → Test → Push to Docker Hub
Docker Hub Images → Pulled by → Kubernetes
k8s/manifests → Deploys → Pods → Services → HPA

---

KUBERNETES_SETUP.md → Explains → k8s/*.yaml files
KUBERNETES_MONITORING.md → Explains → How to monitor pods
CI_CD_SETUP.md → Explains → ci-cd.yml workflow
```

---

## 🎯 Key Technologies & Their Roles

| Technology | Role | File | Purpose |
|-----------|------|------|---------|
| Python 3.9 | Data Producer | app.py | Reads CSV, sends data |
| Node.js 16 | API Server | server.js | Receives, processes, serves data |
| Express.js | Web Framework | server.js | Routing, API endpoints |
| EJS | Template Engine | index.ejs | Render HTML dashboard |
| Docker | Containerization | Dockerfile | Package apps in containers |
| Docker Compose | Container Orchestration | docker-compose.yml | Local multi-container setup |
| Kubernetes | Cloud Orchestration | k8s/*.yaml | Production container management |
| GitHub Actions | CI/CD | .github/workflows/ci-cd.yml | Automated build & deploy |
| Docker Hub | Image Registry | - | Store container images |

---

## 📊 Deployment Journey

```
DEVELOPMENT
├── Write Code (app.py, server.js)
├── Test Locally (docker-compose up)
└── Push to Git

         ↓ (GitHub webhook)

CI/CD PIPELINE
├── Checkout Code
├── Build Images
├── Run Tests
├── Quality Checks
└── Push to Docker Hub (if all pass)

         ↓ (Images available on Docker Hub)

PRODUCTION DEPLOYMENT
├── Pull Images from Docker Hub
├── Apply K8s manifests (kubectl apply -f k8s/)
├── Deploy Pods
├── Create Services
├── Setup Health Checks
├── Enable Auto-Scaling
└── Live on Cluster!

         ↓ (Real-time monitoring)

MONITORING
├── Watch Pods
├── Check Logs
├── Verify Health
├── Monitor Resources
└── Auto-Restart if Needed
```

---

## 💡 Create a diagram that shows:

1. **Data Flow**: Traffic.csv → Collector → Dashboard API → Frontend → Browser
2. **Service Architecture**: How traffic-collector and traffic-dashboard communicate
3. **Container Layers**: From Docker containers to Kubernetes pods
4. **CI/CD Pipeline**: From code commit to production deployment
5. **File Organization**: Where each file fits in the overall system
6. **Technology Stack**: Tools used in each layer (Python, Node.js, Docker, K8s, GitHub Actions)
7. **Auto-Restart & Scaling**: How Kubernetes manages pods and scales them

---

## 📝 Design Requirements:

- Use clear, modern visual styling
- Color-code different components (Data layer, App layer, Container layer, Orchestration layer, CI/CD layer)
- Show data flow with arrows
- Include file names next to their components
- Show relationships between files (dependencies, data flow)
- Include tech stack icons/labels
- Make it suitable for presentations and documentation
- Show the complete journey: Development → CI/CD → Docker Hub → Kubernetes → Running Pods

