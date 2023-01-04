#!/bin/bash
# WordPress目錄權限設定
sudo chown -R $USER:www-data /var/www/$1
sudo chmod 750 -R /var/www/$1/wp-admin/
sudo chmod 750 -R /var/www/$1/wp-includes/
sudo chmod 640 /var/www/$1/wp-config.php
sudo mkdir /var/www/$1/wp-content/uploads
sudo chown -R www-data:www-data /var/www/$1/wp-content/uploads/
echo '\n'
echo '已更改目錄權限!!'