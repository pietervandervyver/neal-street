# Centralised log group for all app/system logs
resource "aws_cloudwatch_log_group" "app" {
  name              = "/${var.env}/app"
  retention_in_days = 30

  tags = { Name = "${var.env}-app-logs" }
}

resource "aws_cloudwatch_log_group" "system" {
  name              = "/${var.env}/system"
  retention_in_days = 30

  tags = { Name = "${var.env}-system-logs" }
}

resource "aws_cloudwatch_log_group" "alb" {
  name              = "/${var.env}/alb"
  retention_in_days = 30

  tags = { Name = "${var.env}-alb-logs" }
}

# IAM role for EC2 to ship logs via CloudWatch agent
resource "aws_iam_role" "ec2_cloudwatch" {
  name = "${var.env}-ec2-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.ec2_cloudwatch.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_cloudwatch.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_cloudwatch" {
  name = "${var.env}-ec2-cloudwatch-profile"
  role = aws_iam_role.ec2_cloudwatch.name
}

# CloudWatch Logs Insights saved queries
resource "aws_cloudwatch_query_definition" "error_logs" {
  name = "${var.env}/errors"

  log_group_names = [
    aws_cloudwatch_log_group.app.name,
    aws_cloudwatch_log_group.system.name,
  ]

  query_string = <<-EOT
    fields @timestamp, @message
    | filter @message like /(?i)error/
    | sort @timestamp desc
    | limit 100
  EOT
}

resource "aws_cloudwatch_query_definition" "alb_5xx" {
  name = "${var.env}/alb-5xx"

  log_group_names = [aws_cloudwatch_log_group.alb.name]

  query_string = <<-EOT
    fields @timestamp, @message
    | filter @message like /HTTP\/1\.[01]" 5/
    | sort @timestamp desc
    | limit 100
  EOT
}

# Basic alarm — high error rate in app logs
resource "aws_cloudwatch_metric_alarm" "app_errors" {
  alarm_name          = "${var.env}-app-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "IncomingLogEvents"
  namespace           = "AWS/Logs"
  period              = 60
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "High error log volume in ${var.env}"

  dimensions = {
    LogGroupName = aws_cloudwatch_log_group.app.name
  }
}
