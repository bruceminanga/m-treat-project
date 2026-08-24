# ==============================================================================
# STEP 0: PROVIDER & SETUP
# ==============================================================================
terraform {
  required_version = ">= 1.5.0"

  # Standard remote state storage
  backend "s3" {
    bucket       = "my-company-prod-terraform-state-bucket-test2"
    key          = "dev/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  # Standard enterprise practice: global tagging across all resources
  default_tags {
    tags = {
      Environment = "dev"
      ManagedBy   = "terraform"
    }
  }
}

# ==============================================================================
# STEP 1: CORE NETWORKING (Custom VPC, Subnet, IGW & Routing)
# ==============================================================================

# 1. Custom VPC
resource "aws_vpc" "custom_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "dev-custom-vpc"
  }
}

# 2. Internet Gateway (The physical door to the internet)
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.custom_vpc.id

  tags = {
    Name = "dev-internet-gateway"
  }
}

# 3. Public Subnet
resource "aws_subnet" "custom_public_subnet" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a" # Explicitly place in an AZ
  map_public_ip_on_launch = true

  tags = {
    Name = "dev-public-subnet"
  }
}

# 4. Route Table (Directs outbound traffic to the Internet Gateway)
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "dev-public-route-table"
  }
}

# 5. Route Table Association (Wires the Subnet to the Route Table)
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.custom_public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# ==============================================================================
# STEP 2: STORAGE (S3 Media Bucket for Django Uploads)
# ==============================================================================

# 1. The Main Bucket
resource "aws_s3_bucket" "app_media" {
  # Use a unique name (or bucket_prefix) for real AWS
  bucket = "my-company-prod-django-media-uploads-bucket-test"

  tags = {
    Name        = "django-media-storage"
    Environment = "dev"
  }
}

# 2. Ownership Controls (Enforce IAM policies over legacy ACLs)
resource "aws_s3_bucket_ownership_controls" "app_media_ownership" {
  bucket = aws_s3_bucket.app_media.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# 3. Block Public Access (Serve media via Django / CloudFront / Presigned URLs)
resource "aws_s3_bucket_public_access_block" "app_media_public_block" {
  bucket = aws_s3_bucket.app_media.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 4. Server-Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "app_media_encryption" {
  bucket = aws_s3_bucket.app_media.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 5. CORS (Allows your React frontend to view and upload media)
resource "aws_s3_bucket_cors_configuration" "app_media_cors" {
  bucket = aws_s3_bucket.app_media.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "HEAD"]
    allowed_origins = ["*"] # In strict production, replace "*" with your domain (e.g., "https://myapp.com")
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# 6. Lifecycle Rule (Cleans up failed/abandoned uploads automatically)
resource "aws_s3_bucket_lifecycle_configuration" "app_media_lifecycle" {
  bucket = aws_s3_bucket.app_media.id

  rule {
    id     = "abort-incomplete-multipart-uploads"
    status = "Enabled"

    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# ==============================================================================
# STEP 3: SECURITY & FIREWALL (Attached to our Custom VPC from Step 1)
# ==============================================================================

# 1. The Security Group Container
resource "aws_security_group" "app_firewall" {
  name_prefix = "app-firewall-"
  description = "Production firewall for Web Application (HTTP/HTTPS)"
  vpc_id      = aws_vpc.custom_vpc.id

  lifecycle {
    create_before_destroy = true # Prevents lockups during updates
  }

  tags = {
    Name = "dev-app-firewall"
  }
}

# 2. Allow Public HTTP (Port 80)
resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.app_firewall.id
  description       = "Allow HTTP web traffic"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

# 3. Allow Public HTTPS (Port 443)
resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.app_firewall.id
  description       = "Allow HTTPS secure web traffic"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

# 4. Allow All Outbound Traffic (Needed for EC2 to download Docker images and updates)
resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.app_firewall.id
  description       = "Allow server to reach the internet for updates"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # All protocols
}

# ==============================================================================
# STEP 4: COMPUTE & IAM (Server + Permissions for S3 Media Bucket)
# ==============================================================================

# 1. IAM Role allowing EC2 to talk to your Step 2 S3 Media Bucket
resource "aws_iam_role" "app_server_role" {
  name = "django-server-s3-access-role-test"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

# 2. Policy: Grants Django Read/Write ONLY to your Step 2 Media Bucket
resource "aws_iam_role_policy" "s3_access_policy" {
  name = "django-s3-media-policy"
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
        aws_s3_bucket.app_media.arn,
        "${aws_s3_bucket.app_media.arn}/*"
      ]
    }]
  })
}

# 3. Instance Profile (The bridge attaching the IAM Role to the EC2 Instance)
resource "aws_iam_instance_profile" "app_server_profile" {
  name = "django-server-instance-profile-test2"
  role = aws_iam_role.app_server_role.name
}

# 4. The Production EC2 Instance
resource "aws_instance" "app_server" {
  ami                  = var.instance_ami # <--- Uses the variable!
  instance_type        = "t3.micro"
  subnet_id            = aws_subnet.custom_public_subnet.id
  iam_instance_profile = aws_iam_instance_profile.app_server_profile.name

  vpc_security_group_ids = [aws_security_group.app_firewall.id]

 # ----------------------------------------------------------------------------
  # PRODUCTION DISK CONFIGURATION:
  # (Uncomment when deploying to real AWS with a real Ubuntu AMI)
  # ----------------------------------------------------------------------------
  # root_block_device {
  #   volume_size           = 20
  #   volume_type           = "gp3"
  #   encrypted             = true
  #   delete_on_termination = true
  # }

  user_data_replace_on_change = true

  user_data = <<-EOF
              #!/bin/bash
              set -e

              # 1. Update and install Docker
              apt-get update -y
              apt-get install -y docker.io
              systemctl enable --now docker

              # 2. Pull and start containers
              docker run -d --restart always -p 80:80 your-dockerhub-user/my-react-app:latest
              docker run -d --restart always -p 8000:8000 your-dockerhub-user/my-django-app:latest
              EOF

  tags = {
    Name = "fullstack-react-django-server"
  }
}

# ==============================================================================
# STEP 5: OUTPUTS (Values displayed on screen & exported for CI/CD)
# ==============================================================================

output "vpc_id" {
  description = "The ID of our custom VPC"
  value       = aws_vpc.custom_vpc.id
}

output "server_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}

output "app_url" {
  description = "Clickable URL to access the deployed frontend"
  value       = "http://${aws_instance.app_server.public_ip}"
}

output "media_bucket_name" {
  description = "S3 bucket name for Django media uploads"
  value       = aws_s3_bucket.app_media.bucket
}

output "media_bucket_arn" {
  description = "S3 bucket ARN for IAM/CDN integration"
  value       = aws_s3_bucket.app_media.arn
}