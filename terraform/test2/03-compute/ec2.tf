# ==============================================================================
# EC2 INSTANCE (The Disposable Server)
# ==============================================================================
resource "aws_instance" "app_server" {
  ami                  = var.instance_ami
  instance_type        = var.instance_type
  subnet_id            = data.terraform_remote_state.networking.outputs.public_subnet_id
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
              apt-get update -y
              apt-get install -y docker.io
              systemctl enable --now docker
              docker run -d --restart always -p 80:80 your-dockerhub-user/my-react-app:latest
              docker run -d --restart always -p 8000:8000 your-dockerhub-user/my-django-app:latest
              EOF

  tags = {
    Name = "${var.environment}-fullstack-server"
  }
}