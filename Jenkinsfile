pipeline {
    agent any

    environment {
        // It's best practice to manage secrets like JULES_SECRET_TOKEN
        // using Jenkins Credentials.
        // For this example, we'll define it here, but in a real setup,
        // you would use something like:
        // JULES_SECRET_TOKEN = credentials('your-jules-secret-token-id')
        JULES_SECRET_TOKEN = "your_very_secret_token_here_TO_BE_CONFIGURED_IN_JENKINS"
        GO_VERSION = "1.21" // Specify your Go version
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/your-repo.git' // Replace with your actual repo URL
            }
        }

        stage('Setup Go') {
            steps {
                script {
                    // Download and install Go if not available
                    // This is a simplified example. For robust Go tool management,
                    // consider using the Go plugin or a tool installer.
                    def goRoot = tool name: "Go ${env.GO_VERSION}", type: 'go'
                    env.PATH = "${goRoot}/bin:${env.PATH}"
                    env.GOROOT = "${goRoot}"
                    sh 'go version'
                }
            }
        }

        stage('Build') {
            steps {
                sh 'go build -v -o kubectl-ai .'
            }
        }

        stage('Archive Artifacts') {
            steps {
                archiveArtifacts artifacts: 'kubectl-ai', fingerprint: true
            }
        }

        stage('Deploy & Run Background Service (Conceptual)') {
            steps {
                script {
                    // This is a conceptual step. In a real-world scenario, you would:
                    // 1. Transfer 'kubectl-ai' binary to your OminousJourney target server(s).
                    //    - Use plugins like "Publish Over SSH" or custom scripting.
                    // 2. Ensure JULES_SECRET_TOKEN is set on the target server's environment
                    //    for the service.
                    // 3. Stop the old version of the service (if running).
                    // 4. Replace the binary.
                    // 5. Start the new version as a background service (e.g., using systemd).
                    //
                    // Example (pseudo-code for systemd on a target server):
                    // withCredentials([string(credentialsId: 'ominous-journey-ssh-key', variable: 'SSH_KEY_PATH')]) {
                    //    sh """
                    //    scp -i ${env.SSH_KEY_PATH} kubectl-ai user@ominous-journey-server:/opt/kubectl-ai/kubectl-ai
                    //    ssh -i ${env.SSH_KEY_PATH} user@ominous-journey-server \\
                    //        'sudo systemctl stop kubectl-ai.service || true && \\
                    //         sudo cp /opt/kubectl-ai/kubectl-ai /usr/local/bin/kubectl-ai && \\
                    //         sudo systemctl daemon-reload && \\
                    //         echo "JULES_SECRET_TOKEN=${env.JULES_SECRET_TOKEN}" > /etc/default/kubectl-ai && \\
                    //         sudo systemctl start kubectl-ai.service && \\
                    //         sudo systemctl status kubectl-ai.service'
                    //    """
                    // }

                    echo "Conceptual Deployment: "
                    echo "1. Transfer kubectl-ai to OminousJourney server."
                    echo "2. Ensure JULES_SECRET_TOKEN='${env.JULES_SECRET_TOKEN}' is available to the service."
                    echo "3. Configure and start as a background service (e.g., systemd)."
                    echo "   Example command on server: JULES_SECRET_TOKEN='${env.JULES_SECRET_TOKEN}' ./kubectl-ai --user-interface=html > /var/log/kubectl-ai.log 2>&1 &"
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished.'
        }
    }
}
