#!/bin/bash
sudo rm /etc/nginx/sites-enabled/phpMyAdmin.conf
sudo nginx -t
sudo nginx -s reload
echo '\n'
echo 'phpMyAdmin 已關閉!'
echo '\n'