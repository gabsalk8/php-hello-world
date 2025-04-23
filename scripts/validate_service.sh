#!/bin/bash

if systemctl is-active --quiet httpd; then
    systemctl stop httpd
    echo "Apache web server stopped"
else
    echo "Apache web server is not running"
fi

if [ -d /var/www/html ]; then
    rm -rf /var/www/html/*
    echo "Cleaned /var/www/html directory"
else
    echo "Directory /var/www/html does not exist"
fi

    
