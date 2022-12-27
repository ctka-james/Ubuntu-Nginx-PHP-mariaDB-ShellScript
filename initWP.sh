#!/bin/bash
sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/wordpress.conf
sudo chown -R $USER:$USER /etc/nginx/sites-available/wordpress.conf
sudo ln -s /etc/nginx/sites-available/wordpress.conf /etc/nginx/sites-enabled/
sudo mkdir /var/www/wordpress
wget https://wordpress.org/latest.zip
unzip latest.zip
sudo mv wordpress/* /var/www/wordpress
sudo chmod -R +x /var/www/wordpress
sudo chown -R www-data:www-data /var/www/wordpress
rm -R wordpress/
rm latest.zip
echo "1. Edit /etc/nginx/sites-available/wordpress.conf server_name and root \n
2. sudo nginx -t (if OK than do 3 step) \n
3. sudo nginx -s reload \n"