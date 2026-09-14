terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket         = "my-company-prod-terraform-state-bucket-test2"
    key            = "prod/terraform.tfstate"     # <--- Only this key changes!
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks"
  }
}