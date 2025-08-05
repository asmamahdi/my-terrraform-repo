# AWS Practice Environment - Low Level Design Implementation
# Owner: Touqeer Hussain
# Environment: Development
# Region: eu-west-2 (London)

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      Owner       = var.owner
      ManagedBy   = "Terraform"
    }
  }
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# VPC
resource "aws_vpc" "practice_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = "${var.environment}-network-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "practice_igw" {
  vpc_id = aws_vpc.practice_vpc.id
  
  tags = {
    Name = "${var.environment}-network-igw"
  }
}

# Public Subnets
resource "aws_subnet" "public_subnets" {
  count = length(var.public_subnet_cidrs)
  
  vpc_id                  = aws_vpc.practice_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  
  tags = {
    Name = "${var.environment}-public-subnet-${substr(data.aws_availability_zones.available.names[count.index], -1, 1)}"
    Type = "Public"
  }
}

# Private App Subnets
resource "aws_subnet" "private_app_subnets" {
  count = length(var.private_app_subnet_cidrs)
  
  vpc_id            = aws_vpc.practice_vpc.id
  cidr_block        = var.private_app_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  tags = {
    Name = "${var.environment}-private-app-subnet-${substr(data.aws_availability_zones.available.names[count.index], -1, 1)}"
    Type = "Private-App"
  }
}

# Private DB Subnets
resource "aws_subnet" "private_db_subnets" {
  count = length(var.private_db_subnet_cidrs)
  
  vpc_id            = aws_vpc.practice_vpc.id
  cidr_block        = var.private_db_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  tags = {
    Name = "${var.environment}-private-db-subnet-${substr(data.aws_availability_zones.available.names[count.index], -1, 1)}"
    Type = "Private-DB"
  }
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat_eips" {
  count = length(var.public_subnet_cidrs)
  
  domain = "vpc"
  depends_on = [aws_internet_gateway.practice_igw]
  
  tags = {
    Name = "${var.environment}-nat-eip-${count.index + 1}"
  }
}

# NAT Gateways
resource "aws_nat_gateway" "nat_gateways" {
  count = length(var.public_subnet_cidrs)
  
  allocation_id = aws_eip.nat_eips[count.index].id
  subnet_id     = aws_subnet.public_subnets[count.index].id
  
  tags = {
    Name = "${var.environment}-nat-gw-${count.index + 1}"
  }
  
  depends_on = [aws_internet_gateway.practice_igw]
}

# Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.practice_vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.practice_igw.id
  }
  
  tags = {
    Name = "${var.environment}-public-rt"
  }
}

# Private App Route Tables
resource "aws_route_table" "private_app_rt" {
  count = length(var.private_app_subnet_cidrs)
  
  vpc_id = aws_vpc.practice_vpc.id
  
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateways[count.index].id
  }
  
  tags = {
    Name = "${var.environment}-private-app-rt-${count.index + 1}"
  }
}

# Private DB Route Tables
resource "aws_route_table" "private_db_rt" {
  count = length(var.private_db_subnet_cidrs)
  
  vpc_id = aws_vpc.practice_vpc.id
  
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateways[count.index].id
  }
  
  tags = {
    Name = "${var.environment}-private-db-rt-${count.index + 1}"
  }
}

# Route Table Associations
resource "aws_route_table_association" "public_rta" {
  count = length(aws_subnet.public_subnets)
  
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_app_rta" {
  count = length(aws_subnet.private_app_subnets)
  
  subnet_id      = aws_subnet.private_app_subnets[count.index].id
  route_table_id = aws_route_table.private_app_rt[count.index].id
}

resource "aws_route_table_association" "private_db_rta" {
  count = length(aws_subnet.private_db_subnets)
  
  subnet_id      = aws_subnet.private_db_subnets[count.index].id
  route_table_id = aws_route_table.private_db_rt[count.index].id
}