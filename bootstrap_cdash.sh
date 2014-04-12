#!/bin/bash
#
# Bootstrap a CDash installation.  The mysql data will live in /vagrant/mysql.
# 
apt-get update

export DEBIAN_FRONTEND=noninteractive
apt-get -y -q install wget apache2 mysql-server php5 php5-mysql php5-xsl php5-curl php5-gd unzip subversion

##### 
# Install CDash, configure mysql
#####

sudo -i -u vagrant svn co https://www.kitware.com/svn/CDash/Release-2-0-2 CDash

mysql -u root -e "grant all on *.* to 'cdash'@'localhost'"



exit 0

#####
# Configure mysql. It will live in /vagrant/mysql.
# This must be created, if need be. 
#####



###
# Move data directory.
###

stop mysql

# Create the target data directory.
sudo -i -u vagrant mkdir -p /vagrant/mysql

# Change the setting in /etc/mysql/my.cnf
cp /etc/mysql/my.cnf /etc/mysql/my.cnf.orig
sed -i 's/datadir\s\{0,\}= \/var\/lib\/mysql/datadir = \/vagrant\/mysql/g' /etc/mysql/my.cnf
cp /etc/mysql/my.cnf /etc/mysql/my.cnf.new

# Update apparmor, insert new directory 
AACFG="/etc/apparmor.d/usr.sbin.mysqld"
sed -i '/\/var\/lib\/mysql\/ r,/a \/vagrant\/mysql\/ r,' $AACFG
sed -i '/\/var\/lib\/mysql\/\*\* rwk,/a \/vagrant\/mysql\/\*\* rwk,' $AACFG

find /var/lib/mysql -maxdepth 1 -type d -exec cp -R {} /vagrant/mysql \;

sudo apparmor_parser -r $AACFG

# Restart mysql
#stop mysql
#start mysql


###
# End move data directory.
###
