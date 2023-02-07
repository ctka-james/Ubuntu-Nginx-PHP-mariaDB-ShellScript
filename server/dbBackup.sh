#!/bin/bash
#儲存備份個數，備份31天資料
number=31
#備份儲存路徑
backup_dir=/home/$USER/dbBackup
#日期
dd=`date +%Y-%m-%d-%H-%M-%S`
#備份工具
tool=mysqldump
#使用者名稱
username=root
#密碼
password=12345
#將要備份的資料庫
database_name=wordpress
#如果資料夾不存在則建立
if [ ! -d $backup_dir ];
then     
    mkdir -p $backup_dir;
fi
#簡單寫法 mysqldump -u root -p123456 users > /root/mysqlbackup/users-$filename.sql
$tool -u $username -p$password $database_name > $backup_dir/$database_name-$dd.sql
#寫建立備份日誌
echo "create $backup_dir/$database_name-$dd.dupm" >> $backup_dir/log.txt
#找出需要刪除的備份
delfile=`ls -l -crt $backup_dir/*.sql | awk '{print $9 }' | head -1`
#判斷現在的備份數量是否大於$number
count=`ls -l -crt $backup_dir/*.sql | awk '{print $9 }' | wc -l`
if [ $count -gt $number ]
then
  #刪除最早生成的備份，只保留number數量的備份
  rm $delfile
  #寫刪除檔案日誌
  echo "delete $delfile" >> $backup_dir/log.txt
fi