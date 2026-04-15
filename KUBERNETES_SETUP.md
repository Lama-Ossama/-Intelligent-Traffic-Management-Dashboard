# Kubernetes Deployment Guide

## Overview

هذا الدليل يشرح كيفية نشر التطبيق على Kubernetes cluster مع:
- ✅ Auto-restart للـ pods اللي بتقع
- ✅ Load balancing بين الـ pods
- ✅ Auto-scaling عند ارتفاع الحمل
- ✅ Health checks (liveness & readiness probes)
- ✅ Resource management (CPU/Memory)

---

## 📋 الملفات المطلوبة

```
k8s/
├── 01-namespace.yaml           # Kubernetes namespace
├── 02-secrets-configmap.yaml   # Configuration & Docker Hub secrets
├── 03-traffic-collector.yaml   # Collector deployment
└── 04-traffic-dashboard.yaml   # Dashboard deployment + HPA
```

---

## 🚀 Quick Start

### الخطوة 1: تثبيت kubectl و minikube (لو محلي)

```powershell
# Windows - استخدام Chocolatey
choco install minikube kubectl

# أو تحميل يدوي من:
# kubectl: https://kubernetes.io/docs/tasks/tools/
# minikube: https://minikube.sigs.k8s.io/docs/start/
```

### الخطوة 2: تشغيل Kubernetes cluster

#### Option A: Minikube (local)
```powershell
minikube start
minikube docker-env
```

#### Option B: Docker Desktop (built-in K8s)
1. افتح **Docker Desktop**
2. اذهب لـ **Settings** → **Kubernetes**
3. Enable Kubernetes
4. اضغط **Apply & Restart**

#### Option C: Cloud (AWS EKS / GCP GKE)
```bash
# AWS EKS example
aws eks create-cluster --name traffic-cluster --version 1.27
aws eks update-kubeconfig --name traffic-cluster
```

### الخطوة 3: تعديل Docker Hub Secrets

قبل الـ deploy، عدّل الـ secret في `02-secrets-configmap.yaml`:

```bash
# Generate base64 encoded Docker credentials
echo -n '{"mohamedosama2004": {"auth": "YOUR_BASE64_TOKEN"}}' | base64

# استخدم الناتج في الـ file
```

### الخطوة 4: Deploy على Kubernetes

```powershell
# تطبيق جميع الـ manifests
kubectl apply -f k8s/

# أو تطبيق file بـ file
kubectl apply -f k8s/01-namespace.yaml
kubectl apply -f k8s/02-secrets-configmap.yaml
kubectl apply -f k8s/03-traffic-collector.yaml
kubectl apply -f k8s/04-traffic-dashboard.yaml
```

### الخطوة 5: التحقق من الـ deployment

```powershell
# عرض جميع الـ pods
kubectl get pods -n traffic-system

# عرض الـ deployments
kubectl get deployments -n traffic-system

# عرض الـ services
kubectl get services -n traffic-system

# عرض الـ HPA status
kubectl get hpa -n traffic-system

# شاهد logs من pod معين
kubectl logs -n traffic-system <pod-name>

# شاهد events
kubectl get events -n traffic-system
```

### الخطوة 6: الوصول للتطبيق

#### لو Minikube:
```powershell
minikube service traffic-dashboard -n traffic-system
```

#### لو Docker Desktop:
```
http://localhost:3002
```

#### لو Cloud (AWS EKS):
```powershell
kubectl get svc -n traffic-system
# Copy الـ EXTERNAL-IP وروح عليه
```

---

## 🔍 Kubernetes Features المستخدمة

### 1. **Namespace**
- عزل التطبيق في namespace خاص: `traffic-system`
- يسهل الإدارة والتنظيم

### 2. **Deployment**
- `replicas: 1` للـ Collector (واحد كفاية)
- `replicas: 2` للـ Dashboard (load balancing)
- Auto-restart: `restartPolicy: Always`

### 3. **Health Checks**

#### **Liveness Probe** (هل الـ pod حي؟)
```yaml
livenessProbe:
  httpGet:
    path: /
    port: 3002
  periodSeconds: 10        # تفحص كل 10 ثواني
  failureThreshold: 3      # 3 فشل = restart
```

#### **Readiness Probe** (هل جاهز للتوزيع؟)
```yaml
readinessProbe:
  httpGet:
    path: /
    port: 3002
  periodSeconds: 5         # تفحص كل 5 ثواني
  failureThreshold: 2      # 2 فشل = remove from load balancer
```

### 4. **Service**
- `ClusterIP` للـ Collector (داخلي فقط)
- `LoadBalancer` للـ Dashboard (accessible من خارج)

### 5. **HorizontalPodAutoscaler (HPA)**
- Auto-scale dashboard من 2 إلى 5 pods
- عند وصول CPU لـ 70% أو Memory لـ 80%

### 6. **Resource Management**
```yaml
resources:
  requests:
    memory: "256Mi"    # minimum
    cpu: "200m"
  limits:
    memory: "512Mi"    # maximum
    cpu: "1000m"
```

---

## 📊 لو Pod وقع (Restart)

```
Pod يقع
    ↓
Kubernetes يشوف الـ liveness probe فشل
    ↓
يعداد العد للـ 3 failures
    ↓
بعد 3 failures → يعمل restart للـ pod
    ↓
pod جديد يشتغل
    ↓
يتفحص الـ readiness probe
    ↓
لما يصبح ready → يتدرج في load balancer
```

---

## 🚀 Scaling (التكبير)

### Manual Scaling
```powershell
# زيادة replicas للـ dashboard
kubectl scale deployment traffic-dashboard -n traffic-system --replicas=5

# شاهد الـ scaling
kubectl get pods -n traffic-system
```

### Auto-Scaling (HPA)
الـ HPA موجود في الـ config ويعمل تلقائياً:
```powershell
# شاهد HPA status
kubectl get hpa -n traffic-system -w

# شاهد metrics
kubectl top pods -n traffic-system
```

---

## 📈 Monitoring

```powershell
# شاهد تفاصيل deployment
kubectl describe deployment traffic-dashboard -n traffic-system

# شاهد events
kubectl get events -n traffic-system --sort-by='.lastTimestamp'

# Stream logs من pod
kubectl logs -f <pod-name> -n traffic-system

# Port-forward للوصول المباشر
kubectl port-forward svc/traffic-dashboard 3002:3002 -n traffic-system
```

---

## 🧹 التنظيف

```powershell
# Delete جميع الموارد
kubectl delete namespace traffic-system

# أو delete selective
kubectl delete deployment traffic-dashboard -n traffic-system
kubectl delete service traffic-dashboard -n traffic-system
```

---

## 🔧 Troubleshooting

### Pod stuck في Pending
```powershell
kubectl describe pod <pod-name> -n traffic-system
# شاهد الـ events للمشكلة
```

### Pod CrashLoopBackOff
```powershell
kubectl logs <pod-name> -n traffic-system
# شاهد الـ error logs
```

### Image Pull Error
```powershell
# تأكد من Docker Hub secret صحيح
kubectl get secret docker-hub-secret -n traffic-system -o yaml
```

### Service بدون IP خارجي (minikube)
```powershell
minikube service traffic-dashboard -n traffic-system
# يفتح الـ service تلقائياً في المتصفح
```

---

## 📚 ملفات اضافية (اختيارية)

### Ingress (للـ production)
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: traffic-ingress
  namespace: traffic-system
spec:
  rules:
  - host: traffic.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: traffic-dashboard
            port:
              number: 3002
```

### Network Policy (للـ security)
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: traffic-network-policy
  namespace: traffic-system
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

---

## 🎯 التالي

1. Deploy على Kubernetes
2. مراقبة الـ pods والـ services
3. Test restart: `kubectl delete pod <pod-name> -n traffic-system`
4. Scale up: `kubectl scale deployment traffic-dashboard -n traffic-system --replicas=5`
5. Setup CI/CD للـ Kubernetes deployments

