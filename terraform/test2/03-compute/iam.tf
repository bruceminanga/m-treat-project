# ==============================================================================
# IAM ROLE & S3 PERMISSIONS
# ==============================================================================
resource "aws_iam_role" "app_server_role" {
  name = "django-server-${var.environment}-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "s3_access_policy" {
  name = "django-s3-${var.environment}-policy"
  role = aws_iam_role.app_server_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ]
      Resource = [
        data.terraform_remote_state.storage.outputs.media_bucket_arn,
        "${data.terraform_remote_state.storage.outputs.media_bucket_arn}/*"
      ]
    }]
  })
}

resource "aws_iam_instance_profile" "app_server_profile" {
  name = "django-server-${var.environment}-profile"
  role = aws_iam_role.app_server_role.name
}