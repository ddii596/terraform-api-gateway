pipeline {
    agent any

    parameters {
        string(name: 'API_NAME', defaultValue: 'MinhaAPI', description: 'Nome da API Gateway')
        string(name: 'BUCKET_NAME', defaultValue: 'meu-bucket-api', description: 'Nome do bucket S3')
        string(name: 'ROLE_NAME', defaultValue: 'api-role', description: 'Nome da role IAM')
        string(name: 'POLICY_NAME', defaultValue: 'api-policy', description: 'Nome da policy IAM')
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
                sh 'terraform init'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh """
                terraform plan \\
                    -var="api_name=${params.API_NAME}" \\
                    -var="bucket_name=${params.BUCKET_NAME}" \\
                    -var="role_name=${params.ROLE_NAME}" \\
                    -var="policy_name=${params.POLICY_NAME}"
                """
            }
        }

        stage('Terraform Apply') {
            steps {
                sh """
                terraform apply -auto-approve \\
                    -var="api_name=${params.API_NAME}" \\
                    -var="bucket_name=${params.BUCKET_NAME}" \\
                    -var="role_name=${params.ROLE_NAME}" \\
                    -var="policy_name=${params.POLICY_NAME}"
                """
            }
        }

        stage('Show Outputs') {
            steps {
                sh 'terraform output'
            }
        }
    }
}
