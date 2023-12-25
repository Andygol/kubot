pipeline {
    agent any
    parameters {
        choice(name: 'OS', choices: ['linux', 'apple', 'windows'], description: 'Pick OS')
        choice(name: 'ARCH', choices: ['amd64', 'arm64'], description: 'Pick ARCH')
    }

    environment {
        GITHUB_TOKEN=credentials('github-token')
        REPO = 'https://github.com/Andygol/kubot'
        BRANCH = 'main'
    }

    stages {

        stage('clone') {
            steps {
                echo 'Clone Repository'
                git branch: "${BRANCH}", url: "${REPO}"
            }
        }

        stage('test') {
            steps {
                echo 'Testing started'
                sh "make test"
            }
        }

        stage('build') {
            steps {
                echo "Building binary for platform ${params.OS} on ${params.ARCH} started"
                sh "make ${params.OS} ${params.ARCH}"
            }
        }

        stage('image') {
            steps {
                echo "Building image for platform ${params.OS} on ${params.ARCH} started"
                sh "make image-${params.OS} ${params.ARCH}"
            }
        }
        
        stage('login to GHCR') {
            steps {
                sh "echo $GITHUB_TOKEN_PSW | docker login ghcr.io -u $GITHUB_TOKEN_USR --password-stdin"
            }
        }

        stage('push image') {
            steps {
                sh "make ${params.OS} ${params.ARCH} image push"
            }
        } 
    }

    post {
        always {
            sh 'docker logout'
        }
    }
}

// Guide to push images to ghcr.io 
// - video https://www.youtube.com/watch?v=HTou7pGnS0Y
// - repo https://github.com/darinpope/jenkins-example-ghcr