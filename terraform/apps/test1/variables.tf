variable "instance_ami" {
  description = "AMI ID for the server. In LocalStack, any dummy AMI works. In real AWS, use data.aws_ami or leave empty."
  type        = string
  default     = "ami-12345678" # LocalStack accepts any dummy string
}