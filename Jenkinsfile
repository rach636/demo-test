pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "my-app"
        AWS_REGION   = "ap-south-1"
        ECR_URI      = "035736213603.dkr.ecr.ap-south-1.amazonaws.com/my-app"
        TERRAFORM_DIR = "terraform"
    }

    stages {
        stage('SonarQube Scan') {
            steps {
                withSonarQubeEnv('sonarqube') { // Name configured in Jenkins global settings
                    sh 'sonar-scanner -Dsonar.projectKey=my-app -Dsonar.sources=.'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t ${DOCKER_IMAGE} .'
            }
        }

        stage('Trivy Scan') {
            steps {
                sh '''
                docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest \
                image --severity HIGH,CRITICAL --exit-code 1 ${DOCKER_IMAGE}
                '''
            }
        }

        stage('Push to ECR') {
            steps {
                withAWS(region: "${AWS_REGION}", credentials: 'aws-creds-id') {
                    sh '''
                    aws ecr get-login-password --region ${AWS_REGION} | \
                    docker login --username AWS --password-stdin ${ECR_URI}
                    docker tag ${DOCKER_IMAGE}:latest ${ECR_URI}:latest
                    docker push ${ECR_URI}:latest
                    '''
                }
            }
        }

        stage('Terraform Init & Plan') {
            steps {
                dir("${TERRAFORM_DIR}") {
                    withAWS(region: "${AWS_REGION}", credentials: 'aws-creds-id') {
                        sh 'terraform init'
                        sh 'terraform plan -out=tfplan'
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir("${TERRAFORM_DIR}") {
                    withAWS(region: "${AWS_REGION}", credentials: 'aws-creds-id') {
                        sh 'terraform apply -auto-approve tfplan'
                    }
                }
            }
        }

        stage('Checkov Terraform Scan') {
            steps {
                sh '''
                docker run --rm -v ${PWD}/${TERRAFORM_DIR}:/tf bridgecrew/checkov:latest -d /tf
                '''
            }
        }

    }

    post {
        always {
            echo "Pipeline finished. Listing Docker images..."
            sh 'docker images'
        }
        failure {
            echo "Pipeline failed! Check logs for Trivy scan, Terraform, or Checkov errors."
        }
    }
}
