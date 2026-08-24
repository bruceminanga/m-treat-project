# ==============================================================================
# REMOTE STATE DATA SOURCES
# ==============================================================================
data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = var.state_bucket_name
    key    = "networking/${var.environment}/terraform.tfstate"
    region = var.aws_region
  }
}

data "terraform_remote_state" "storage" {
  backend = "s3"
  config = {
    bucket = var.state_bucket_name
    key    = "storage/${var.environment}/terraform.tfstate"
    region = var.aws_region
  }
}