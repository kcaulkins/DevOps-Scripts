# Install AWS CLI and backup databases nightly


    apt-get update
    apt-get -y install python-pip
    pip install awscli


##### /root/.aws/credentials
    aws_access_key_id = xxxxxxxxxxx
    aws_secret_access_key = xxxxxxxxx

##### /root/.aws/config
    region = us-west-2

##### ~/.my.cnf:
    [mysqldump]
    user=root
    password=root

##### crontab:
    00 00 * * * aws s3 sync /var/www/html/wp-content/uploads s3://[s3_path]
    30 00 * * * mysqldump --defaults-file=/home/ubuntu/.my.cnf -u root [DB_NAME] > /home/ubuntu/db_backup/backup.sql
    35 00 * * * aws s3 sync /home/ubuntu/db_backup s3://[s3_path]

`sudo service cron restart`
