module "django_media_bucket" {
  source = "../../../modules/s3-secure-bucket"
  bucket_name = "my-company-${var.environment}-django-media-bucket"
  environment = var.environment
}