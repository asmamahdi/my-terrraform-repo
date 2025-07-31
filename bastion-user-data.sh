#!/bin/bash
# User Data Script for Bastion Host
# Owner: Touqeer Hussain

# Update system
yum update -y

# Install required packages
yum install -y mysql git htop nano vim aws-cli

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Configure timezone
timedatectl set-timezone UTC

# Create a welcome message
cat > /etc/motd <<EOF
*********************************************************
*                                                       *
*           AWS Practice Environment                    *
*                 Bastion Host                         *
*                                                       *
*  This is a bastion host for secure access to         *
*  private resources in the AWS practice environment   *
*                                                       *
*  Owner: Touqeer Hussain                              *
*  Environment: Development                             *
*                                                       *
*********************************************************

Available tools:
- AWS CLI v2
- MySQL client
- Git
- Standard Linux tools (htop, nano, vim)

Usage:
- Connect to RDS: mysql -h <rds-endpoint> -u admin -p
- Access private EC2 instances via SSH
- Manage AWS resources via CLI

EOF

# Create useful aliases
cat >> /home/ec2-user/.bashrc <<EOF

# Custom aliases for AWS Practice Environment
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# AWS specific aliases
alias awsprofile='aws configure list'
alias awsregion='aws configure get region'
alias ec2list='aws ec2 describe-instances --query "Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType,PublicIpAddress,PrivateIpAddress]" --output table'
alias rdslist='aws rds describe-db-instances --query "DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus,Engine,DBInstanceClass,Endpoint.Address]" --output table'

# Environment variables
export AWS_DEFAULT_REGION=eu-west-2
export ENVIRONMENT=dev

EOF

# Set proper permissions
chown ec2-user:ec2-user /home/ec2-user/.bashrc

# Configure SSH client for better security
cat >> /etc/ssh/ssh_config <<EOF

# Custom SSH configuration for bastion host
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3
    StrictHostKeyChecking ask
    UserKnownHostsFile ~/.ssh/known_hosts
    IdentitiesOnly yes

EOF

# Create a directory for SSH keys
mkdir -p /home/ec2-user/.ssh
chown ec2-user:ec2-user /home/ec2-user/.ssh
chmod 700 /home/ec2-user/.ssh

# Log completion
echo "Bastion host user data script completed at $(date)" >> /var/log/user-data.log

# Display system information
echo "System Information:" >> /var/log/user-data.log
echo "Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)" >> /var/log/user-data.log
echo "Instance Type: $(curl -s http://169.254.169.254/latest/meta-data/instance-type)" >> /var/log/user-data.log
echo "Availability Zone: $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)" >> /var/log/user-data.log
echo "Public IP: $(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)" >> /var/log/user-data.log
echo "Private IP: $(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)" >> /var/log/user-data.log