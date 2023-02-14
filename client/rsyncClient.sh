#!/bin/bash
sudo apt install -y rsync
touch rsync.passwd
mv rsync.passwd /home/$USER/
chmod 600 /home/$USER/rsync.passwd
mkdir /home/$USER/dbBackup
# crontab allow user
sudo cat << EOF > cron.allow
$USER
EOF
sudo mv cron.allow /etc/cron.allow
sudo service cron reload
echo "請在 /home/$USER/rsync.passwd 輸入連線密碼 \n 執行 do_rsync.sh [rsync server IP][rsync server dirName]"