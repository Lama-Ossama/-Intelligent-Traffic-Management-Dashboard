# Kubernetes Monitoring & Troubleshooting Guide

## 👀 كيف تشوف الـ Pods بالضبط

### 1️⃣ شاهد جميع الـ Pods

```powershell
# شاهد الـ pods في namespace معين
kubectl get pods -n traffic-system

# OUTPUT:
# NAME                                    READY   STATUS    RESTARTS   AGE
# traffic-collector-6d8f7c4f9-abc12      1/1     Running   0          5m
# traffic-dashboard-7b4c5d3e8-def45      1/1     Running   0          5m
# traffic-dashboard-7b4c5d3e8-ghi67      1/1     Running   0          5m
```

**معنى الـ Columns:**
- `NAME`: اسم الـ pod
- `READY`: عدد الـ containers جاهزة / المجموع
- `STATUS`: حالة الـ pod (Running, Pending, CrashLoopBackOff, إلخ)
- `RESTARTS`: كم مرة اتعمل restart
- `AGE`: متى اتنشأ

---

### 2️⃣ شاهد تفاصيل Pod معين

```powershell
# اختار اسم الـ pod من الـ output أعلى
kubectl describe pod <POD_NAME> -n traffic-system

# مثال:
kubectl describe pod traffic-dashboard-7b4c5d3e8-def45 -n traffic-system

# يعطيك:
# Name:         traffic-dashboard-7b4c5d3e8-def45
# Namespace:    traffic-system
# Status:       Running
# IP:           10.244.0.5
# Node:         docker-desktop
# 
# Containers:
#   traffic-dashboard:
#     Image:        mohamedosama2004/traffic-dashboard:latest
#     Port:         3002/TCP
#     State:        Running
#     Started:      Tue, 15 Apr 2026 20:30:00 +0000
#
# Events:
#   Type    Reason     Age    From               Message
#   ----    ------     ----   ----               -------
#   Normal  Scheduled  5m     default-scheduler  Successfully assigned
#   Normal  Pulling    5m     kubelet            Pulling image "mohamedosama..."
#   Normal  Pulled     4m30s  kubelet            Image pulled
#   Normal  Created    4m30s  kubelet            Created container
#   Normal  Started    4m30s  kubelet            Started container
```

---

### 3️⃣ شاهد الـ Logs (ماذا يطبع التطبيق)

```powershell
# شاهد logs من pod معين
kubectl logs <POD_NAME> -n traffic-system

# مثال:
kubectl logs traffic-collector-6d8f7c4f9-abc12 -n traffic-system

# OUTPUT:
# Starting Traffic Collector...
# Time: 10:00 | Date: 2024-01-15 | Day: Monday | 
# Cars: 150 | Bikes: 45 | Buses: 12 | Trucks: 8 | 
# Total: 215 | Situation: normal
# ✓ Data sent successfully
```

```powershell
# شاهد آخر 50 سطر فقط
kubectl logs <POD_NAME> -n traffic-system --tail=50

# شاهد الـ logs بـ real-time (stream)
kubectl logs -f <POD_NAME> -n traffic-system

# شاهد logs مع timestamps
kubectl logs <POD_NAME> -n traffic-system --timestamps=true

# شاهد logs من container معين (لو في أكتر من واحد)
kubectl logs <POD_NAME> -n traffic-system -c <CONTAINER_NAME>
```

---

### 4️⃣ شاهد الـ Deployments

```powershell
kubectl get deployments -n traffic-system

# OUTPUT:
# NAME                  READY   UP-TO-DATE   AVAILABLE   AGE
# traffic-collector     1/1     1            1           10m
# traffic-dashboard     2/2     2            2           10m
```

---

### 5️⃣ شاهد الـ Services

```powershell
kubectl get services -n traffic-system

# OUTPUT:
# NAME                  TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)
# traffic-collector     ClusterIP      10.96.100.200   <none>        3001/TCP
# traffic-dashboard     LoadBalancer   10.96.100.201   localhost     3002:30123/TCP
```

---

### 6️⃣ شاهد الـ HPA (Auto-Scaling)

```powershell
kubectl get hpa -n traffic-system

# OUTPUT:
# NAME                       REFERENCE                     TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
# traffic-dashboard-hpa      Deployment/traffic-dashboard  45%/70%, 30%/80%   2         5         2          10m

# شاهد تفاصيل أكتر
kubectl describe hpa traffic-dashboard-hpa -n traffic-system

# شاهد بـ real-time
kubectl get hpa -n traffic-system -w
```

---

### 7️⃣ شاهد الـ Events (ماذا حصل)

```powershell
# شاهد جميع الـ events
kubectl get events -n traffic-system

# مثال:
# LAST SEEN   TYPE     REASON              OBJECT                         MESSAGE
# 10m         Normal   Scheduled           pod/traffic-dashboard-abc      Successfully assigned
# 10m         Normal   Pulling             pod/traffic-dashboard-abc      Pulling image
# 9m50s       Normal   Pulled              pod/traffic-dashboard-abc      Successfully pulled
# 9m50s       Normal   Created             pod/traffic-dashboard-abc      Created container
# 9m50s       Normal   Started             pod/traffic-dashboard-abc      Started container

# شاهد events مع sorting حسب الـ time
kubectl get events -n traffic-system --sort-by='.lastTimestamp'
```

---

## 🔴 حالات الـ Status و معانيها

| Status | المعنى | الحل |
|--------|--------|------|
| `Running` | ✅ الـ pod شغال تمام | كل شيء تمام |
| `Pending` | ⏳ الـ pod بينتظر resource | شوف الـ describe |
| `CrashLoopBackOff` | ❌ الـ app بتتعطل وتعمل restart | شوف الـ logs |
| `ImagePullBackOff` | ❌ مشكلة في سحب الـ image | تأكد من الـ Docker secret |
| `Terminating` | 🛑 الـ pod بتتوقف | انتظر شوية |

---

## 🧪 اختبر الـ Restart

### اعمل delete للـ pod عشان تختبر الـ auto-restart:

```powershell
# اعرض الـ pods الأولى
kubectl get pods -n traffic-system

# احفظ اسم الـ pod (مثلاً traffic-dashboard-7b4c5d3e8-def45)

# اعمل delete
kubectl delete pod <POD_NAME> -n traffic-system

# شاهد الـ pods تاني - هتشوف واحد جديد بـ age قليل!
kubectl get pods -n traffic-system

# هتشوف:
# traffic-dashboard-7b4c5d3e8-ghi67    0/1     Creating   0          2s
```

الـ pod القديم اتحذف والـ Kubernetes بنى واحد جديد تلقائياً! ✅

---

## 📊 شاهد الـ Resources Usage

```powershell
# شاهد CPU و Memory بتاع كل pod
kubectl top pods -n traffic-system

# OUTPUT:
# NAME                                    CPU(m)   MEMORY(Mi)
# traffic-collector-6d8f7c4f9-abc12      50m      120Mi
# traffic-dashboard-7b4c5d3e8-def45      100m     250Mi
# traffic-dashboard-7b4c5d3e8-ghi67      95m      240Mi

# شاهد resources بتاع كل node
kubectl top nodes
```

---

## 🔍 Dashboard Kubernetes (UI)

```powershell
# بدل من الـ commands بتاعتك، استخدم dashboard
kubectl proxy

# بعدين روح:
# http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/

# أو استخدم Lens (UI أفضل)
# Download من: https://k8slens.dev/
```

---

## ⚡ Quick Commands Cheatsheet

```powershell
# الأوامر الأساسية
kubectl get pods -n traffic-system                    # عرض الـ pods
kubectl describe pod <NAME> -n traffic-system         # تفاصيل pod
kubectl logs <NAME> -n traffic-system                 # logs
kubectl logs -f <NAME> -n traffic-system              # real-time logs
kubectl delete pod <NAME> -n traffic-system           # اعمل delete
kubectl get events -n traffic-system                  # الـ events
kubectl get svc -n traffic-system                     # الـ services
kubectl get hpa -n traffic-system                     # الـ HPA status
kubectl top pods -n traffic-system                    # الـ resources

# شاهد كل شيء مرة واحدة
kubectl get all -n traffic-system

# شاهد بـ real-time (watching)
kubectl get pods -n traffic-system -w

# اعمل port-forward للـ وصول المباشر
kubectl port-forward svc/traffic-dashboard 3002:3002 -n traffic-system
# روح: http://localhost:3002
```

---

## 🎯 خطة التتابع:

1. **شاهد الـ pods:**
   ```powershell
   kubectl get pods -n traffic-system
   ```

2. **شاهد الـ status:**
   ```powershell
   kubectl describe pod <NAME> -n traffic-system
   ```

3. **شاهد الـ logs:**
   ```powershell
   kubectl logs <NAME> -n traffic-system
   ```

4. **اختبر الـ restart:**
   ```powershell
   kubectl delete pod <NAME> -n traffic-system
   ```

5. **شاهد الـ pod الجديد:**
   ```powershell
   kubectl get pods -n traffic-system
   ```

---

## 🚨 لو في مشكلة:

```powershell
# 1. شاهد الـ pod الحالي
kubectl describe pod <NAME> -n traffic-system

# 2. شاهد الـ logs
kubectl logs <NAME> -n traffic-system

# 3. شاهد الـ events
kubectl get events -n traffic-system --sort-by='.lastTimestamp'

# 4. شاهد الـ deployment
kubectl describe deployment <NAME> -n traffic-system

# 5. شاهد الـ node
kubectl get nodes
kubectl describe node <NODE_NAME>
```

