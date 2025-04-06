pipeline {
    agent any

    parameters {
        string(name: 'API_NAME', defaultValue: 'MinhaAPI', description: 'Nome da API Gateway')
        string(name: 'BUCKET_NAME', defaultValue: 'meu-bucket-api', description: 'Nome do bucket S3')
        string(name: 'ROLE_NAME', defaultValue: 'api-role', description: 'Nome da role IAM')
        string(name: 'POLICY_NAME', defaultValue: 'api-policy', description: 'Nome da policy IAM')
        booleanParam(name: 'DESTROY_INFRA', defaultValue: false, description: 'Marque para destruir a infraestrutura')
    }

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/ddii596/terraform-api-gateway'
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh '''
                        export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                        export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                        export AWS_DEFAULT_REGION=us-east-1

                        terraform init
                    '''
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh '''
                        export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                        export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                        export AWS_DEFAULT_REGION=us-east-1

                        terraform plan \
                          -var="api_name=${API_NAME}" \
                          -var="bucket_name=${BUCKET_NAME}" \
                          -var="role_name=${ROLE_NAME}" \
                          -var="policy_name=${POLICY_NAME}"
                    '''
                }
            }
        }

        stage('Terraform Apply or Destroy') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    script {
                        def action = params.DESTROY_INFRA ? "destroy -auto-approve" : "apply -auto-approve"

                        sh """
                            export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                            export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                            export AWS_DEFAULT_REGION=us-east-1

                            terraform ${action} \\
                              -var="api_name=${API_NAME}" \\
                              -var="bucket_name=${BUCKET_NAME}" \\
                              -var="role_name=${ROLE_NAME}" \\
                              -var="policy_name=${POLICY_NAME}"
                        """
                    }
                }
            }
        }

        stage('Show Outputs') {
            when {
                expression { return !params.DESTROY_INFRA }
            }
            steps {
                sh 'terraform output'
            }
        }
    }
}
