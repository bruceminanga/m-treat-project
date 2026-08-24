output "media_bucket_name" {
  description = "The name of the S3 media bucket"
  value       = module.django_media_bucket.bucket_name
}

output "media_bucket_arn" {
  description = "The ARN of the S3 media bucket"
  value       = module.django_media_bucket.bucket_arn
}