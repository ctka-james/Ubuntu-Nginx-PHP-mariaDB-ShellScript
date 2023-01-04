#!/bin/bash
sudo ln -s /etc/nginx/sites-available/phpMyAdmin.conf /etc/nginx/sites-enabled/
sudo nginx -t
sudo nginx -s reload
echo '\n'
echo 'phpMyAdmin 已開啟!'
echo '\n'