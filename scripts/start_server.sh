#!/bin/bash
# Start Server Script for CodeDeploy
# Owner: Touqeer Hussain

echo "Starting Apache web server..."

# Start Apache service
systemctl start httpd

# Enable Apache to start on boot
systemctl enable httpd

# Check if Apache is running
if systemctl is-active --quiet httpd; then
    echo "Apache web server started successfully"
    exit 0
else
    echo "Failed to start Apache web server"
    exit 1
fi