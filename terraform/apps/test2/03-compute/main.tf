module "app_server" {
  source = "../../../modules/ec2-app-server"
  environment   = var.environment
  vpc_id        = data.terraform_remote_state.networking.outputs.vpc_id
  subnet_id     = data.terraform_remote_state.networking.outputs.public_subnet_id
  s3_bucket_arn = data.terraform_remote_state.storage.outputs.media_bucket_arn
  instance_type = var.instance_type
  instance_ami  = var.instance_ami
}