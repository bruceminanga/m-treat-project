# ==============================================================================
# FIREWALL & SECURITY GROUP
# ==============================================================================
resource "aws_security_group" "app_firewall" {
  name_prefix = "app-firewall-${var.environment}-"
  description = "Firewall for Web Application"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.environment}-app-firewall"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.app_firewall.id
  description       = "Allow HTTP web traffic"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.app_firewall.id
  description       = "Allow HTTPS secure web traffic"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.app_firewall.id
  description       = "Allow server to reach the internet for updates"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}