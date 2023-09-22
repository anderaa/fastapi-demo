pipeline {
    agent { dockerfile true }
    stages {
        stage('Install Dependencies') {
            steps {
                script {
                    // Install Python dependencies using pip
                    sh 'pip install -r requirements.txt'
                }
            }
        }
        
        stage('Run Tests') {
            steps {
                script {
                    // Run pytest
                    sh 'python -m pytest .'
                }
            }
        }
    }
}