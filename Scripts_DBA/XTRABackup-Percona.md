# Using percona xtrabackup for backup
taking backup
restore backup
## Taking backup
 Percona xtrabackup is consider a hot backup that backup the whole data directory with its redo logs and also it will take backup of the my.cnf. 
 1. Create the directory for backup:
 ``` bash
 mkdir ~/backup
 ```
2. Take de backup
``` bash
xtrabackup -uroot -p --compress --backup --target-dir=/backup
```
by the end of prompt you should receive LSN number .
## Restore backup
To restore backup we need to first prepare the backup.
Data files are not point-in-time consistent until they are prepared, because they were copied at different times as the program ran, and they might have been changed while this was happening.
If you try to start InnoDB with these data files, it will detect corruption and stop working to avoid running on damaged data. The --prepare step makes the files perfectly consistent at a single instant in time, so you can run InnoDB on them.
first we need to decompress the backup we can do so by using `--decompress` and also `--removeoriginal` which will proceed to remove compress files after decompress.

```bash
xtrabackup -uroot -p --compress --backup --target-dir=/backup
```
after that we can prepare the backup with the command

`xtrabackup -uroot -p --prepare --target-dir=/backup`

after that we can prepare the backup

`xtrabackup -uroot -p --prepare --target-dir=/backup`

next go to data directory and remove all the files in the data dir
```shell
cd /var/lib/mysql
rm -rf *
```
now we can copy the content of bacup to data dir 
we can do it manually using `cp` or use percona xtrabackup it self to copy the backup file to the data dir.

xtrabackup will automatically detect the data dir path

`xtrabackup --copy-back --target-dir=/backup`

after that change the owner of the files back to MySQL user

`chown -R mysql:mysql /var/lib/mysql`

now start mysqld services and it should start normally