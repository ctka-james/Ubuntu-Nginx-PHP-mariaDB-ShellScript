#!/bin/bash
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
    <p>為 $1 加入 LetsEncrypt SSL</p>
    <p>$ sh certbot.sh $1 YOUR_EMAIL</p>
    <?php
    phpinfo();
    ?>
</body>
</html>
EOF
sudo mv $1.conf /etc/nginx/sites-available/
sudo mkdir /var/www/$1/
sudo mv index.php /var/www/$1
sudo chown www-data:www-data /var/www/$1/
sudo chown $USER:$USER /etc/nginx/sites-available/$1.conf
sudo chown -R $USER:$USER /var/www/$1/
sudo ln -s /etc/nginx/sites-available/$1.conf /etc/nginx/sites-enabled/
sudo nginx -t
sudo sleep 3s
sudo nginx -s reload
sudo chown www-data:adm /var/log/nginx/$1-access.log
sudo chown www-data:adm /var/log/nginx/$1-error.log

echo "\n"
echo "新網站 $1 已建置完成"
echo "\n"
echo "網站目錄 /var/www/$1"
echo "\n"
echo "網址 http://$1"
echo "\n"
