#!/bin/sh

# Make sure to:
# 1) Name this file `backup.sh` and place it in /home/ubuntu
# 2) Run sudo apt-get install awscli to install the AWSCLI
# 3) Run aws configure (enter s3-authorized IAM user and specify region)
# 4) Fill in DB host + name
# 5) Create S3 bucket for the backups and fill it in below (set a lifecycle rule to expire files older than X days in the bucket)
# 6) Run sudo mkdir /data/tmp
# 7) Run sudo chmod 777 /data/tmp/
# 8) Run chmod +x backup.sh
# 9) Test it out via ./backup.sh
# 10) Set up a daily backup at midnight via `crontab -e`:
#    0 0 * * * /home/ubuntu/backup.sh > /home/ubuntu/backup.log 2>&1
# 

# DB host (secondary preferred as to avoid impacting primary performance)

HOST=localhost
PORT=27017

# DB name
DBNAME=admin
DBAUTH=admin
DBUSER=admin
DBPASS=1qaz2wsx

# S3 bucket name
BUCKET=mongo-backup

# Linux user account
USER=ec2-user

# Current time
TIME=`/bin/date +%d-%m-%Y-%T`
QDATE=`/bin/date --date='-6 days' +%Y-%m-%d`

# Backup directory
DEST=/data/tmp/bck

# Tar file of backup directory
TAR=$DEST/../$TIME.tar.bz2

# Create backup dir (-p to avoid warning if already exists)
/bin/mkdir -p $DEST

# Log
echo "Backing up $HOST/$DBNAME to s3://$BUCKET/ on $TIME";

# Dump from mongodb host into backup directory
# mongodump -h $HOST -d $DBNAME -o $DEST
echo "mongoexport --authenticationDatabase $DBAUTH -u $DBUSER -p $DBPASS -h $HOST:$PORT -d $DBNAME -o ./collection_name.json -c collection_name --query '{ \"date\": { $lt: \"$QDATE\" } }'"
mongoexport --authenticationDatabase $DBAUTH -u $DBUSER -p $DBPASS -h $HOST:$PORT -d $DBNAME -o $DEST/collection_name.json -c collection_name --query '{ "date": { $lt: "'$QDATE'" } }'

echo "mongo $DBNAME --eval 'db.collection_name.deleteMany( { \"date\": { $lt: \"$QDATE\" } } );'"
mongo  --authenticationDatabase $DBAUTH -u $DBUSER -p $DBPASS $HOST:$PORT/$DBNAME --eval 'db.collection_name.deleteMany( { "date": { $lt: "'$QDATE'" } } );'

# Create tar of backup directory
/bin/tar -jcvf $TAR -C $DEST .

# Upload tar to s3
/usr/bin/aws s3 cp $TAR s3://$BUCKET/

# Remove tar file locally
/bin/rm -f $TAR

# Remove backup directory
/bin/rm -rf $DEST

# All done
echo "Backup available at https://s3.amazonaws.com/$BUCKET/$QDATE_$TIME.tar.bz2"

