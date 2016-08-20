#!/bin/bash

echo "Provisioning virtual machine..."
echo "Update OS"
sudo apt-get update -y > /dev/null 2>&1
sudo apt-get upgrade -y > /dev/null 2>&1

# Git
echo "Installing Git"
sudo apt-get install git -y > /dev/null 2>&1

# nginx
echo "Installing nginx"
sudo apt-get install nginx -y > /dev/null 2>&1

# PHP
echo "Installing PHP"
sudo apt-get install php5-common php5-dev php5-cli php5-fpm -y > /dev/null 2>&1
sudo apt-get install curl php5-curl php5-mcrypt php5-mysql -y > /dev/null 2>&1

echo "Installing Memcached"
sudo apt-get install memcached -y > /dev/null 2>&1
sudo apt-get install php5-memcache -y > /dev/null 2>&1

# MySQL 
echo "Preparing MySQL"
sudo apt-get install debconf-utils -y > /dev/null 2>&1
debconf-set-selections <<< "mysql-server mysql-server/root_password password root"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password root"

echo "Installing MySQL"
sudo apt-get install mysql-server -y > /dev/null 2>&1

echo "Installing PHPMyAdmin"
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password root" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password root" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password root" | debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none" | debconf-set-selections
sudo apt-get install phpmyadmin -y > /dev/null 2>&1
sudo php5enmod mcrypt

# nginx Configuration
echo "Configuring nginx"
sudo rm /etc/nginx/sites-enabled/default
sudo rm /etc/nginx/nginx.conf
sudo cp /var/www/html/vagrant/nginx.conf /etc/nginx/nginx.conf
sudo cp /var/www/html/vagrant/vagrant_vhost /etc/nginx/sites-enabled/vagrant_vhost

# Restart nginx and fpm for the config to take effect
sudo service nginx restart > /dev/null 2>&1
sudo service php5-fpm restart > /dev/null 2>&1

echo "Copying wp-config"
sudo cp /var/www/html/vagrant/wp-config.php /var/www/html/wp-config.php

echo "Install NPM and Gulp"
cd /var/www/html
sudo apt-get install npm -y > /dev/null 2>&1
ln -s /usr/bin/nodejs /usr/bin/node
sudo npm install -g npm
sudo npm install -g npm
npm config rm proxy
npm config rm https-proxy
sudo npm install --global gulp-cli > /dev/null 2>&1
sudo npm install gulp --no-bin-link > /dev/null 2>&1
npm install --no-bin-links > /dev/null 2>&1

echo "Copy AWS Config"
mkdir ~/.aws
sudo cp /var/www/html/vagrant/credentials ~/.aws/credentials
sudo cp /var/www/html/vagrant/config ~/.aws/config

echo "Install AWS CLI"
curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
sudo python get-pip.py > /dev/null 2>&1
sudo pip install awscli > /dev/null 2>&1

echo "Copy DB from S3"
aws s3 cp s3://backup.sql ~/backup.sql
echo "import DB"
echo "create database vagrant;" | mysql -u root -proot
sudo mysql -u root -proot vagrant < ~/backup.sql

echo "Download Uploads from S3"
aws --recursive s3 cp s3://uploads /var/www/html/wp-content/uploads

# Reset permissions
sudo find /var/www/html -type d -exec chmod 755 {} +
sudo find /var/www/html -type f -exec chmod 644 {} +
sudo chown -R www-data.www-data /var/www/html

echo "Finished provisioning."
