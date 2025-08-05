# AWS Practice Environment - Infrastructure as Code

This repository contains Terraform code to implement a comprehensive AWS practice environment based on the Low-Level Design (LLD) document.

## 🏗️ Architecture Overview

The infrastructure includes:

- **VPC**: Custom VPC with public and private subnets across 2 AZs
- **Compute**: Auto Scaling Group with EC2 instances behind an Application Load Balancer
- **Database**: Multi-AZ RDS MySQL instance
- **Storage**: S3 buckets for assets and logs
- **CI/CD**: Complete pipeline with CodeCommit, CodeBuild, CodeDeploy, and CodePipeline
- **Monitoring**: CloudWatch logs, metrics, alarms, and dashboard
- **Security**: Security groups, IAM roles, and VPC Flow Logs

## 📋 Prerequisites

1. **AWS CLI** configured with appropriate permissions
2. **Terraform** >= 1.0 installed
3. **SSH Key Pair** generated for EC2 access
4. **Your Public IP** for security group access

## 🚀 Quick Start

### 1. Clone and Setup

```bash
git clone <repository-url>
cd aws-practice-environment
```

### 2. Generate SSH Key Pair

```bash
mkdir -p keys
ssh-keygen -t rsa -b 4096 -f keys/practice-key -N ""
```

### 3. Configure Variables

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values:
- Replace `YOUR_PUBLIC_IP/32` with your actual public IP
- Update S3 bucket names to be globally unique
- Modify other values as needed

### 4. Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Apply configuration
terraform apply
```

### 5. Access Your Environment

After deployment, you'll get outputs including:
- ALB DNS name for web access
- Bastion host public IP for SSH access
- RDS endpoint for database connection

## 📁 File Structure

```
├── main.tf                 # Main Terraform configuration
├── variables.tf            # Variable definitions
├── outputs.tf             # Output values
├── security-groups.tf     # Security group configurations
├── load-balancer.tf       # ALB and target group setup
├── ec2-asg.tf            # EC2 Auto Scaling Group
├── rds.tf                # RDS database configuration
├── s3.tf                 # S3 bucket setup
├── cicd.tf               # CI/CD pipeline resources
├── monitoring.tf         # CloudWatch and monitoring
├── user-data.sh          # EC2 instance startup script
├── bastion-user-data.sh  # Bastion host startup script
├── buildspec.yml         # CodeBuild build specification
├── appspec.yml           # CodeDeploy deployment specification
└── README.md             # This file
```

## 🔧 Configuration Details

### Network Configuration

- **VPC CIDR**: 10.0.0.0/16
- **Public Subnets**: 10.0.0.0/24, 10.0.1.0/24
- **Private App Subnets**: 10.0.10.0/24, 10.0.11.0/24
- **Private DB Subnets**: 10.0.20.0/24, 10.0.21.0/24

### Security Groups

| Security Group | Purpose | Inbound Rules |
|----------------|---------|---------------|
| alb-sg | Application Load Balancer | HTTP (80), HTTPS (443) from 0.0.0.0/0 |
| ec2-web-sg | Web EC2 instances | HTTP/HTTPS from ALB, SSH from bastion/your IP |
| rds-sg | RDS database | MySQL (3306) from web instances and bastion |
| bastion-sg | Bastion host | SSH (22) from your IP |

### Monitoring and Alarms

- **CPU Utilization**: Triggers scaling when > 80%
- **ALB Response Time**: Alerts when > 1 second
- **RDS CPU**: Alerts when > 80%
- **Unhealthy Targets**: Alerts when any targets are unhealthy

## 🔐 Security Best Practices

1. **Update your IP**: Change `your_ip` variable to your actual public IP
2. **Strong passwords**: Use strong, unique passwords for RDS
3. **Key management**: Store SSH private keys securely
4. **IAM permissions**: Use least privilege principle
5. **Encryption**: All storage is encrypted at rest

## 🚀 CI/CD Pipeline

The infrastructure includes a complete CI/CD pipeline:

1. **CodeCommit**: Git repository for source code
2. **CodeBuild**: Builds and packages the application
3. **CodeDeploy**: Deploys to EC2 instances with zero downtime
4. **CodePipeline**: Orchestrates the entire pipeline

### Using the Pipeline

1. Clone the CodeCommit repository:
```bash
git clone <codecommit-clone-url>
```

2. Add your application code with:
   - `appspec.yml` (deployment specification)
   - `buildspec.yml` (build specification)
   - Application source code

3. Push changes to trigger the pipeline:
```bash
git add .
git commit -m "Deploy application"
git push origin main
```

## 📊 Monitoring and Logging

### CloudWatch Dashboard

Access the CloudWatch dashboard to monitor:
- EC2 CPU utilization
- ALB request count and response time
- RDS CPU and connections
- Custom application metrics

### Log Groups

- `/aws/ec2/dev-web-app`: Application logs
- `/aws/vpc/flowlogs/dev`: VPC Flow Logs
- `/aws/rds/instance/dev-rds-mysql/*`: RDS logs

## 🔧 Maintenance

### Scaling

The Auto Scaling Group automatically scales based on CPU utilization:
- **Scale Out**: When CPU > 80% for 2 consecutive periods
- **Scale In**: When CPU < 20% for 2 consecutive periods

### Backups

- **RDS**: Automated backups with 7-day retention
- **S3**: Versioning enabled with lifecycle policies

### Updates

To update the infrastructure:

```bash
# Make changes to .tf files
terraform plan
terraform apply
```

## 🧹 Cleanup

To destroy all resources:

```bash
terraform destroy
```

**Warning**: This will permanently delete all resources and data.

## 📞 Support

For issues or questions:
- Check AWS CloudWatch logs for application issues
- Review Terraform state for infrastructure issues
- Ensure all prerequisites are met

## 📝 License

This project is for educational purposes as part of AWS learning and practice.

---

**Owner**: Touqeer Hussain  
**Environment**: Development  
**Region**: eu-west-2 (London)  
**Purpose**: Learning & Implementation Practice

