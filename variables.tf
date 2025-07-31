# AWS Practice Environment Variables
# Owner: Touqeer Hussain

# General Variables
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "eu-west-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "AWS Practice Environment"
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "Touqeer Hussain"
}

# VPC Variables
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_app_subnet_cidrs" {
  description = "CIDR blocks for private app subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "private_db_subnet_cidrs" {
  description = "CIDR blocks for private database subnets"
  type        = list(string)
  default     = ["10.0.20.0/24", "10.0.21.0/24"]
}

# Security Variables
variable "your_ip" {
  description = "Your IP address for SSH access (CIDR format)"
  type        = string
  default     = "0.0.0.0/0"  # Change this to your actual IP for security
}

# EC2 Variables
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "min_size" {
  description = "Minimum number of EC2 instances in ASG"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of EC2 instances in ASG"
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "Desired number of EC2 instances in ASG"
  type        = number
  default     = 2
}

# RDS Variables
variable "db_engine" {
  description = "Database engine"
  type        = string
  default     = "mysql"
}

variable "db_engine_version" {
  description = "Database engine version"
  type        = string
  default     = "8.0"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "RDS allocated storage in GB"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "practicedb"
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Database password"
  type        = string
  default     = "maf141259"
  sensitive   = true
}

variable "backup_retention_period" {
  description = "RDS backup retention period in days"
  type        = number
  default     = 7
}

# S3 Variables
variable "assets_bucket_name" {
  description = "S3 bucket name for app assets"
  type        = string
  default     = "dev-app-assets-touqeer-practice"  # Must be globally unique
}

variable "logs_bucket_name" {
  description = "S3 bucket name for logs"
  type        = string
  default     = "dev-app-logs-touqeer-practice"  # Must be globally unique
}

variable "log_expiration_days" {
  description = "Number of days after which logs expire"
  type        = number
  default     = 30
}

# CodeCommit Variables
variable "repository_name" {
  description = "CodeCommit repository name"
  type        = string
  default     = "dev-practice-app"
}

variable "repository_description" {
  description = "CodeCommit repository description"
  type        = string
  default     = "Practice application repository for AWS learning"
}

# CloudWatch Variables
variable "cpu_alarm_threshold" {
  description = "CPU utilization threshold for CloudWatch alarm"
  type        = number
  default     = 80
}

variable "memory_alarm_threshold" {
  description = "Memory utilization threshold for CloudWatch alarm"
  type        = number
  default     = 70
}

# Key Pair Variables
variable "key_pair_name" {
  description = "Name of the EC2 Key Pair"
  type        = string
  default     = "dev-practice-keypair"
}