pipeline {
    agent { label 'docker' }

    stages {
        stage('Prep') {
            steps {
                sh 'make fb-prep'
            }
        }
        stage('Build') {
            steps {
                sh 'make fb-build'
            }
        }
        stage('Check') {
            steps {
                sh 'make fb-check'
            }
        }
        stage('Clean') {
            steps {
                sh 'make fb-clean'
            }
        }
    }
}