variable "api_name" {
  description = "Nome da API Gateway"
  type        = string
}

variable "bucket_name" {
  description = "Nome do bucket S3"
  type        = string
}

variable "role_name" {
  description = "Nome da IAM Role"
  type        = string
}

variable "policy_name" {
  description = "Nome da Policy"
  type        = string
}

variable "region" {

  description = "região da aws "
  type = string
  default = "us-east-1"


}
