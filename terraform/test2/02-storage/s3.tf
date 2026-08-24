module "django_media_bucket" {
  source      = "../modules/s3-secure-bucket"
  bucket_name = "my-company-${var.environment}-django-media-bucket"
  environment = var.environment
}


# ==============================================================================
# STATE REFACTORING: Move existing resources into the new module without downtime
# ==============================================================================
moved {
  from = aws_s3_bucket.app_media
  to   = module.django_media_bucket.aws_s3_bucket.this
}

moved {
  from = aws_s3_bucket_ownership_controls.app_media_ownership
  to   = module.django_media_bucket.aws_s3_bucket_ownership_controls.this
}

moved {
  from = aws_s3_bucket_public_access_block.app_media_public_block
  to   = module.django_media_bucket.aws_s3_bucket_public_access_block.this
}

moved {
  from = aws_s3_bucket_server_side_encryption_configuration.app_media_encryption
  to   = module.django_media_bucket.aws_s3_bucket_server_side_encryption_configuration.this
}

moved {
  from = aws_s3_bucket_cors_configuration.app_media_cors
  to   = module.django_media_bucket.aws_s3_bucket_cors_configuration.this
}

moved {
  from = aws_s3_bucket_lifecycle_configuration.app_media_lifecycle
  to   = module.django_media_bucket.aws_s3_bucket_lifecycle_configuration.this
}