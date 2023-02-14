#!/bin/bash
rsync -arvzh $USER@$1::$2 /var/www/$2/  --password-file=/home/$USER/rsync.passwd --delete

# do_rsync.sh [rsync server IP][rsync server dirName]