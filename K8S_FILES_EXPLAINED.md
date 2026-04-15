# Kubernetes Files Explanation

## 📂 k8s/ Folder Structure

```
k8s/
├── 01-namespace.yaml
├── 02-secrets-configmap.yaml
├── 03-traffic-collector.yaml
├── 04-traffic-dashboard.yaml
└── kustomization.yaml
```

---

## 📄 كل ملف بتفاصيله:

### 1️⃣ **01-namespace.yaml** 🏠

**المهمة**: إنشاء مساحة معزولة في الـ Kubernetes cluster

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: traffic-system
  labels:
    name: traffic-system
```

**معنى ده:**
- `kind: Namespace` = إنشاء namespace جديد
- `name: traffic-system` = اسم المساحة المعزولة
- **الفائدة**: كل الـ resources بتاعتك (pods, services, etc) بتكون في namespace واحد معزول

**لماذا؟**
- عزل تطبيقك عن التطبيقات التانية
- تنظيم أفضل
- سهل الحذف (احذف الـ namespace بتحذف كل حاجة جواه)

**مثال الاستخدام:**
```powershell
# شاهد كل الموارد في الـ namespace
kubectl get all -n traffic-system

# حذف الـ namespace (وكل حاجة جواه!)
kubectl delete namespace traffic-system
```

---

### 2️⃣ **02-secrets-configmap.yaml** 🔐

**المهمة**: تخزين الإعدادات والبيانات الحساسة

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: docker-hub-secret
  namespace: traffic-system
type: kubernetes.io/dockercfg
stringData:
  .dockercfg: |
    {
      "auths": {
        "docker.io": {
          "auth": "USERNAME_AND_TOKEN_BASE64_ENCODED"
        }
      }
    }

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: traffic-config
  namespace: traffic-system
data:
  NODE_ENV: "production"
  COLLECTOR_HOST: "traffic-collector"
  COLLECTOR_PORT: "3001"
  DASHBOARD_HOST: "traffic-dashboard"
  DASHBOARD_PORT: "3002"
```

**جزء 1: Secret (البيانات الحساسة)**
- **docker-hub-secret**: تخزين بيانات Docker Hub (اسم المستخدم والـ token)
- **الهدف**: حتى لو في حد شاف الـ manifest، ما يشوف الـ password
- **الاستخدام**: الـ pods بتستخدمه لـ سحب الـ images من Docker Hub

**جزء 2: ConfigMap (الإعدادات العامة)**
- `NODE_ENV`: "production" - نوع البيئة
- `COLLECTOR_HOST`: "traffic-collector" - اسم الـ service بتاع الـ Collector
- `DASHBOARD_HOST`: "traffic-dashboard" - اسم الـ service بتاع الـ Dashboard
- `PORTS`: الـ ports اللي يستخدموها

**الفرق:**
- **Secret**: للـ data الحساسة (passwords, tokens)
- **ConfigMap**: للـ configuration العامة

**الاستخدام:**
```powershell
# شاهد الـ secrets
kubectl get secrets -n traffic-system

# شاهد الـ configmaps
kubectl get configmaps -n traffic-system

# شاهد التفاصيل
kubectl describe secret docker-hub-secret -n traffic-system
```

---

### 3️⃣ **03-traffic-collector.yaml** 📊

**المهمة**: تشغيل الـ Traffic Collector (Python app)

**الأقسام الرئيسية:**

#### **Deployment Section**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: traffic-collector
  namespace: traffic-system
spec:
  replicas: 1                    # كم pod بتشتغل؟
  selector:
    matchLabels:
      app: traffic-collector
  template:
    # تفاصيل الـ pod
```

- `replicas: 1` = واحد pod بس (الـ collector مش محتاج أكتر)
- **الفائدة**: إدارة تلقائية للـ pods

#### **Pod Template**
```yaml
containers:
- name: traffic-collector
  image: mohamedosama2004/traffic-collector:latest
  imagePullPolicy: Always
```

- `image`: الـ Docker image للـ collector
- `imagePullPolicy: Always`: دايماً سحب أحدث version

#### **Health Checks**
```yaml
livenessProbe:
  exec:
    command:
    - /bin/sh
    - -c
    - ps aux | grep app.py || exit 1
  initialDelaySeconds: 30
  periodSeconds: 10
  failureThreshold: 3
```

- **Liveness Probe**: هل الـ app حي؟
- كل 10 ثواني: تفحص لو الـ process شغال
- لو فشل 3 مرات: اعمل restart

```yaml
readinessProbe:
  exec:
    command:
    - /bin/sh
    - -c
    - ps aux | grep app.py || exit 1
  initialDelaySeconds: 10
  periodSeconds: 5
  failureThreshold: 2
```

- **Readiness Probe**: هل الـ app جاهز للـ traffic؟
- كل 5 ثواني: تفحص
- لو فشل مرتين: شيلها من الـ load balancer

#### **Service Section**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: traffic-collector
  namespace: traffic-system
spec:
  type: ClusterIP
  ports:
  - port: 3001
    targetPort: 3001
```

- `kind: Service` = طريقة الـ وصول للـ pod
- `type: ClusterIP` = داخلي فقط (ما في وصول من برا الـ cluster)
- `port: 3001` = الـ port الخارجي
- `targetPort: 3001` = الـ port الداخلي للـ container

**الفائدة**: الـ Dashboard يقدر يقول "traffic-collector:3001" بدل الـ IP

---

### 4️⃣ **04-traffic-dashboard.yaml** 🎨

**المهمة**: تشغيل الـ Traffic Dashboard (Node.js app) + Auto-Scaling

#### **Deployment Section**
```yaml
spec:
  replicas: 2                    # 2 pods من البداية
```

- `replicas: 2` = اتنين pod (load balancing)
- **الفائدة**: لو واحد وقع، التاني بيكمل

#### **Health Checks** (أكتر شمولاً)
```yaml
livenessProbe:
  httpGet:
    path: /
    port: 3002
  periodSeconds: 10
  failureThreshold: 3

readinessProbe:
  httpGet:
    path: /
    port: 3002
  periodSeconds: 5
  failureThreshold: 2

startupProbe:
  httpGet:
    path: /
    port: 3002
  failureThreshold: 30
```

- **Liveness**: هل الـ server رد على الـ HTTP request؟
- **Readiness**: هل الـ server جاهز يخدم؟
- **Startup**: وقت إضافي للـ app تبدأ

#### **Service Section**
```yaml
apiVersion: v1
kind: Service
type: LoadBalancer
ports:
- port: 3002
  targetPort: 3002
```

- `type: LoadBalancer` = accessible من برا الـ cluster (الـ world)
- **الفائدة**: يمكن الـ وصول من المتصفح على `http://localhost:3002`

#### **HorizontalPodAutoscaler (HPA)**
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: traffic-dashboard-hpa
spec:
  scaleTargetRef:
    kind: Deployment
    name: traffic-dashboard
  minReplicas: 2
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        averageUtilization: 80
```

**معنى ده:**
- ابدأ بـ 2 pods
- لو الـ CPU وصل 70% أو Memory وصل 80%: أضف pod جديد
- لا تتعدى 5 pods
- لو استهلاك قل: قلل الـ pods

**مثال:**
```
اليوم العادي:
├─ 2 pods
└─ CPU: 40% ✅

اليوم الـ busy:
├─ Collector يرسل كتير
├─ CPU ارتفع لـ 75%
├─ Kubernetes: "CPU عالي! أضيف pod جديد"
├─ 3 pods الآن
└─ CPU انخفض لـ 50% ✅
```

---

### 5️⃣ **kustomization.yaml** 🧩

**المهمة**: تسهيل الـ deployment (اختياري)

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: traffic-system

resources:
  - 01-namespace.yaml
  - 02-secrets-configmap.yaml
  - 03-traffic-collector.yaml
  - 04-traffic-dashboard.yaml

commonLabels:
  app.kubernetes.io/name: intelligent-traffic-management
  app.kubernetes.io/version: "1.0.0"
  app.kubernetes.io/part-of: traffic-system
```

**الفائدة:**
- بدل `kubectl apply -f 01... 02... 03...`
- استخدم: `kubectl apply -k k8s/`
- يضيف labels وإعدادات عامة تلقائياً

---

## 🔗 كيف يشتغلون مع بعض:

```
kustomization.yaml
├─ 01-namespace.yaml
│  └─ ينشئ: traffic-system namespace
│
├─ 02-secrets-configmap.yaml
│  ├─ ينشئ: docker-hub-secret (للـ image pull)
│  └─ ينشئ: traffic-config (للـ environment variables)
│
├─ 03-traffic-collector.yaml
│  ├─ Deployment:
│  │  ├─ Image: mohamedosama2004/traffic-collector:latest
│  │  ├─ Replicas: 1
│  │  ├─ Health Checks: Liveness + Readiness
│  │  └─ Auto-Restart: YES
│  └─ Service: ClusterIP (internal only)
│
└─ 04-traffic-dashboard.yaml
   ├─ Deployment:
   │  ├─ Image: mohamedosama2004/traffic-dashboard:latest
   │  ├─ Replicas: 2
   │  ├─ Health Checks: Liveness + Readiness + Startup
   │  └─ Auto-Restart: YES
   ├─ Service: LoadBalancer (external access)
   └─ HPA: Auto-scale 2-5 pods
```

---

## 📊 ملخص سريع:

| الملف | النوع | الوظيفة |
|------|-------|--------|
| 01 | Namespace | عزل التطبيق |
| 02 | Secret + ConfigMap | إعدادات وكريدنشيالز |
| 03 | Deployment + Service | شغل الـ Collector |
| 04 | Deployment + Service + HPA | شغل الـ Dashboard مع auto-scaling |
| Kustomization | Manifest Tool | تسهيل الـ deployment |

---

## 🚀 كيفية الـ Deployment:

```powershell
# الطريقة 1: ملف ملف (طويل)
kubectl apply -f k8s/01-namespace.yaml
kubectl apply -f k8s/02-secrets-configmap.yaml
kubectl apply -f k8s/03-traffic-collector.yaml
kubectl apply -f k8s/04-traffic-dashboard.yaml

# الطريقة 2: كل شيء مرة (سهل)
kubectl apply -k k8s/

# أو
kubectl apply -f k8s/
```

---

## 🔍 كيف تشاهد ما تم إنشاؤه:

```powershell
# الـ namespaces
kubectl get ns

# الـ resources في الـ namespace
kubectl get all -n traffic-system

# التفاصيل
kubectl describe deployment traffic-collector -n traffic-system
kubectl describe deployment traffic-dashboard -n traffic-system
kubectl describe hpa -n traffic-system
```

