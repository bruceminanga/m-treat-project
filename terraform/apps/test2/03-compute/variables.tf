variable "environment" {
  description = "Deployment environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "us-east-1"
}

variable "state_bucket_name" {
  description = "The S3 bucket where remote state files are stored"
  type        = string
  default     = "my-company-prod-terraform-state-bucket"
}

variable "instance_type" {
  description = "EC2 instance size"
  type        = string
  default     = "t3.micro"
}

variable "instance_ami" {
  description = "AMI ID for the EC2 server (dummy ID for LocalStack, real Ubuntu AMI for AWS)"
  type        = string
  default     = "ami-12345678"
}