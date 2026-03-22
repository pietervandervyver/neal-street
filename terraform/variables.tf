variable "env" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Public subnet CIDR"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "Private subnet CIDR"
  type        = string
  default     = "10.0.2.0/24"
}

variable "az" {
  description = "Primary availability zone"
  type        = string
  default     = "us-east-1a"
}

variable "az_secondary" {
  description = "Secondary availability zone (required for ALB)"
  type        = string
  default     = "us-east-1b"
}

variable "public_subnet_cidr_secondary" {
  description = "Secondary public subnet CIDR (ALB requirement)"
  type        = string
  default     = "10.0.3.0/24"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "Amazon Linux 2 AMI ID (update per region)"
  type        = string
  default     = "ami-0c02fb55956c7d316" # Amazon Linux 2, us-east-1
}
