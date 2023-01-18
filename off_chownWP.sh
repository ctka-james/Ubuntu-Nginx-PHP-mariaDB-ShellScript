#!/bin/bash
sudo chown -R www-data:www-data /var/www/$1/
echo '\n'
echo '目錄權限已設定為可直接後台安裝外掛\n'
echo '安裝完畢後請再執行 initWP.sh 以保持 WordPress 較安全的權限設定'
echo '\n'