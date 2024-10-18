pipeline {
    agent any 

    environment {
        AWS_ACCESS_KEY_ID = credentials('aws-access-key')
        AWS_REGION = 'ap-southeast-2'
        SSH_KEY = credentials('mykey')
        TEST_SERVER_IP = '52.63.55.56'
        PROD_SERVER_IP = '3.107.67.30'
    }

    stages {
        stage('Checkout Code') {
            steps {
                script {
                    git branch: 'main', url: 'https://github.com/softwaredeployment8/swe40006_project.git'
                }
            }
        }
        
        stage('Test') {
            steps {
                script {
                    sh '''
                        ssh -o StrictHostKeyChecking=no -i $SSH_KEY ec2-user@$TEST_SERVER_IP "mkdir -p ~/myapp && chmod -R 755 ~/myapp && rm -rf ~/myapp/*"
                        scp -o StrictHostKeyChecking=no -i $SSH_KEY -r ./ ec2-user@$TEST_SERVER_IP:~/myapp/
                        ssh -o StrictHostKeyChecking=no -i $SSH_KEY ec2-user@$TEST_SERVER_IP "chown -R ec2-user:ec2-user ~/myapp/"
                    '''
                }
            }
        }

        stage('Production') {
            when {
                expression {
                    return currentBuild.resultIsBetterOrEqualTo('SUCCESS')
                }
            }
            steps {
                script {
                    sh '''
                        ssh -o StrictHostKeyChecking=no -i $SSH_KEY ec2-user@$PROD_SERVER_IP "mkdir -p ~/myapp && chmod -R 755 ~/myapp && rm -rf ~/myapp/*"
                        scp -o StrictHostKeyChecking=no -i $SSH_KEY -r ./ ec2-user@$PROD_SERVER_IP:~/myapp/
                        ssh -o StrictHostKeyChecking=no -i $SSH_KEY ec2-user@$PROD_SERVER_IP "chown -R ec2-user:ec2-user ~/myapp/"
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
