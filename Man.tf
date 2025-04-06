provider "aws" {
  region = "us-east-1"
}

# Bucket S3
resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
}

# IAM Role
resource "aws_iam_role" "api_gateway_role" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy
resource "aws_iam_policy" "api_policy" {
  name = var.policy_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.bucket.arn}/*"
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.api_gateway_role.name
  policy_arn = aws_iam_policy.api_policy.arn
}

# API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name = var.api_name
}

# API Resource (raiz)
resource "aws_api_gateway_resource" "upload" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "upload"
}

# API Method
resource "aws_api_gateway_method" "put_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.upload.id
  http_method   = "PUT"
  authorization = "NONE"
}

# API Integration (S3)
resource "aws_api_gateway_integration" "s3_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.upload.id
  http_method = aws_api_gateway_method.put_method.http_method

  integration_http_method = "PUT"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.region}:s3:path/${var.bucket_name}/{object}"

  credentials = aws_iam_role.api_gateway_role.arn
}

# Deploy da API
resource "aws_api_gateway_deployment" "api_deploy" {
  depends_on  = [aws_api_gateway_integration.s3_integration]
  rest_api_id = aws_api_gateway_rest_api.api.id
  description = "Deploy automático pelo Terraform"
}
# Stage da API
resource "aws_api_gateway_stage" "api_stage" {
  rest_api_id    = aws_api_gateway_rest_api.api.id
  stage_name     = "prod"
  deployment_id  = aws_api_gateway_deployment.api_deploy.id
}

terraform {
  backend "s3" {
    bucket         = "ddii596-lab-terraform-statefile"
    key            = "api-gateway/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "ddii596-lab-terraform-lock"
    encrypt        = true
  }
}
