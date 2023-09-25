pipeline {
    agent {
        label 'my-docker-agent' // Optional agent label
    }
    
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

    post {
        success {
            script {
                def github = getGitHub()
                def commitSha = currentBuild().getEnvironment(env).CHANGE_ID
                def targetUrl = currentBuild().getAbsoluteUrl()
                def context = 'Jenkins CI'

                // Set the build status to success
                github.createCommitStatus(env.GITHUB_REPO, commitSha, "SUCCESS", context, "Build is successful", targetUrl)
            }
        }
        failure {
            script {
                def github = getGitHub()
                def commitSha = currentBuild().getEnvironment(env).CHANGE_ID
                def targetUrl = currentBuild().getAbsoluteUrl()
                def context = 'Jenkins CI'

                // Set the build status to failure
                github.createCommitStatus(env.GITHUB_REPO, commitSha, "FAILURE", context, "Build failed", targetUrl)
            }
        }
    }
}