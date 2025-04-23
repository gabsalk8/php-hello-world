#!/bin/bash
if [ -d /var/www/html ]; then
    rm -rf /var/www/html/*
    echo "Cleaned /var/www/html directory"
else
    echo "Directory /var/www/html does not exist"
fi

    
