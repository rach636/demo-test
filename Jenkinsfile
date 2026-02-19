pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "my-app"
    }

    stages {
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
