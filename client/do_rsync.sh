#!/bin/bash
rsync -arvzh $USER@$1::$2 /var/www/$2/  --password-file=/home/$USER/rsync.passwd --delete

# do_rsync.sh [rsync server IP][rsync server dirName]
# for wordpress
# client
# sudo chmod 777 /var/www/dirName/wp-content/uploads
# server
# sudo chmod 755 /var/www/dirName/wp-content/uploads