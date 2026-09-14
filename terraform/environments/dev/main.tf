locals {
  environment = "dev"
}

# 1. Network Layer
module "vpc" {
  source      = "../../modules/vpc"
  environment = local.environment
  aws_region  = "us-east-1"
  vpc_cidr    = "10.0.0.0/16"
}

# 2. Storage Layer
module "s3" {
  source      = "../../modules/s3-secure-bucket"
  environment = local.environment
  bucket_name = "my-app-media-storage-${local.environment}"
}

# 3. Compute Layer
module "ec2" {
  source        = "../../modules/ec2-app-server"
  environment   = local.environment
  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.vpc.public_subnet_id
  s3_bucket_arn = module.s3.bucket_arn

  instance_type = "t3.micro"
}