#!/bin/bash
# 設定時區
sudo timedatectl set-timezone Asia/Taipei

# 更新套件
sudo apt -y update

# clean cache and lock
##   sudo kill -9 $(jobs -p) 清除 Linux 中斷後的 stoped
#sudo lsb_release -a
#sudo sleep 5s
#sudo rm /var/lib/dpkg/lock-frontend
#sudo rm /var/lib/dpkg/lock
#sudo rm /var/cache/apt/archives/lock

sudo apt install -y zip
sudo apt install -y net-tools

# Install Nginx
sudo apt install -y nginx
sudo systemctl enable --now nginx
sudo systemctl status nginx
sudo sleep 3s

# firewall 設定
sudo service ufw start
sudo service ufw enable
sudo ufw allow 'Nginx HTTP'
# sudo ufw allow 80/tcp
sudo ufw allow 'Nginx HTTPS'
# sudo ufw allow 443/tcp
sudo ufw allow ssh
#sudo ufw allow 22/tcp
#sudo ufw allow 873/tcp
sudo ufw enable
sudo ufw reload
sudo ufw status
sudo systemctl status ufw
sudo sleep 3s

# install PHP
sudo apt install -y php8.1-cli php-fpm php-mysqlnd php-mbstring php-json php-xml php-mysql php-zip php-curl php-intl

# install imagick
sudo apt install -y php8.1-imagick
sudo systemctl restart nginx php8.1-fpm.service
sudo systemctl enable php8.1-fpm.service
sudo systemctl status php8.1-fpm.service
sudo sleep 3s

# install LetsEncrypt SSL certbot
sudo apt install -y certbot python3-certbot-nginx
sudo systemctl start certbot.timer
sudo systemctl enable certbot.timer
sudo systemctl status certbot.timer
sudo sleep 3s

# install atd.service
sudo apt install -y at
sudo systemctl start atd.service
sudo systemctl enable atd.service
sudo cat << EOF > at.allow
$USER
EOF
sudo mv at.allow /etc/at.allow
sudo systemctl restart atd.service
sudo systemctl status atd.service
sudo sleep 3s

# install MariaDB
sudo apt install -y mariadb-server
sudo systemctl enable --now mariadb
sudo systemctl status mariadb
sudo sleep 3s
sudo mysql_secure_installation

# install plocate
sudo apt install -y plocate

# install phpMyAdmin
wget --no-check-certificate https://files.phpmyadmin.net/phpMyAdmin/5.2.0/phpMyAdmin-5.2.0-all-languages.zip
sudo unzip phpMyAdmin-5.2.0-all-languages.zip
sudo mv phpMyAdmin-5.2.0-all-languages/ /var/www/phpMyAdmin
sudo chmod -R +x /var/www/phpMyAdmin
sudo mkdir /var/www/phpMyAdmin/tmp
sudo chmod 777 /var/www/phpMyAdmin/tmp
sudo chown -R $USER:$USER /var/www/phpMyAdmin
sudo rm phpMyAdmin-5.2.0-all-languages.zip
# setup phpMyAdmin.conf file
cat << EOF > phpMyAdmin.conf
server {
        listen 80;
        listen [::]:80;
        root /var/www/phpMyAdmin;
        index index.html index.htm index.php;
        server_name phpmyadmin.$1;
        location / {
            try_files \$uri \$uri/ /index.php?\$args;
            allow all;
            # deny all;
        }
        location ~ \.php$ {
            # 執行 ip 總數連線
			# limit_req zone=one burst=5 nodelay;
            include snippets/fastcgi-php.conf;
            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        #
        #   # With php-fpm (or other unix sockets):
            include /etc/nginx/fastcgi_params;
            fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        }
        access_log /var/log/nginx/phpMyAdmin-access.log;
        error_log /var/log/nginx/phpMyAdmin-error.log;
        #
        #   # 加速 Nginx 讀取檔案速度
        sendfile on;
        #
        #   # 關閉 Nginx 版本訊息
        server_tokens off;
        #   
        #   # 拒絕無法解析的 request 
        location ~ /\.ht {
            deny all;
        } 
}
EOF

# init phpMyAdmin on Nginx
sudo cp phpMyAdmin.conf /etc/nginx/sites-available/
sudo chown $USER:$USER /etc/nginx/sites-available/phpMyAdmin.conf
sudo ln -s /etc/nginx/sites-available/phpMyAdmin.conf /etc/nginx/sites-enabled/
sudo rm phpMyAdmin.conf
# init nginx.conf 限制 ip 每秒 10 個 request
sudo cat << EOF > nginx.conf
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
	worker_connections 768;
	# multi_accept on;
}

http {
	# 觸發條件，限制 ip 每秒 10 個 request
	# limit_req_zone \$binary_remote_addr zone=one:10m rate=10r/s;

    # 檔案最大上傳
    client_max_body_size 20m;

	##
	# Basic Settings
	##

	sendfile on;
	tcp_nopush on;
	types_hash_max_size 2048;
	# server_tokens off;

	# server_names_hash_bucket_size 64;
	# server_name_in_redirect off;

	include /etc/nginx/mime.types;
	default_type application/octet-stream;

	##
	# SSL Settings
	##

	ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3; # Dropping SSLv3, ref: POODLE
	ssl_prefer_server_ciphers on;

	##
	# Logging Settings
	##

	# access_log /var/log/nginx/access.log;
	# error_log /var/log/nginx/error.log;

	##
	# Gzip Settings
	##

	gzip on;

	# gzip_vary on;
	# gzip_proxied any;
	# gzip_comp_level 6;
	# gzip_buffers 16 8k;
	# gzip_http_version 1.1;
	# gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

	##
	# Virtual Host Configs
	##

	include /etc/nginx/conf.d/*.conf;
	include /etc/nginx/sites-enabled/*;
}


#mail {
#	# See sample authentication script at:
#	# http://wiki.nginx.org/ImapAuthenticateWithApachePhpScript
#
#	# auth_http localhost/auth.php;
#	# pop3_capabilities "TOP" "USER";
#	# imap_capabilities "IMAP4rev1" "UIDPLUS";
#
#	server {
#		listen     localhost:110;
#		protocol   pop3;
#		proxy      on;
#	}
#
#	server {
#		listen     localhost:143;
#		protocol   imap;
#		proxy      on;
#	}
#}
EOF
sudo rm /etc/nginx/nginx.conf
sudo mv nginx.conf /etc/nginx/nginx.conf
sudo chown $USER:$USER /etc/nginx/nginx.conf
sudo nginx -t
sudo nginx -s reload

# 讓預設的 Nginx 能夠執行 PHP
cat << EOF > $1.conf
server {
        listen 80 ;
        listen [::]:80 ;
        root /var/www/$1;
        index index.html index.htm index.php;
        server_name $1;
        client_max_body_size 50m;
        charset utf-8;
        location / {                
                try_files \$uri \$uri/ /index.php?\$args;
        }
        location ~ \.php$ {
            # 執行 ip 總數連線
			# limit_req zone=one burst=5 nodelay;
            include snippets/fastcgi-php.conf;
            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        #
        #   # With php-fpm (or other unix sockets):
            include /etc/nginx/fastcgi_params;
            fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        }
        # access_log /var/log/nginx/$1-access.log;
        error_log /var/log/nginx/$1-error.log;
        #
        #   # 加速 Nginx 讀取檔案速度
        sendfile on;
        #
        #   # 關閉 Nginx 版本訊息
        server_tokens off;
        #   
        #   # 拒絕無法解析的 request 
        location ~ /\.ht {
            deny all;
        } 
}
EOF

cat << EOF > index.php
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$1 的設定</title>
</head>
<body>
    <h1>網站的 Domain Name：$1</h1>
    <h1>網站目錄：/var/www/$1/</h1>
    <h1>$1 的 nginx 設定檔：/etc/nginx/sites-available/$1.conf</h1>
    <h1><a href="http://phpmyadmin.$1" target="_blank">資料庫管理介面 phpMyAdmin</a></h1>
    <p>為 $1 加入 LetsEncrypt SSL</p>
    <p>$ sh certbot.sh $1 YOUR_EMAIL</p>
    <?php
    phpinfo();
    ?>
</body>
</html>
EOF

cat << EOF > ip_to_dns.conf
server {
    listen 80 default_server; 
    if ( \$host != '$1' ){
            rewrite ^/(.*)$ http://$1/\$1 permanent;
    }
}
EOF
sudo rm /etc/nginx/sites-available/default
sudo rm /etc/nginx/sites-enabled/default
sudo mv $1.conf /etc/nginx/sites-available/
sudo rm -rf /var/www/html/
sudo mkdir /var/www/$1/
sudo mv index.php /var/www/$1
sudo chown www-data:www-data /var/www/$1/
sudo chown $USER:$USER /etc/nginx/sites-available/$1.conf
sudo mv phpinfo.php /var/www/$1/
sudo chown -R $USER:$USER /var/www/$1/
sudo ln -s /etc/nginx/sites-available/$1.conf /etc/nginx/sites-enabled/
sudo mv ip_to_dns.conf /etc/nginx/sites-available/
sudo ln -s /etc/nginx/sites-available/ip_to_dns.conf /etc/nginx/sites-enabled/

# # install WordPress
# wget https://wordpress.org/latest.zip
# unzip latest.zip
# sudo mv wordpress/* /var/www/$1
# sudo chown -R www-data:www-data /var/www/$1
# rm -R wordpress/
# rm latest.zip

# reload Nginx
sudo nginx -t
sudo sleep 3s
sudo nginx -s reload
sudo chown www-data:adm /var/log/nginx/$1-access.log
sudo chown www-data:adm /var/log/nginx/$1-error.log

# install fail2ban
sudo apt install -y fail2ban
sudo systemctl status fail2ban.service
sudo sleep 3s

# 暫停更新核心套件
sudo apt remove unattended-upgrades
# sudo apt upgrade  # 更新核心套件

# 啟動
#sudo systemctl start fail2ban.service
# 開機時啟動
#sudo systemctl enable fail2ban.service
# 查看狀態
#sudo systemctl status fail2ban.service
# 停止
#sudo systemctl stop fail2ban.service
# 重新啟動
#sudo systemctl restart fail2ban.service
# 重新載入設定（有修改 jail 內容時需執行)
#sudo fail2ban-client reload
# 查 jail 狀態
#sudo fail2ban-client status
# 查指定 jail 的狀態，例如 sshd
#sudo fail2ban-client status sshd
# 如果不小心封鎖到自己的IP
#sudo fail2ban-client set sshd unbanip x.x.x.x
# 時不時就檢查一下有多少IP被封鎖
#sudo iptables -L -n

# Print finish info
echo "\n"
echo "Ubuntu Nginx PHP MariaDB Certbot 環境已建製完成!!"
echo "\n"
echo "網址："
echo "http://$1"
echo "\n"
echo "新增資料庫可以連結到：(並將此網址加入書籤)"
echo "http://phpmyadmin.$1"
echo "\n"
echo "完成後請務必刪除 init.sh 並執行 \$ sh off_phpMyAdmin.sh"
echo "\n"
echo "重新開啟 phpMyAdmin 請執行 \$ sh on_phpMyAdmin.sh"
