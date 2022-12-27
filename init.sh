#!/bin/bash
sudo apt update
sudo apt upgrade
sudo apt install -y zip
# Install Nginx
sudo apt install -y nginx
sudo systemctl enable --now nginx
# firewall 設定
sudo service ufw start
sudo service ufw enable
sudo ufw allow 'Nginx HTTP'
sudo ufw allow 80/tcp
sudo ufw allow 'Nginx HTTPS'
sudo ufw allow 443/tcp
sudo ufw allow 'SSH'
sudo ufw allow 22/tcp
sudo ufw reload
# install PHP
sudo apt-get install -y php8.1-cli php-fpm php-mysqlnd php-mbstring php-json php-xml php-mysql php-zip
# install imagick
sudo apt install -y php8.1-imagick
sudo systemctl restart nginx php8.1-fpm.service
# install MariaDB
sudo apt-get install -y mariadb-server
sudo systemctl enable --now mariadb
sudo mysql_secure_installation
# install phpMyAdmin
wget https://files.phpmyadmin.net/phpMyAdmin/5.2.0/phpMyAdmin-5.2.0-all-languages.zip
sudo unzip phpMyAdmin-5.2.0-all-languages.zip
sudo mv phpMyAdmin-5.2.0-all-languages/ /var/www/phpMyAdmin
sudo chmod -R +x /var/www/phpMyAdmin
sudo mkdir /var/www/phpMyAdmin/tmp
sudo chmod 777 /var/www/phpMyAdmin/tmp
sudo rm phpMyAdmin-5.2.0-all-languages.zip
# init phpMyAdmin on Nginx
sudo cp phpMyAdmin.conf /etc/nginx/sites-available/
sudo chown $USER:$USER /etc/nginx/sites-available/phpMyAdmin.conf
sudo ln -s /etc/nginx/sites-available/phpMyAdmin.conf /etc/nginx/sites-enabled/
# echo edit the phpMyAdmin.conf file
echo "1. Open WinSCP \n
2. Edit /etc/nginx/sites-available/phpMyAdmin.conf server_name and allow ip \n
3. Open terminal \n
4. sudo nginx -t (if OK than do 5 step) \n
5. sudo nginx -s reload \n
6. Open browser http://server_name \n"
