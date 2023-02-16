#!/bin/bash
rsync -arvzh $USER@$1::$2 /home/$USER/$2/  --password-file=/home/$USER/rsync.passwd --delete

# dbbackup_rsync.sh [rsync server IP][dbBackup]
# 回復
# mysql -u root -p [dbName] < [dbBackup].sql
# mysql -u root -p dbname < dbname_backup.sql