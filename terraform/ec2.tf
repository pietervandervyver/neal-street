# Security group for EC2 — only allow traffic from ALB
resource "aws_security_group" "ec2" {
  name        = "${var.env}-ec2-sg"
  description = "EC2 security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.env}-ec2-sg" }
}

resource "aws_key_pair" "app" {
  key_name   = "${var.env}-app-key"
  public_key = file("~/.ssh/id_ed25519.pub")
}

resource "aws_instance" "app" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.ec2.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_cloudwatch.name
  key_name               = aws_key_pair.app.key_name

  # Minimal user_data — just install SSM agent so Ansible can connect via SSM
  user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y amazon-ssm-agent
    systemctl enable amazon-ssm-agent
    systemctl start amazon-ssm-agent
  EOF

  tags = { Name = "${var.env}-app-server" }
}
