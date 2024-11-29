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

# Configure Nginx to use /var/www/html as the web root
cat > /etc/nginx/conf.d/default.conf << EOL
server {
    listen 80;
    server_name _;
    root /var/www/html;
    index index.html index.htm index.php;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php-fpm/www.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }
}
EOL

# Create the /var/www/html directory if it doesn't exist
mkdir -p /var/www/html

# Set appropriate permissions
chown -R nginx:nginx /var/www/html
chmod -R 755 /var/www/html

# Restart Nginx to pick up the changes
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
echo "Web root is set to /var/www/html"
