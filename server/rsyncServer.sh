#!/bin/bash
sudo apt install -y rsync
sudo mkdir /var/log/rsync
sudo cat << EOF > rsyncd.conf
uid = $USER     
gid = $USER    
use chroot = yes   
max connections = 4   
log file=/var/log/rsync/rsyncd.log  
pid file = /var/run/rsyncd.pid  
exclude = lost+found/  
transfer logging = yes   
timeout = 900    
ignore nonreadable = yes   
dont compress   = *.gz *.tgz *.zip *.z *.Z *.rpm *.deb *.bz2  
[$1] 
	path = /var/www/$1    
    comment = $1 website backup    
    read only = no
 #  hosts allow = your client ip
    hosts deny = *     
    auth users = $USER    
    secrets file = /home/$USER/rsync.secret   
    log file = /var/log/rsync/$1.log
[phpMyAdmin]
    path = /var/www/phpMyAdmin    
    comment = phpMyAdmin backup    
    read only = no
 #  hosts allow = your client ip
    hosts deny = *     
    auth users = $USER    
    secrets file = /home/$USER/rsync.secret   
    log file = /var/log/rsync/phpMyAdmin.log
[dbBackup]
    path = /home/$USER/dbBackup    
    comment = MariaDB MySQL Backup    
    read only = no
 #  hosts allow = your client ip
    hosts deny = *     
    auth users = $USER    
    secrets file = /home/$USER/rsync.secret   
    log file = /var/log/rsync/dbBackup.log    
EOF
sudo mv rsyncd.conf /etc/rsyncd.conf
sudo chown $USER:$USER /etc/rsyncd.conf
sudo cat << EOF > rsync.secret
$USER:your passwd
EOF
sudo mv rsync.secret /home/$USER/rsync.secret
sudo chmod 600 /home/$USER/rsync.secret
sudo chown root:root /home/$USER/rsync.secret
sudo systemctl start rsync
sudo systemctl enable rsync
sudo ufw allow 873/tcp
sudo ufw reload
sudo systemctl restart rsync
mkdir /home/$USER/dbBackup/
echo "rsync server 遠端同步已安裝完成 \n 請於 /home/$USER/rsync.secret 設定連線密碼，權限必須為root \n rsync server 設定檔：/etc/rsyncd.conf"