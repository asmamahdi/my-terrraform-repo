#!/bin/bash
# Cleanup Script for CodeDeploy
# Owner: Touqeer Hussain

echo "Performing cleanup tasks..."

# Remove old application files (except health check)
find /var/www/html -type f -name "*.php" -not -name "health" -delete
find /var/www/html -type f -name "*.html" -not -name "health" -delete
find /var/www/html -type f -name "*.js" -delete
find /var/www/html -type f -name "*.css" -delete

# Clean up temporary files
rm -rf /tmp/codedeploy-*
rm -rf /var/www/html/tmp/*

# Clear Apache logs if they're too large (>100MB)
if [ -f /var/log/httpd/access_log ] && [ $(stat -f%z /var/log/httpd/access_log 2>/dev/null || stat -c%s /var/log/httpd/access_log) -gt 104857600 ]; then
    echo "Rotating large access log"
    > /var/log/httpd/access_log
fi

if [ -f /var/log/httpd/error_log ] && [ $(stat -f%z /var/log/httpd/error_log 2>/dev/null || stat -c%s /var/log/httpd/error_log) -gt 104857600 ]; then
    echo "Rotating large error log"
    > /var/log/httpd/error_log
fi

echo "Cleanup completed successfully"
exit 0