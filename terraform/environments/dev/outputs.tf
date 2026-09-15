output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "s3_bucket_name" {
  description = "S3 Storage Bucket Name"
  value       = module.s3.bucket_name
}

output "server_public_ip" {
  description = "Public IP for the App Server"
  value       = module.ec2.server_public_ip
}

output "app_url" {
  description = "Application URL"
  value       = module.ec2.app_url
}

output "website_url" {
  description = "The public URL to access the application"
  value       = var.enable_alb ? "http://${module.alb[0].alb_dns_name}" : "ALB disabled (testing on LocalStack)"
}
