# Intelligent Traffic Management Dashboard

**Advanced DevOps Project with CI/CD Pipeline**

---

## 📌 Project Overview

تطبيق متكامل لـ إدارة ومراقبة المرور في الوقت الفعلي باستخدام:
- **Backend**: Python Data Collector + Node.js Dashboard
- **Containerization**: Docker + Docker Compose
- **CI/CD**: GitHub Actions with automated testing and Docker Hub deployment
- **Monitoring**: Real-time data processing and visualization

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Traffic Data                         │
│                    (CSV File)                           │
└─────────────────────────────────────────────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────┐
│          Traffic Collector (Python)                     │
│   • Reads CSV data                                      │
│   • Processes records every 2 seconds                   │
│   • Sends to Dashboard API                              │
└─────────────────────────────────────────────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────┐
│        Traffic Dashboard (Node.js + Express)            │
│   • Receives data via REST API                          │
│   • Stores in memory (latest 50 records)                │
│   • Serves web interface on port 3002                   │
│   • Provides JSON APIs                                  │
└─────────────────────────────────────────────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────┐
│        Web Browser (Frontend)                           │
│   • Real-time dashboard with live updates               │
│   • Statistics and traffic analysis                     │
│   • Pagination (100 records per page)                   │
│   • Responsive design                                   │
└─────────────────────────────────────────────────────────┘
```

---

## 🚀 Quick Start

### Prerequisites
- Docker & Docker Compose installed
- Git (for cloning repo)

### Local Development

```powershell
# Clone the repository
git clone https://github.com/Lama-Ossama/-Intelligent-Traffic-Management-Dashboard.git
cd -Intelligent-Traffic-Management-Dashboard

# Start services
docker-compose up

# Access dashboard
# Browser: http://localhost:3002
# API: http://localhost:3002/api/traffic
```

### Docker Hub Images

```powershell
# After CI/CD pipeline pushes images
docker pull lamaossama/traffic-dashboard:latest
docker pull lamaossama/traffic-collector:latest

# Or use compose with environment variables
$env:DOCKER_REGISTRY = "lamaossama"
$env:IMAGE_TAG = "latest"
docker-compose -f docker-compose.prod.yml up
```

---

## 📁 Project Structure

```
.
├── .github/
│   └── workflows/
│       └── ci-cd.yml                 # GitHub Actions workflow
├── traffic-collector/
│   ├── app.py                        # Python data collector
│   ├── Dockerfile                    # Python container config
│   ├── .dockerignore
│   └── Traffic.csv                   # Sample traffic data
├── traffic-dashboard/
│   ├── server.js                     # Express server
│   ├── Dockerfile                    # Node.js container config
│   ├── .dockerignore
│   ├── package.json                  # Dependencies
│   ├── views/
│   │   └── index.ejs                 # HTML template
│   ├── public/
│   │   └── style.css                 # Dashboard styles
│   └── data/
│       └── Traffic.csv
├── docker-compose.yml                # Development
├── docker-compose.prod.yml           # Production
├── CI_CD_SETUP.md                    # CI/CD documentation
└── README.md                         # This file
```

---

## 🔧 Services

### Traffic Collector (Python)
- **Port**: Internal (no external port)
- **Reads**: Traffic.csv
- **Sends**: Data to Dashboard API every 2 seconds
- **Image**: `traffic-collector`

### Traffic Dashboard (Node.js)
- **Port**: 3002
- **Endpoints**:
  - `GET /` - Main dashboard
  - `GET /api/traffic` - All traffic records (CSV)
  - `GET /api/traffic/live` - Current live records
  - `POST /api/traffic/live` - Receive new data

---

## 📊 Features

### Dashboard Features
- ✅ Real-time traffic statistics
- ✅ Live data updates every 3 seconds
- ✅ Vehicle breakdown (cars, bikes, buses, trucks)
- ✅ Traffic situation analysis
- ✅ Peak traffic detection
- ✅ Pagination (100 records per page)
- ✅ Responsive web interface

### Data Processing
- Reads CSV files with traffic data
- Normalizes and validates records
- Computes statistics (totals, averages, peaks)
- Categories traffic situations (low/normal/high/heavy)

---

## 🔄 CI/CD Pipeline

### Automated Workflows (GitHub Actions)

1. **Test & Build** ✅
   - Builds Docker images
   - Runs health checks
   - Tests API endpoints

2. **Code Quality** ✨
   - Python syntax validation
   - Node.js syntax validation

3. **Security Scan** 🔒
   - Trivy vulnerability scanner
   - Reports to GitHub Security

4. **Docker Hub Push** 🐳
   - Pushes images to Docker Hub
   - Tags: `latest` + commit SHA
   - Runs on `main` branch push

### How to Setup
See [CI_CD_SETUP.md](./CI_CD_SETUP.md)

---

## 📈 API Endpoints

### Get All Traffic Records
```bash
curl http://localhost:3002/api/traffic
```
Response:
```json
{
  "count": 1000,
  "data": [
    {
      "time": "10:00",
      "date": "2024-01-15",
      "dayOfWeek": "Monday",
      "carCount": 150,
      "bikeCount": 45,
      "busCount": 12,
      "truckCount": 8,
      "total": 215,
      "trafficSituation": "normal"
    }
  ]
}
```

### Get Live Traffic Data
```bash
curl http://localhost:3002/api/traffic/live
```

### Send New Traffic Record
```bash
curl -X POST http://localhost:3002/api/traffic/live \
  -H "Content-Type: application/json" \
  -d '{
    "time": "10:05",
    "date": "2024-01-15",
    "dayOfWeek": "Monday",
    "carCount": 160,
    "bikeCount": 50,
    "busCount": 15,
    "truckCount": 10,
    "trafficSituation": "high"
  }'
```

---

## 🔐 Environment Variables

### Development
```env
NODE_ENV=development
PORT=3002
```

### Production
```env
NODE_ENV=production
PORT=3002
DOCKER_REGISTRY=your-docker-username
IMAGE_TAG=latest
```

---

## 📝 Configuration

### Docker Compose Environment
Create `.env` file:
```env
DOCKER_REGISTRY=lamaossama
IMAGE_TAG=latest
```

---

## 🐛 Troubleshooting

### Dashboard not accessible
- Check port 3002: `netstat -an | findstr :3002`
- Check Docker logs: `docker-compose logs traffic-dashboard`

### Data not updating
- Check Collector logs: `docker-compose logs traffic-collector`
- Verify CSV file exists: `traffic-dashboard/data/Traffic.csv`

### Build failures
- Check Dockerfiles for syntax
- Verify package.json and requirements are correct
- Check disk space: `docker system df`

---

## 🚢 Deployment

### Local Testing
```powershell
docker-compose up
```

### Production Deployment
```powershell
docker-compose -f docker-compose.prod.yml up -d
```

### Kubernetes Ready
Images can be deployed to Kubernetes with:
- Docker Hub images from CI/CD
- Health checks configured
- Environment variables supported

---

## 📚 Documentation

- [CI/CD Setup Guide](./CI_CD_SETUP.md) - GitHub Actions configuration
- [Local Testing Steps](./LOCAL_TEST_STEPS.md) - Manual testing guide
- [Docker Setup](./DOCKER_SETUP.md) - Docker configuration

---

## 👨‍💻 Development

### Add New Features
1. Make changes to code
2. Test locally: `docker-compose up`
3. Commit to feature branch
4. Push to GitHub
5. Create Pull Request
6. CI/CD automatically tests changes

### Build Manually
```powershell
docker-compose build

# Build specific service
docker-compose build traffic-dashboard
docker-compose build traffic-collector
```

---

## 📦 Technologies Used

- **Backend**: Node.js 16, Express 4.x
- **Data Processing**: Python 3.9, Pandas
- **Containerization**: Docker, Docker Compose
- **CI/CD**: GitHub Actions
- **Registry**: Docker Hub
- **Security**: Trivy Scanner
- **Frontend**: HTML5, CSS3, EJS Templates

---

## 📄 License

This project is part of an advanced DevOps curriculum.

---

## 👤 Author

- **Lama Ossama**
- GitHub: [@Lama-Ossama](https://github.com/Lama-Ossama)

---

## 🔗 Links

- [GitHub Repository](https://github.com/Lama-Ossama/-Intelligent-Traffic-Management-Dashboard)
- [Docker Hub](https://hub.docker.com/)
- [GitHub Actions Docs](https://docs.github.com/en/actions)

---

## ✨ Next Steps

1. ✅ Configure GitHub Secrets (DOCKER_HUB_USERNAME, DOCKER_HUB_TOKEN)
2. ✅ Push code to main branch
3. ✅ Monitor GitHub Actions pipeline
4. ✅ Check Docker Hub for pushed images
5. ✅ Deploy to production

