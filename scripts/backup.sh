#!/bin/bash

# The backups live on the server and will need to be taken offsite
# A command like the following ought to do the trick:
# scp -r semawi.notanumber.dk:/home/josef/tmp/backups/ .

BACKUP_DIR=~/tmp/backups/$(date +%Y%m%d%H%M%S)

mkdir $BACKUP_DIR
cd $BACKUP_DIR
docker exec semawi-mysql mysqldump -u wiki --password=wiki wiki > backup.sql
gzip backup.sql
docker cp semawi-mediawiki:/var/www/wiki/images .
tar cvvvjf images.tar.bz2 images/
rm -rf images/
