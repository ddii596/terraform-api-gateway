output "bucket_name" {
  value = aws_s3_bucket.bucket.bucket
}

output "api_endpoint" {
  value = aws_api_gateway_deployment.api_deploy.invoke_url
}

output "role_arn" {
  value = aws_iam_role.api_gateway_role.arn
}
