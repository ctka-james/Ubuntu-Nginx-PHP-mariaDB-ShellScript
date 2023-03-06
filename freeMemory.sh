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
sudo apt autoremove --purge
sudo apt autoclean
sudo apt clean
sudo apt list --upgradable
echo "=========記憶體資訊========="
sudo free -m
echo "=========磁碟空間==========="
sudo df -h
# 查詢已安裝的套件
# sudo dpkg --get-selections

# 套件昇級
# sudo apt upgrade

# 擴充磁碟
# sudo df -h        # 顯示磁碟各磁區容量
# sudo vgdisplay    # 顯示磁碟狀況 Free PE 為可用容量

# 100% 全部給會有點卡
# sudo lvextend -l +100%FREE /dev/mapper/ubuntu--vg-ubuntu--lv

# 給 50G     
# sudo lvextend -L 50G /dev/mapper/ubuntu--vg-ubuntu--lv

# 重新計算磁區
# sudo resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv 

# 重新檢視磁碟
# df -h
# sudo vgdisplay

# 安裝 python3 pip
# python3 --version
# sudo apt install python3-pip