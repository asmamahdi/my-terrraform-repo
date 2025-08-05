#!/bin/bash
# Stop Server Script for CodeDeploy
# Owner: Touqeer Hussain

echo "Stopping Apache web server..."

# Stop Apache service
systemctl stop httpd

# Check if Apache is stopped
if ! systemctl is-active --quiet httpd; then
    echo "Apache web server stopped successfully"
    exit 0
else
    echo "Failed to stop Apache web server"
    exit 1
fi