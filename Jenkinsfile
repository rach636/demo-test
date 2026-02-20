pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "my-app"
        AWS_REGION = "ap-south-1"
        ECR_URI = "035736213603.dkr.ecr.ap-south-1.amazonaws.com/my-app"
    }

    stages {

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t ${DOCKER_IMAGE} .'
            }
        }
    stage('Trivy Security Scan') {
            steps {
                sh '''
                echo "Scanning Docker image ${DOCKER_IMAGE} for vulnerabilities..."
                trivy image --severity HIGH,CRITICAL --exit-code 1 ${DOCKER_IMAGE}
                '''
            }
        }    
        stage('Run Container') {
            steps {
                sh '''
                docker stop my-app || true
                docker rm my-app || true
                docker run -d -p 8082:80 --name my-app ${DOCKER_IMAGE}
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

    }
}
