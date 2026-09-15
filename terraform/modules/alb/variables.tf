variable "environment" {
  type        = string
  description = "Deployment environment (e.g. dev, prod)"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the ALB will be deployed"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of at least two public subnet IDs across different AZs"
}

variable "target_instance_id" {
  type        = string
  description = "ID of the EC2 instance to register with the target group"
}

variable "app_port" {
  type        = number
  description = "Port the application container is listening on (e.g., 80 or 8000)"
  default     = 80
}

variable "health_check_path" {
  type        = string
  description = "Endpoint path for ALB health checks"
  default     = "/"
}