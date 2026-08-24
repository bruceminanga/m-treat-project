output "vpc_id" {
  description = "The ID of the custom VPC"
  value       = aws_vpc.custom_vpc.id
}

output "public_subnet_id" {
  description = "The ID of the public subnet"
  value       = aws_subnet.custom_public_subnet.id
}