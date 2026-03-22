output "alb_dns_name" {
  description = "ALB public DNS — use this to reach your app"
  value       = aws_lb.main.dns_name
}

output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.app.id
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "cloudwatch_log_group_app" {
  description = "App log group name"
  value       = aws_cloudwatch_log_group.app.name
}

output "cloudwatch_log_group_system" {
  description = "System log group name"
  value       = aws_cloudwatch_log_group.system.name
}
