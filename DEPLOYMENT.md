# AWS Practice Environment - Deployment Guide

This guide provides step-by-step instructions for deploying the AWS Practice Environment infrastructure.

## 🛠️ Prerequisites Checklist

Before deploying, ensure you have:

- [ ] AWS CLI installed and configured with appropriate permissions
- [ ] Terraform >= 1.0 installed
- [ ] Your public IP address identified
- [ ] Git installed (for CodeCommit integration)

### Required AWS Permissions

Your AWS user/role needs the following permissions:
- EC2 full access
- VPC full access
- RDS full access
- S3 full access
- IAM full access
- CloudWatch full access
- CodeCommit, CodeBuild, CodeDeploy, CodePipeline full access
- Application Load Balancer full access

## 🚀 Step-by-Step Deployment

### Step 1: Clone Repository

```bash
git clone <your-repository-url>
cd aws-practice-environment
```

### Step 2: Generate SSH Key Pair

```bash
# Create keys directory
mkdir -p keys

# Generate SSH key pair
ssh-keygen -t rsa -b 4096 -f keys/practice-key -N ""

# Set proper permissions
chmod 600 keys/practice-key
chmod 644 keys/practice-key.pub
```

### Step 3: Get Your Public IP

```bash
# Get your public IP
curl -s https://ifconfig.me
```

### Step 4: Configure Variables

```bash
# Copy example variables file
cp terraform.tfvars.example terraform.tfvars

# Edit the file with your values
nano terraform.tfvars
```

**Important configurations to update:**

1. **your_ip**: Replace with your actual public IP in CIDR format (e.g., "203.0.113.1/32")
2. **S3 bucket names**: Must be globally unique
   ```
   assets_bucket_name = "dev-app-assets-yourname-unique-12345"
   logs_bucket_name   = "dev-app-logs-yourname-unique-12345"
   ```
3. **db_password**: Use a strong, secure password
4. **Email for SNS**: Update the email in `monitoring.tf` line 235

### Step 5: Initialize Terraform

```bash
terraform init
```

### Step 6: Plan Deployment

```bash
terraform plan
```

Review the plan carefully. You should see approximately 50+ resources to be created.

### Step 7: Deploy Infrastructure

```bash
terraform apply
```

Type `yes` when prompted. Deployment will take approximately 15-20 minutes.

## 📋 Post-Deployment Steps

### Step 1: Verify Deployment

After successful deployment, verify the outputs:

```bash
terraform output
```

You should see outputs including:
- ALB DNS name
- VPC ID
- Subnet IDs
- RDS endpoint
- CodeCommit repository URLs

### Step 2: Test Web Application

1. Get the ALB DNS name from terraform outputs
2. Open in browser: `http://<alb-dns-name>`
3. You should see the AWS Practice Environment page

### Step 3: Access Bastion Host

```bash
# Get bastion public IP from EC2 console or terraform output
ssh -i keys/practice-key ec2-user@<bastion-public-ip>
```

### Step 4: Test Database Connection

From bastion host:
```bash
mysql -h <rds-endpoint> -u admin -p
# Enter password: maf141259 (or your custom password)
```

### Step 5: Configure CI/CD Pipeline

1. Clone the CodeCommit repository:
```bash
git clone <codecommit-clone-url>
cd <repository-name>
```

2. Add sample application files:
```bash
# Copy buildspec.yml and appspec.yml to the repository
cp ../buildspec.yml .
cp ../appspec.yml .
cp -r ../scripts .

# Create a simple index.php
cat > index.php << 'EOF'
<?php
echo "<h1>Hello from CI/CD Pipeline!</h1>";
echo "<p>Deployed via CodePipeline</p>";
?>
EOF

# Commit and push
git add .
git commit -m "Initial application deployment"
git push origin main
```

3. Monitor the pipeline in AWS CodePipeline console

## 🔍 Troubleshooting

### Common Issues

1. **S3 Bucket Name Already Exists**
   - Update bucket names in `terraform.tfvars` to be globally unique

2. **Key Pair File Not Found**
   - Ensure SSH key pair is generated in the `keys/` directory
   - Check file permissions (600 for private key, 644 for public key)

3. **RDS Connection Failed**
   - Verify security groups allow connection from bastion/EC2 instances
   - Check RDS endpoint and credentials

4. **ALB Health Check Failing**
   - Ensure `/health` endpoint exists and returns HTTP 200
   - Check security group rules for ALB to EC2 communication

5. **CodeDeploy Deployment Failed**
   - Check CodeDeploy agent is installed on EC2 instances
   - Verify IAM roles have proper permissions
   - Review deployment logs in CodeDeploy console

### Useful Commands

```bash
# Check Terraform state
terraform show

# Refresh state
terraform refresh

# View specific resource
terraform state show aws_vpc.practice_vpc

# Check AWS resources
aws ec2 describe-instances --region eu-west-2
aws rds describe-db-instances --region eu-west-2
aws elbv2 describe-load-balancers --region eu-west-2
```

## 🔧 Customization

### Scaling Configuration

To modify Auto Scaling Group settings:

```hcl
# In terraform.tfvars
min_size         = 2
max_size         = 5
desired_capacity = 3
```

### Instance Types

To change instance types:

```hcl
# In terraform.tfvars
instance_type     = "t3.small"
db_instance_class = "db.t3.small"
```

### Monitoring Thresholds

To adjust alarm thresholds:

```hcl
# In terraform.tfvars
cpu_alarm_threshold    = 70
memory_alarm_threshold = 80
```

## 🧹 Cleanup

To destroy all resources:

```bash
terraform destroy
```

**⚠️ Warning**: This will permanently delete all resources and data.

## 📞 Support

If you encounter issues:

1. Check CloudWatch logs for application errors
2. Review Terraform state and plan
3. Verify AWS service limits
4. Check IAM permissions
5. Review security group configurations

## 📚 Additional Resources

- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS CodePipeline User Guide](https://docs.aws.amazon.com/codepipeline/latest/userguide/)

---

**Environment**: Development  
**Owner**: Touqeer Hussain  
**Last Updated**: $(date)