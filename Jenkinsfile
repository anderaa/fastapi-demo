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
                def githubToken = credentials('6609c088-0b63-4458-afc4-8d4efc530cf8') 
                def commitSha = currentBuild().getEnvironment(env).CHANGE_ID
                def targetUrl = currentBuild().getAbsoluteUrl()
                def context = 'Jenkins CI'

                def status = 'success'
                def description = 'Build is successful'

                // Update GitHub commit status
                updateGitHubCommitStatus(githubToken, commitSha, status, context, description, targetUrl)
            }
        }
        failure {
            script {
                def githubToken = credentials('6609c088-0b63-4458-afc4-8d4efc530cf8	')
                def commitSha = currentBuild().getEnvironment(env).CHANGE_ID
                def targetUrl = currentBuild().getAbsoluteUrl()
                def context = 'Jenkins CI'

                def status = 'failure'
                def description = 'Build failed'

                // Update GitHub commit status
                updateGitHubCommitStatus(githubToken, commitSha, status, context, description, targetUrl)
            }
        }
    }
}


def updateGitHubCommitStatus(token, commitSha, status, context, description, targetUrl) {
    def apiUrl = "https://api.github.com/repos/${env.GITHUB_REPO}/statuses/${commitSha}"

    def payload = [
        state: status,
        target_url: targetUrl,
        description: description,
        context: context
    ]

    def response = httpRequest(
        acceptType: 'APPLICATION_JSON',
        contentType: 'APPLICATION_JSON',
        httpMode: 'POST',
        url: apiUrl,
        authentication: token,
        requestBody: groovy.json.JsonOutput.toJson(payload)
    )

    if (response.status != 201) {
        error("Failed to update GitHub commit status: ${response.status} ${response.responseMessage}")
    }
}