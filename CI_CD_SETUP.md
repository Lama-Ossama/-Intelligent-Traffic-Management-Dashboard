# GitHub Actions CI/CD Setup Guide

## Overview
This project uses GitHub Actions for automated CI/CD pipeline with the following jobs:

1. **Test & Build**: Build Docker images and run basic health checks
2. **Build & Push to Docker Hub**: Push images to Docker Hub (main branch only)
3. **Code Quality Check**: Syntax validation for Python and Node.js
4. **Security Scan**: Vulnerability scanning with Trivy

---

## Required GitHub Secrets

لتشغيل الـ CI/CD بنجاح، لازم تضيف الـ secrets التالية في GitHub:

### الخطوات:
1. اذهب لـ **GitHub Repo** → **Settings** → **Secrets and variables** → **Actions**
2. اضغط **New repository secret** وأضيف:

### الـ Secrets المطلوبة:

#### 1. **DOCKER_HUB_USERNAME**
- **Value**: اسم المستخدم في Docker Hub (مثال: `lama-ossama`)
- اضغط **Add secret**

#### 2. **DOCKER_HUB_TOKEN**
- **Value**: Access Token من Docker Hub (ليس password!)
  
  **كيفية الحصول على Token:**
  1. اذهب لـ https://hub.docker.com/
  2. اذهب لـ **Account Settings** → **Security** → **Personal access tokens**
  3. اضغط **Create Token**
  4. أختر **Read, Write** permissions
  5. انسخ الـ Token وضيفه في GitHub

---

## Pipeline Triggers

الـ workflow يشتغل تلقائياً عند:

### اليوم اللي يحصل:
- ✅ **Push على `main`**: Test → Build → Push to Docker Hub
- ✅ **Push على `develop`**: Test → Build (بدون push)
- ✅ **Pull Request**: Test + Code Quality Check

---

## المراحل بالتفصيل:

### 1️⃣ Test & Build
```yaml
- بناء الـ Docker images
- تشغيل الـ containers
- اختبار الـ API endpoints
```

### 2️⃣ Build & Push to Docker Hub
```yaml
- يشتغل بس عند push على main
- يبني الـ images
- يرسلهم لـ Docker Hub
- Tags: latest + commit SHA
```

### 3️⃣ Code Quality
```yaml
- فحص Python syntax (traffic-collector)
- فحص Node.js syntax (traffic-dashboard)
```

### 4️⃣ Security Scan
```yaml
- Trivy vulnerability scanner
- يفحص الـ Docker images
- يرفع النتائج في GitHub Security tab
```

---

## Example: البيانات المُرسلة لـ Docker Hub

بعد Push على `main`، الـ images هتكون:

```
docker pull lamaossama/traffic-collector:latest
docker pull lamaossama/traffic-collector:abc123def456...

docker pull lamaossama/traffic-dashboard:latest
docker pull lamaossama/traffic-dashboard:abc123def456...
```

---

## قراءة النتائج

### في GitHub Actions:
1. اذهب لـ **Actions** tab
2. اختر الـ workflow الأخير
3. شوف النتائج:
   - ✅ Green = نجح
   - ❌ Red = فشل

### في Docker Hub:
1. اذهب لـ https://hub.docker.com/
2. شوف الـ repositories الجديدة
3. كل push = new tag

---

## Troubleshooting

### لو الـ push فشل:
1. تأكد من الـ DOCKER_HUB_TOKEN صحيح
2. تأكد من Docker Hub username صحيح
3. في الـ workflow logs تحت **Actions** تشوف الـ error

### لو الـ tests فشلت:
1. تأكد إن الـ containers بتشتغل محلياً
2. تأكد من الـ ports صحيحة (3001, 3002)

---

## ملاحظات:

- الـ workflow يشتغل **اتوماتيكي** لكل commit
- مفيش حاجة لـ manual trigger (لكن ممكن نضيفها)
- الـ build images استغرق ~5-10 دقائق أول مرة
