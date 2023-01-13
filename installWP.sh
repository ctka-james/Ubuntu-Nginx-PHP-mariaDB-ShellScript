#!/bin/bash
sudo rm -rf /var/www/$1/*
# install WordPress
wget https://wordpress.org/latest.zip
unzip latest.zip
sudo mv wordpress/* /var/www/$1
sudo chown -R www-data:www-data /var/www/$1
rm -R wordpress/
rm latest.zip
sudo chown -R www-data:www-data /var/www/$1/

echo "\n"
echo "網站 $1 WordPress 已下載完成，務必刪除 installWP.sh，請依照指示繼續完成設定，設定前先設定 SSL"
echo "\n"
echo "網站目錄 /var/www/$1"
echo "\n"
echo "網址 https://$1"
echo "\n"