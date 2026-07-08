// ============================================================
//  Jenkinsfile — Intelligent Traffic Management Dashboard
//  Runs alongside the existing GitHub Actions workflow
//  (.github/workflows/ci-cd.yml). Both pipelines are independent.
//
//  Requires:
//   - A Multibranch Pipeline (or equivalent) job so BRANCH_NAME
//     is set, matching the GitHub Actions "main only" push gate.
//   - A Jenkins "Username with password" credential named
//     'dockerhub-credentials' (username = Docker Hub username,
//     password = Docker Hub access token).
// ============================================================

pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        COLLECTOR_IMAGE = "${DOCKERHUB_CREDENTIALS_USR}/traffic-collector"
        DASHBOARD_IMAGE = "${DOCKERHUB_CREDENTIALS_USR}/traffic-dashboard"
        IMAGE_TAG = "${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                dir('traffic-dashboard') {
                    sh 'npm ci'
                }
                // Debian's system Python is externally-managed (PEP 668);
                // this container is CI-only and disposable per build.
                sh 'pip3 install --no-cache-dir --break-system-packages pandas'
            }
        }

        stage('Run Tests') {
            steps {
                sh '''
                    docker compose build traffic-collector traffic-dashboard
                    docker compose up -d traffic-collector traffic-dashboard
                    sleep 10
                    CID=$(docker compose ps -q traffic-dashboard)
                    docker exec "$CID" wget -q -O- http://localhost:3002/ > /dev/null
                    docker exec "$CID" wget -q -O- http://localhost:3002/api/traffic > /dev/null
                    echo "Integration checks passed"
                '''
            }
            post {
                always {
                    sh 'docker compose down || true'
                }
            }
        }

        stage('Code Quality') {
            steps {
                sh 'python3 -m py_compile traffic-collector/app.py'
                dir('traffic-dashboard') {
                    sh 'node -c server.js'
                }
            }
        }

        stage('Build Docker Images') {
            steps {
                sh "docker build -t ${COLLECTOR_IMAGE}:latest -t ${COLLECTOR_IMAGE}:${IMAGE_TAG} ./traffic-collector"
                sh "docker build -t ${DASHBOARD_IMAGE}:latest -t ${DASHBOARD_IMAGE}:${IMAGE_TAG} ./traffic-dashboard"
            }
        }

        stage('Push to Docker Hub') {
            when {
                branch 'main'
            }
            steps {
                sh 'echo "$DOCKERHUB_CREDENTIALS_PSW" | docker login -u "$DOCKERHUB_CREDENTIALS_USR" --password-stdin'
                sh "docker push ${COLLECTOR_IMAGE}:latest"
                sh "docker push ${COLLECTOR_IMAGE}:${IMAGE_TAG}"
                sh "docker push ${DASHBOARD_IMAGE}:latest"
                sh "docker push ${DASHBOARD_IMAGE}:${IMAGE_TAG}"
            }
        }
    }

    post {
        always {
            sh 'docker logout || true'
        }
    }
}
