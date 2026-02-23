# Intelligent Traffic Management Dashboard 
**Drive Link:** https://drive.google.com/drive/folders/1-Q9L_qYiQUs13soYEqLijQGZFUDaiGQo?usp=sharing
**Team Members:**
Lama Ossama
Mariam Yasser
Nouran Adel
Mohamed Ossama
Youssef Mustafa


##  Project Overview
Cities face challenges in monitoring traffic congestion and reacting quickly to peak times and incidents.
This project provides a real-time traffic monitoring system that collects simulated traffic sensor data and displays insights through a dashboard.

The solution focuses on DevOps practices including automation, containerization, CI/CD, monitoring, and scalable deployment.



##  Project Objectives
- Collect traffic data from simulated IoT sensors or CSV logs
- Display real-time traffic congestion metrics
- Detect peak times and trigger alerts
- Deploy services using Docker and Kubernetes
- Automate CI/CD using Jenkins
- Monitor system performance with Prometheus and Grafana
- Use Nginx as a reverse proxy
- Provision AWS infrastructure using Terraform
- Configure servers using Ansible


## Tools & Technologies
- Docker
- Kubernetes
- Jenkins
- Prometheus
- Grafana
- Nginx
- Terraform
- Ansible
- AWS (EC2, S3)
- Git / GitHub


| Period          | Time in Days | Task & Deliverables                                                                                                                                                                                                                                                                                                                                                                             |
| --------------- | ------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **16-2 → 28-2** | **13 Days**  | **Phase 1: GitHub Setup & Project Foundations**  <br><br>• Create and organize the GitHub repository structure (Deliverable 10). <br>• Add README.md with project description, architecture, and deliverables. <br>• Setup Git branching strategy (main/dev/feature branches). <br>• Invite team members and assign roles. <br>• Create documentation folder (docs/) for diagrams and reports.  |
| **1-3 → 15-3**  | **15 Days**  | **Phase 2: AWS Basics & Manual Provisioning**  <br><br>• Learn AWS core services needed: EC2, VPC, Security Groups, S3, IAM. <br>• Manually create EC2 instance for testing. <br>• Setup basic networking (VPC/Subnets) to understand architecture. <br>• Store sample traffic logs in S3 manually. <br>• Validate access permissions with IAM roles.                                           |
| **16-3 → 30-3** | **15 Days**  | **Phase 3: Infrastructure as Code (Terraform)**  <br><br>• Learn Terraform providers, state, modules, variables. <br>• Write Terraform scripts to provision AWS infrastructure (Deliverable 8). <br>• Provision EC2 instances, VPC, subnets, security groups. <br>• Provision S3 bucket for traffic logs storage. <br>• Ensure infrastructure can be destroyed/recreated fully using Terraform. |
| **31-3 → 14-4** | **15 Days**  | **Phase 4: Configuration Management (Ansible)**  <br><br>• Learn Ansible inventory, playbooks, roles. <br>• Write Ansible playbooks to configure EC2 servers (Deliverable 9). <br>• Automate installation of Docker, Kubernetes tools, and Nginx. <br>• Automate setup of required system dependencies for deployment.                                                                          |
| **15-4 → 30-4** | **16 Days**  | **Phase 5: Traffic Data Collection Service (Dockerized)**  <br><br>• Implement traffic data collection service (simulated IoT sensor generator or CSV reader). <br>• Dockerize the traffic collector service (Deliverable 1). <br>• Validate traffic data is generated correctly. <br>• Optional: store output data in file or send via REST API.                                               |
| **1-5 → 15-5**  | **15 Days**  | **Phase 6: Web Dashboard Development**  <br><br>• Build web dashboard to display traffic congestion metrics (Deliverable 2). <br>• Display peak times, congestion levels, alerts. <br>• Connect dashboard with traffic collector output. <br>• Containerize the dashboard web app using Docker.                                                                                                 |
| **16-5 → 30-5** | **15 Days**  | **Phase 7: Reverse Proxy Setup (Nginx)**  <br><br>• Learn Nginx reverse proxy and routing rules. <br>• Configure Nginx to route traffic between collector and dashboard services (Deliverable 7). <br>• Dockerize Nginx configuration. <br>• Ensure services are reachable through one entry point.                                                                                             |
| **31-5 → 15-6** | **16 Days**  | **Phase 8: Kubernetes Deployment & Scaling**  <br><br>• Learn Kubernetes core components (Pods, Deployments, Services). <br>• Write Kubernetes manifests for traffic collector + dashboard + Nginx (Deliverable 5). <br>• Deploy all services to Kubernetes cluster. <br>• Implement Horizontal Pod Autoscaler (HPA) for scalability.                                                           |
| **16-6 → 30-6** | **15 Days**  | **Phase 9: CI/CD Automation (Jenkins)**  <br><br>• Setup Jenkins server. <br>• Create Jenkinsfile pipeline to build Docker images and push to registry (Deliverable 3). <br>• Automate deployment updates to Kubernetes cluster. <br>• Validate CI/CD works with code changes.                                                                                                                  |
| **1-7 → 15-7**  | **15 Days**  | **Phase 10: Monitoring & Alerts (Prometheus + Grafana)**  <br><br>• Deploy Prometheus and Grafana (Deliverable 6). <br>• Configure Prometheus scraping for Kubernetes cluster and services. <br>• Create Grafana dashboards for CPU/Memory/Requests. <br>• Setup Prometheus alert rules for service downtime and high traffic.                                                                  |
| **16-7 → 23-7** | **8 Days**   | **Phase 11: Full Integration, Testing & Documentation**  <br><br>• Integrate full workflow: Terraform → Ansible → Kubernetes → Jenkins CI/CD → Monitoring. <br>• Test auto-scaling behavior under load. <br>• Test alert triggers. <br>• Finalize README.md with full deployment guide. <br>• Clean repo structure and ensure secrets are secured.                                              |


