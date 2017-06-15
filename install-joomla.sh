#!/bin/bash
# Install Joomla on a CentoOS/Fedora VPS
#
# Script by https://www.rosehosting.com
#
#


# Create MySQL database
read -p "Enter your MySQL root password: " rootpass
read -p "Database name: " dbname
read -p "Database username: " dbuser
read -p "Enter a password for user $dbuser: " userpass
mysql -uroot <<MYSQL_SCRIPT
CREATE DATABASE $dbname;
delete from mysql.user
where user='$dbuser'
and host = 'localhost';
flush privileges;
CREATE USER $dbuser@localhost;
GRANT ALL PRIVILEGES ON $dbname.* TO $dbuser@localhost IDENTIFIED BY '$userpass';
FLUSH PRIVILEGES;
MYSQL_SCRIPT
echo "New MySQL database has been successfully created"
sleep 2

# Download, unpack and configure Joomla
read -r -p "Enter your Joomla URL? [e.g. mydomain.com]: " joomlaurl
mkdir -p /var/www/html/$joomlaurl && \
wget -P /var/www/html/$joomlaurl \
https://downloads.joomla.org/cms/joomla3/3-7-2/Joomla_3-7.2-Stable-Full_Package.zip && \
cd /var/www/html/$joomlaurl
echo "Installing unzip package if necessary..." && yum -yq install unzip
sleep 3
unzip Joomla*.zip && rm -f Joomla_*.zip && \
chown apache: -R /var/www/html/$joomlaurl
killall httpd

# Create the Apache virtual host
echo "

<VirtualHost $(dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | awk -F'"' '{ print $2}'):80>
 ServerName www.$joomlaurl
 DocumentRoot "/var/www/html/$joomlaurl"
 DirectoryIndex index.php
 Options FollowSymLinks
 ErrorLog logs/$joomlaurl-error_log
 CustomLog logs/$joomlaurl-access_log common
</VirtualHost>

" >> /etc/httpd/conf/httpd.conf
service httpd restart

echo -en "\aPlease go to http://www.$joomlaurl and finish the installation\n"

#End of script