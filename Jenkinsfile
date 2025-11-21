pipeline {
    agent any

    environment {
        DOCKERHUB_USER = credentials('dockerhub-user')   // Jenkins credential ID
        DOCKERHUB_PASS = credentials('dockerhub-pass')   // Jenkins credential ID
        IMAGE_NAME = "your-dockerhub-username/vacancy-board"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build & Test') {
            steps {
                sh '''
                  if [ -f package.json ]; then
                    npm install
                    # Uncomment if you have tests
                    # npm test
                  else
                    echo "No package.json, skipping npm install"
                  fi
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                  docker build -t ${IMAGE_NAME}:latest .
                '''
            }
        }

        stage('Login to Docker Hub') {
            steps {
                sh '''
                  echo "${DOCKERHUB_PASS}" | docker login -u "${DOCKERHUB_USER}" --password-stdin
                '''
            }
        }

        stage('Push Docker Image') {
            steps {
                sh '''
                  docker push ${IMAGE_NAME}:latest
                '''
            }
        }

        stage('Deploy') {
            steps {
                // Assuming Jenkins and Docker are on same host
                sh '''
                  cd /opt/vacancy-board || exit 1
                  docker compose pull
                  docker compose up -d
                '''
            }
        }
    }

    post {
        always {
            sh 'docker logout || true'
        }
    }
}
