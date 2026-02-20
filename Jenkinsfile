pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "my-app"
        AWS_REGION   = "ap-south-1"
        ECR_URI      = "035736213603.dkr.ecr.ap-south-1.amazonaws.com/my-app"
        TF_DIR       = "terraform" // Terraform folder in your repo
    }

    stages {

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image..."
                sh 'docker build -t ${DOCKER_IMAGE} .'
            }
        }

        stage('Trivy Security Scan') {
            steps {
                echo "Running Trivy scan (HIGH & CRITICAL vulnerabilities)..."
                sh '''
                trivy image --severity HIGH,CRITICAL --exit-code 1 ${DOCKER_IMAGE}
                '''
            }
        }

        stage('Push Docker Image to ECR') {
            steps {
                echo "Pushing Docker image to AWS ECR..."
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

        stage('Deploy ECS Fargate via Terraform (Default VPC)') {
            steps {
                echo "Deploying ECS Fargate service using Terraform in default VPC..."
                dir("${TF_DIR}") {
                    withAWS(region: "${AWS_REGION}", credentials: 'aws-creds-id') {
                        sh '''
                        terraform init
                        terraform apply -auto-approve
                        '''
                    }
                }
            }
        }

    }

    post {
        always {
            echo "Pipeline finished. Listing Docker images..."
            sh 'docker images'
        }
        failure {
            echo "Pipeline failed! Check logs for Trivy scan or Terraform errors."
        }
        success {
            echo "Pipeline completed successfully! ECS Fargate service updated."
        }
    }
}
