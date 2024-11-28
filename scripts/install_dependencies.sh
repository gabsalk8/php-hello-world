#!/bin/bash

# Update yum
yum update -y

# Install Nginx
amazon-linux-extras enable nginx1
yum install -y nginx

# Start Nginx and enable it to start on boot
systemctl start nginx
systemctl enable nginx

# Install PHP
amazon-linux-extras enable php7.4
yum install -y php php-fpm

# Install additional PHP modules if needed
yum install -y php-mysqlnd php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap

# Configure PHP-FPM to work with Nginx
sed -i 's/user = apache/user = nginx/' /etc/php-fpm.d/www.conf
sed -i 's/group = apache/group = nginx/' /etc/php-fpm.d/www.conf

# Start PHP-FPM and enable it to start on boot
systemctl start php-fpm
systemctl enable php-fpm

# Restart Nginx to pick up the PHP-FPM changes
systemctl restart nginx

# Check if Nginx was installed and started successfully
if systemctl is-active --quiet nginx; then
    echo "Nginx installed and started successfully"
else
    echo "Nginx installation or startup failed"
    exit 1
fi

# Check if PHP was installed successfully
if command -v php &> /dev/null; then
    echo "PHP installed successfully"
    php -v
else
    echo "PHP installation failed"
    exit 1
fi

# Check if PHP-FPM is running
if systemctl is-active --quiet php-fpm; then
    echo "PHP-FPM is running"
else
    echo "PHP-FPM is not running"
    exit 1
fi

echo "Nginx and PHP installation completed successfully"