#!/bin/bash
sudo certbot --nginx -d $1 -m $2
echo "\n"
echo "已經建立 $1 的 LetsEncrypt SSL \n"
echo "查詢憑證資訊： \n"
echo "https://crt.sh/?q=$1"