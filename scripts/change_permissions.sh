#!/bin/bash
# Change Permissions Script for CodeDeploy
# Owner: Touqeer Hussain

echo "Setting proper file permissions..."

# Set ownership to apache user
chown -R apache:apache /var/www/html

# Set directory permissions
find /var/www/html -type d -exec chmod 755 {} \;

# Set file permissions
find /var/www/html -type f -exec chmod 644 {} \;

# Set executable permissions for scripts
find /var/www/html -name "*.sh" -exec chmod +x {} \;

# Set special permissions for writable directories
chmod 775 /var/www/html/logs
chmod 775 /var/www/html/tmp
chmod 775 /var/www/html/uploads

# Set proper permissions for configuration files
if [ -f /var/www/html/.env ]; then
    chmod 600 /var/www/html/.env
fi

if [ -f /var/www/html/config.php ]; then
    chmod 600 /var/www/html/config.php
fi

# Ensure health check endpoint is accessible
if [ -f /var/www/html/health ]; then
    chmod 644 /var/www/html/health
fi

echo "File permissions set successfully"
exit 0