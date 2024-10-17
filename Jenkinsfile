pipeline {
    agent any 

    environment {
        AWS_ACCESS_KEY_ID = credentials('aws-access-key')
        AWS_REGION = 'ap-southeast-2'
        SSH_KEY = credentials('mykey')
        TEST_SERVER_IP = '13.54.199.48' 
        PROD_SERVER_IP = '3.25.115.63' 
    }

    stages {
        stage('Install Dependencies') {
            steps {
                script {
                    sh 'pip install -r requirements.txt'
                }
            }
        }

        stage('Run Tests') {
            steps {
                script {
                    sh 'pytest'
                }
            }
        }

        stage('Deploy to Test') {
            steps {
                script {
                    // Add EC2 host to known_hosts
                    sh '''
                        mkdir -p ~/.ssh
                        ssh-keyscan -H $TEST_SERVER_IP >> ~/.ssh/known_hosts
                    '''

                    // Ensure the target directory exists and deploy the application
                    sh '''
                        ssh -i $SSH_KEY ec2-user@$TEST_SERVER_IP "mkdir -p /var/www/myapp && rm -rf /var/www/myapp/*"
                        rsync -avz -e "ssh -i $SSH_KEY" ./ ec2-user@$TEST_SERVER_IP:/var/www/myapp/
                        ssh -i $SSH_KEY ec2-user@$TEST_SERVER_IP "chown -R ec2-user:ec2-user /var/www/myapp/"
                    '''
                }
            }
        }

        stage('Deploy to Production') {
            when {
                expression {
                    return currentBuild.resultIsBetterOrEqualTo('SUCCESS')
                }
            }
            steps {
                script {
                    // Add EC2 host to known_hosts
                    sh '''
                        mkdir -p ~/.ssh
                        ssh-keyscan -H $PROD_SERVER_IP >> ~/.ssh/known_hosts
                    '''

                    // Ensure the target directory exists and deploy the application
                    sh '''
                        ssh -i $SSH_KEY ec2-user@$PROD_SERVER_IP "mkdir -p /var/www/myapp && rm -rf /var/www/myapp/*"
                        rsync -avz -e "ssh -i $SSH_KEY" ./ ec2-user@$PROD_SERVER_IP:/var/www/myapp/
                        ssh -i $SSH_KEY ec2-user@$PROD_SERVER_IP "chown -R ec2-user:ec2-user /var/www/myapp/"
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline succeeded! Deployment to Test and Production completed.'
        }
        failure {
            echo 'Pipeline failed! Check logs for details.'
        }
    }
}
