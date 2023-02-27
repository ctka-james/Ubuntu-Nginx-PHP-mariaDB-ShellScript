#!/bin/bash
sudo apt update
sudo sync
sudo sh -c 'echo 1 >/proc/sys/vm/drop_caches'
sudo sync
sudo sh -c 'echo 2 >/proc/sys/vm/drop_caches'
sudo sync
sudo sh -c 'echo 3 >/proc/sys/vm/drop_caches'
sudo systemctl restart php8.1-fpm.service
sudo journalctl --vacuum-time=3d
sudo apt autoremove
sudo apt autoclean
sudo apt clean
sudo free -m