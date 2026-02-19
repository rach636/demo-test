pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "my-app"
        SONARQUBE_SERVER = "sonarqube"
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonarqube') {
                    sh '''
                    docker run --rm \
                    -e SONAR_HOST_URL=http://host.docker.internal:9000 \
                    -e SONAR_LOGIN=$SONAR_AUTH_TOKEN \
                    -v $(pwd):/usr/src \
                    sonarsource/sonar-scanner-cli \
                    -Dsonar.projectKey=my-app \
                    -Dsonar.sources=.
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t my-app .'
            }
        }

        stage('Run Container') {
            steps {
                sh '''
                docker stop my-app || true
                docker rm my-app || true
                docker run -d -p 8082:80 --name my-app my-app
                '''
            }
        }

    }
}
