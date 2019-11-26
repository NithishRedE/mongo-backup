# mongo-backup
mongo-backup


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
# 11)  0 0 * * * /home/ubuntu/backup.sh > /home/ubuntu/backup.log 2>&1
