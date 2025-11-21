pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    environment {
        IMAGE_NAME = "adaleshri/vacancy-board"
    }

    stages {
        stage('Checkout') {
            steps {
                // Works if job is configured as "Pipeline script from SCM"
                checkout scm
            }
        }

        stage('Build & Test') {
            // Run this stage inside a Node container so npm is available
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true   // share the same workspace with main agent
                }
            }
            steps {
                sh '''
                  echo "Node version:"
                  node -v

                  if [ -f package.json ]; then
                    echo "Installing dependencies..."

                    if [ -f package-lock.json ]; then
                      npm ci
                    else
                      npm install
                    fi

                    if npm run | grep -q "test"; then
                      echo "Running tests..."
                      npm test
                    else
                      echo "No test script defined, skipping tests."
                    fi
                  else
                    echo "No package.json found, skipping Node build."
                  fi
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Tag for this build
                    env.IMAGE_TAG = "${BUILD_NUMBER}"
                }

                sh '''
                  echo "Building Docker image: ${IMAGE_NAME}:${IMAGE_TAG} and :latest"

                  docker build \
                    --build-arg NODE_ENV=production \
                    -t ${IMAGE_NAME}:${IMAGE_TAG} \
                    -t ${IMAGE_NAME}:latest \
                    .
                '''
            }
        }

        stage('Login to Docker Hub') {
            steps {
                // Use Jenkins credentials instead of hardcoding username/password
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-cred',   // <- create this in Jenkins
                    usernameVariable: 'DOCKERHUB_USER',
                    passwordVariable: 'DOCKERHUB_PASS'
                )]) {
                    sh '''
                      echo "Logging in to Docker Hub as ${DOCKERHUB_USER}"
                      echo "${DOCKERHUB_PASS}" | docker login -u "${DOCKERHUB_USER}" --password-stdin
                    '''
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                sh '''
                  echo "Pushing images ${IMAGE_NAME}:${IMAGE_TAG} and :latest"
                  docker push ${IMAGE_NAME}:${IMAGE_TAG}
                  docker push ${IMAGE_NAME}:latest
                '''
            }
        }

        stage('Deploy') {
            steps {
                // Assuming Jenkins and Docker are on same host
                // and docker-compose.yml is in /opt/vacancy-board
                sh '''
                  echo "Deploying vacancy-board to production..."

                  cd /opt/vacancy-board || exit 1

                  # Pull latest image from Docker Hub
                  docker compose pull

                  # Recreate containers with latest image
                  docker compose up -d

                  echo "Deployment completed."
                '''
            }
        }
    }

    post {
        success {
            echo "✅ Production deployment successful."
        }
        failure {
            echo "❌ Build or deployment failed. Check logs above."
        }
    }
}
