pipeline {
    agent any 

    environment {
        // Define any environment variables you need, e.g., AWS credentials.
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        AWS_REGION = 'us-west-2'  // Update as needed
    }

    stages {
        stage('Build') {
            steps {
                script {
                    // Execute your build on AWS build servers
                    sh 'aws codebuild start-build --project-name MyBuildProject'
                }
            }
        }

        stage('Test') {
            steps {
                script {
                    // Use Jenkins to run your tests
                    // Example: run unit tests
                    sh 'npm test'  // or any test command specific to your project
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    // Deploy to your AWS environment
                    sh 'aws deploy create-deployment --application-name MyApp --s3-location bucket=mybucket,key=myapp.zip,bundleType=zip'
                }
            }
        }
    }

    post {
        success {
            // Actions to perform on success
            echo 'Pipeline succeeded!'
        }
        failure {
            // Actions to perform on failure
            echo 'Pipeline failed!'
        }
    }
}
