#!/bin/bash
# User Data Script for Web Application EC2 Instances
# Owner: Touqeer Hussain

# Update system
yum update -y

# Install required packages
yum install -y httpd php php-mysql mysql git amazon-cloudwatch-agent

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install CodeDeploy agent
yum install -y ruby wget
cd /home/ec2-user
wget https://aws-codedeploy-eu-west-2.s3.eu-west-2.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto

# Configure Apache
systemctl start httpd
systemctl enable httpd

# Create a simple health check endpoint
cat > /var/www/html/health <<EOF
OK
EOF

# Create a sample index page
cat > /var/www/html/index.php <<EOF
<?php
echo "<h1>AWS Practice Environment</h1>";
echo "<h2>Environment: ${environment}</h2>";
echo "<p>Instance ID: " . file_get_contents('http://169.254.169.254/latest/meta-data/instance-id') . "</p>";
echo "<p>Availability Zone: " . file_get_contents('http://169.254.169.254/latest/meta-data/placement/availability-zone') . "</p>";
echo "<p>Instance Type: " . file_get_contents('http://169.254.169.254/latest/meta-data/instance-type') . "</p>";

// Database connection test
\$db_host = "${db_endpoint}";
\$db_name = "${db_name}";
\$db_user = "${db_username}";
\$db_pass = "${db_password}";

try {
    \$pdo = new PDO("mysql:host=\$db_host;dbname=\$db_name", \$db_user, \$db_pass);
    echo "<p style='color: green;'>Database connection: SUCCESS</p>";
} catch(PDOException \$e) {
    echo "<p style='color: red;'>Database connection: FAILED - " . \$e->getMessage() . "</p>";
}

// S3 connection test
\$s3_bucket = "${s3_bucket}";
echo "<p>S3 Bucket: \$s3_bucket</p>";

// Test S3 connectivity
\$s3_test = shell_exec("aws s3 ls s3://\$s3_bucket --region ${region} 2>&1");
if (strpos(\$s3_test, 'error') === false && strpos(\$s3_test, 'Error') === false) {
    echo "<p style='color: green;'>S3 connection: SUCCESS</p>";
} else {
    echo "<p style='color: red;'>S3 connection: FAILED</p>";
}

echo "<p>Current Time: " . date('Y-m-d H:i:s') . "</p>";
?>
EOF

# Create CloudWatch agent configuration
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<EOF
{
    "agent": {
        "metrics_collection_interval": 60,
        "run_as_user": "root"
    },
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/httpd/access_log",
                        "log_group_name": "/aws/ec2/${environment}-web-app",
                        "log_stream_name": "{instance_id}/httpd/access_log"
                    },
                    {
                        "file_path": "/var/log/httpd/error_log",
                        "log_group_name": "/aws/ec2/${environment}-web-app",
                        "log_stream_name": "{instance_id}/httpd/error_log"
                    }
                ]
            }
        }
    },
    "metrics": {
        "namespace": "CWAgent",
        "metrics_collected": {
            "cpu": {
                "measurement": [
                    "cpu_usage_idle",
                    "cpu_usage_iowait",
                    "cpu_usage_user",
                    "cpu_usage_system"
                ],
                "metrics_collection_interval": 60
            },
            "disk": {
                "measurement": [
                    "used_percent"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                    "*"
                ]
            },
            "diskio": {
                "measurement": [
                    "io_time"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                    "*"
                ]
            },
            "mem": {
                "measurement": [
                    "mem_used_percent"
                ],
                "metrics_collection_interval": 60
            }
        }
    }
}
EOF

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s

# Create application directory
mkdir -p /var/www/html/app

# Set proper permissions
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

# Restart Apache
systemctl restart httpd

# Create a simple deployment script for CodeDeploy
mkdir -p /home/ec2-user/scripts
cat > /home/ec2-user/scripts/start_server.sh <<EOF
#!/bin/bash
systemctl start httpd
EOF

cat > /home/ec2-user/scripts/stop_server.sh <<EOF
#!/bin/bash
systemctl stop httpd
EOF

chmod +x /home/ec2-user/scripts/*.sh

# Log completion
echo "User data script completed at $(date)" >> /var/log/user-data.log