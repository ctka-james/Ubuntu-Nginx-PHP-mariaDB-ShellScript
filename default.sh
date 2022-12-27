#!/bin/bash
# 讓預設的 Nginx 能夠執行 PHP
sudo rm -rf /var/www/html/
sudo mkdir /var/www/html/
sudo chown $USER:$USER /var/www/html/
sudo chown -R $USER:$USER /etc/nginx/sites-available/default
sudo touch /var/www/html/index.php
sudo chown $USER:$USER /var/www/html/index.php
echo "1. Edit /etc/nginx/sites-available/default \n
2. sudo nginx -t (if OK than do 3 step) \n
3. sudo nginx -s reload \n"