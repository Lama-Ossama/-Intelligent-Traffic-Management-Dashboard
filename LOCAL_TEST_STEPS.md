# Local Testing Guide — خطوات التجربة المحلية

## الخطوة 1️⃣: تحضير البيئة

### 1.1 افتح PowerShell وتأكد من وجود Docker
```powershell
# اختبر تثبيت Docker
docker --version
docker-compose --version
```

**النتيجة المتوقعة:**
```
Docker version 20.10.x
Docker Compose version 1.29.x (or 2.x)
```

---

## الخطوة 2️⃣: الانتقال لمجلد المشروع

```powershell
# انتقل لمجلد المشروع
cd \\wsl.localhost\Ubuntu\root\-Intelligent-Traffic-Management-Dashboard

# تأكد أنك في المكان الصحيح
ls
```

**يجب أن تشوف:**
```
Mode                 Name
----                 ----
d-----           traffic-collector
d-----           traffic-dashboard
-a----           docker-compose.yml
-a----           README.md
-a----           DOCKER_SETUP.md
```

---

## الخطوة 3️⃣: بناء الصور (Building Images)

### 3.1 بناء الصورتين
```powershell
# اترك PowerShell بندوة كاملة
docker-compose build
```

**ماذا يحدث:**
- Docker يقرأ docker-compose.yml
- يبني صورة traffic-collector من Dockerfile
- يبني صورة traffic-dashboard من Dockerfile
- يحفظ الصور محليا

**ستشوف شيء زي:**
```
Building traffic-collector
Step 1/9 : FROM python:3.9-slim
Step 2/9 : WORKDIR /app
...
Successfully built xyz123
Successfully tagged traffic-collector:latest

Building traffic-dashboard
Step 1/8 : FROM node:20-alpine
...
Successfully built abc456
Successfully tagged traffic-dashboard:latest
```

**الوقت المتوقع:** 2-5 دقائق (المرة الأولى أطول)

---

## الخطوة 4️⃣: تشغيل الحاويات (Run Containers)

### 4.1 ابدأ الخدمات
```powershell
docker-compose up
```

**ستشوف logs مشابهة:**
```
traffic-collector  | Starting Traffic Collector...
traffic-collector  | Time: 08:15 | Date: 01/01/2024 | Day: Monday | Cars: 45 | Bikes: 12 | ...
traffic-collector  | Time: 08:30 | Date: 01/01/2024 | Day: Monday | Cars: 52 | Bikes: 15 | ...

traffic-dashboard  | Traffic Dashboard running at http://localhost:3002
```

✅ **النجاح:** الخدمات تعمل!

### 4.2 افتح نافذة PowerShell ثانية (بدون إغلاق الأولى)

```powershell
# النافذة الثانية - للاختبار
cd \\wsl.localhost\Ubuntu\root\-Intelligent-Traffic-Management-Dashboard

# اختبر الحاويات تعمل
docker-compose ps
```

**الناتج المتوقع:**
```
NAME                  STATUS              PORTS
traffic-collector     Up 1 minute         
traffic-dashboard     Up 1 minute         0.0.0.0:3002->3002/tcp
```

---

## الخطوة 5️⃣: اختبر الـ Dashboard في المتصفح

### 5.1 افتح متصفحك
اذهب إلى:
```
http://localhost:3002
```

**ماذا تتوقع أن تشوف:**
- Header يقول "ITMD - Intelligent Traffic Management Dashboard"
- بطاقات تعرض:
  - ✓ Total Records (عدد السجلات)
  - ✓ Total Vehicles (إجمالي المركبات)
  - ✓ Avg Vehicles / Interval (المتوسط)
  - ✓ Peak Traffic (ذروة المرور)
- جدول بآخر 50 سجل مرور
- رسوم بيانية لحالات المرور (Low/Normal/High/Heavy)

---

## الخطوة 6️⃣: اختبر الـ API

### 6.1 في PowerShell الثانية
```powershell
# اختبر الـ API endpoint
curl http://localhost:3002/api/traffic
```

**أو استخدم Invoke-WebRequest:**
```powershell
$response = Invoke-WebRequest -Uri http://localhost:3002/api/traffic
$response.Content | ConvertFrom-Json | Select-Object -First 1
```

**النتيجة المتوقعة:**
```json
{
  "count": 1000,
  "data": [
    {
      "time": "08:15",
      "date": "01/01/2024",
      "dayOfWeek": "Monday",
      "carCount": 45,
      "bikeCount": 12,
      ...
    }
  ]
}
```

---

## الخطوة 7️⃣: شوف الـ Logs بالتفصيل

### 7.1 في PowerShell الثانية

```powershell
# شوف logs الـ Dashboard فقط (آخر 50 سطر)
docker-compose logs --tail=50 traffic-dashboard

# شوف logs الـ Collector فقط
docker-compose logs --tail=50 traffic-collector

# شوف logs الاتنين معا (مع التحديث الحي)
docker-compose logs -f
```

---

## الخطوة 8️⃣: اختبر التواصل بين الحاويات

### 8.1 ادخل بداخل الـ Dashboard Container

```powershell
# ادخل إلى الـ container
docker exec -it traffic-dashboard sh

# بداخل الـ container
ls -la
cat server.js | head -20
exit
```

### 8.2 ادخل بداخل الـ Collector Container

```powershell
docker exec -it traffic-collector bash

# بداخل الـ container
ls -la
cat app.py
python --version
exit
```

---

## الخطوة 9️⃣: اختبر الشبكة بينهم

### 9.1 اختبر الاتصال بين الحاويات

```powershell
# من داخل dashboard، جرّب ping الـ collector
docker exec -it traffic-dashboard sh
ping traffic-collector

# يجب أن تشوف (بدون errors):
# PING traffic-collector (172.xx.0.x) 56(84) bytes of data
# 64 bytes from traffic-collector: icmp_seq=1 time=0.xxx ms
exit
```

---

## الخطوة 🔟: اختبر البيانات تتحدث

### 10.1 تحقق من CSV محدثة

```powershell
# شوف حجم الـ CSV (يجب أن يكون موجود)
ls -l traffic-collector/Traffic.csv
ls -l traffic-dashboard/data/Traffic.csv

# شوف أول 5 أسطر
head -5 traffic-collector/Traffic.csv
```

---

## خطوة الـ 1️⃣1️⃣: التنظيف والإيقاف

### 11.1 إيقاف الحاويات (عندما تخلص من الاختبار)

```powershell
# في نفس PowerShell التي بدأت بها docker-compose up
# اضغط Ctrl+C

# أو من PowerShell ثانية
docker-compose down

# تأكد أن الحاويات توقفت
docker-compose ps

# لحذف الـ volumes أيضا
docker-compose down -v
```

---

## ملاحظات مهمة ⚠️

### اذا حصلت مشاكل:

**المشكلة 1: Port 3002 مستخدم**
```powershell
# اختبر من استخدمها
Get-NetTCPConnection -LocalPort 3002

# غيّر البورت في docker-compose.yml
# ports:
#   - "3003:3002"
```

**المشكلة 2: Docker لم يبدأ**
```powershell
# أعد تشغيل Docker Desktop
# أو في WSL
wsl --shutdown
```

**المشكلة 3: CSV file not found**
```powershell
# تأكد الملفات موجودة
ls traffic-collector/Traffic.csv
ls traffic-dashboard/data/Traffic.csv
```

**المشكلة 4: Container keeps restarting**
```powershell
# شوف الـ logs بالتفصيل
docker-compose logs traffic-dashboard
```

---

## النتيجة النهائية ✅

بعد كل هذا، يجب أن تشوف:
1. ✅ Dashboard يشتغل على localhost:3002
2. ✅ بيانات مرور تعرض بشكل صحيح
3. ✅ API ترد JSON
4. ✅ حاويتان متصلتان عبر الشبكة
5. ✅ Logs تظهر بدون أخطاء

---

## الخطوة التالية

لما تتأكد كل شيء يعمل:
1. احفظ الصور في Docker Hub أو ECR
2. ابدأ تعمل kubernetes manifests
3. اختبر على k8s cluster

**سؤال:** تحتاج مساعدة في أي خطوة من الخطوات دي؟
