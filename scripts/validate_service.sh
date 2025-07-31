#!/bin/bash
# Validate Service Script for CodeDeploy
# Owner: Touqeer Hussain

echo "Validating web service..."

# Wait for Apache to fully start
sleep 10

# Check if Apache is running
if ! systemctl is-active --quiet httpd; then
    echo "ERROR: Apache web server is not running"
    exit 1
fi

# Check if Apache is listening on port 80
if ! netstat -tuln | grep -q ":80 "; then
    echo "ERROR: Apache is not listening on port 80"
    exit 1
fi

# Test health check endpoint
echo "Testing health check endpoint..."
health_response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/health)

if [ "$health_response" != "200" ]; then
    echo "ERROR: Health check endpoint returned HTTP $health_response"
    exit 1
fi

# Test main application endpoint
echo "Testing main application endpoint..."
app_response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/)

if [ "$app_response" != "200" ]; then
    echo "WARNING: Main application endpoint returned HTTP $app_response"
    # Don't fail deployment for main app issues, just warn
fi

# Check disk space
disk_usage=$(df /var/www/html | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$disk_usage" -gt 90 ]; then
    echo "WARNING: Disk usage is high ($disk_usage%)"
fi

# Check if log files are being written
if [ ! -f /var/log/httpd/access_log ]; then
    echo "WARNING: Apache access log not found"
fi

if [ ! -f /var/log/httpd/error_log ]; then
    echo "WARNING: Apache error log not found"
fi

echo "Service validation completed successfully"
echo "Apache is running and responding to requests"
exit 0