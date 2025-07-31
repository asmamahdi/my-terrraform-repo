#!/bin/bash
# Install Dependencies Script for CodeDeploy
# Owner: Touqeer Hussain

echo "Installing application dependencies..."

# Update system packages
yum update -y

# Install required packages if not already installed
yum install -y httpd php php-mysql mysql git

# Install Composer if needed (for PHP dependencies)
if [ ! -f /usr/local/bin/composer ]; then
    echo "Installing Composer..."
    curl -sS https://getcomposer.org/installer | php
    mv composer.phar /usr/local/bin/composer
    chmod +x /usr/local/bin/composer
fi

# Install Node.js and npm if needed
if ! command -v node &> /dev/null; then
    echo "Installing Node.js..."
    curl -fsSL https://rpm.nodesource.com/setup_16.x | bash -
    yum install -y nodejs
fi

# Install application dependencies if composer.json exists
if [ -f /var/www/html/composer.json ]; then
    echo "Installing PHP dependencies with Composer..."
    cd /var/www/html
    /usr/local/bin/composer install --no-dev --optimize-autoloader
fi

# Install Node.js dependencies if package.json exists
if [ -f /var/www/html/package.json ]; then
    echo "Installing Node.js dependencies..."
    cd /var/www/html
    npm install --production
fi

# Create necessary directories
mkdir -p /var/www/html/logs
mkdir -p /var/www/html/tmp
mkdir -p /var/www/html/uploads

echo "Dependencies installation completed successfully"
exit 0