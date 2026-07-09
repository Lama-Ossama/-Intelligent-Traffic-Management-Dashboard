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
        // Isolates each Jenkins run's containers/network/volumes from
        // local dev and from other concurrent Jenkins builds — avoids
        // "container name already in use" / "port already allocated".
        COMPOSE_PROJECT_NAME = "traffic-ci-${env.BUILD_NUMBER}"
        COMPOSE_FILES = "-f docker-compose.yml -f docker-compose.ci.yml"
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
                // scripts/ci-test.sh is the single source of truth for the
                // integration checks — the GitHub Actions workflow calls the
                // same script so both pipelines run identical checks.
                sh 'bash scripts/ci-test.sh'
            }
            post {
                always {
                    // Safety net: ci-test.sh already tears the stack down on
                    // exit via its own trap, but this covers the case where
                    // the script itself gets killed (e.g. build aborted).
                    sh 'docker compose $COMPOSE_FILES down -v --remove-orphans || true'
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
