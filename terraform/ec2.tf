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

resource "aws_instance" "app" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.ec2.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_cloudwatch.name

  # Installs CloudWatch agent + a basic nginx server on boot
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y nginx amazon-cloudwatch-agent

    # Start nginx
    systemctl enable nginx
    systemctl start nginx

    # CloudWatch agent config — ships nginx + system logs
    cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<'CW'
    {
      "logs": {
        "logs_collected": {
          "files": {
            "collect_list": [
              {
                "file_path": "/var/log/nginx/access.log",
                "log_group_name": "/${var.env}/app",
                "log_stream_name": "{instance_id}/nginx-access"
              },
              {
                "file_path": "/var/log/nginx/error.log",
                "log_group_name": "/${var.env}/app",
                "log_stream_name": "{instance_id}/nginx-error"
              },
              {
                "file_path": "/var/log/messages",
                "log_group_name": "/${var.env}/system",
                "log_stream_name": "{instance_id}/messages"
              }
            ]
          }
        }
      }
    }
    CW

    /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
      -a fetch-config \
      -m ec2 \
      -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
      -s
  EOF

  tags = { Name = "${var.env}-app-server" }
}
