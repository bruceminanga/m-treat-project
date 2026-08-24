variable "instance_ami" {
  description = "AMI ID for the server. In LocalStack, any dummy AMI works. In real AWS, use data.aws_ami or leave empty."
  type        = string
}

variable "environment" {
  description = "Deployment environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance size"
  type        = string
}

