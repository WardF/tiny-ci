#!/bin/bash
#
# Bootstrap a CDash installation.  The mysql data will live in /vagrant/mysql.
# 
apt-get update

export DEBIAN_FRONTEND=noninteractive
apt-get -y -q install wget apache2 mysql-server php5 php5-mysql php5-xsl php5-curl php5-gd unzip subversion links

##### 
# Install CDash, configure mysql
#####

cd /var/www/

echo '<?php' > /var/www/info.php
echo 'phpinfo();' >> /var/www/info.php
echo '?>' >> /var/www/info.php


###
# Check out and configure CDash, if need be.
###
if [ ! -f /var/www/CDash ]; then
    # Stop mysql for the time being.
    stop mysql

    svn co https://www.kitware.com/svn/CDash/Release-2-0-2 CDash
    # Start mysql back up.
    start mysql

    # Configure MySQL
    # Add cdash database, user.
    mysql -u root -e "create user 'cdash'@'%'"
    mysql -u root -e "grant all on *.* to 'cdash'@'%'"
    mysql -u root -e "create database cdash"


    # If there is a default database file,
    # import it into the database.
    # Otherwise, create a script that lives in /home/vagrant
    # that can be used to export the database file.
    if [ -f /vagrant/default_cdash_database.sql.gz ]; then
	echo "Importing pre-existing database."
	gunzip < /vagrant/default_cdash_database.sql.gz | mysql -u root cdash 
    else
	# Create a script for easy export of database, once it's been configured.
	echo "You must create a default database for use with CDash."
	echo "Once created, run the script in /home/vagrant to"
	echo "export it."
	echo ""
    fi
    SQLSCRIPT="/home/vagrant/mysql_export.sh"
    echo '#!/bin/bash' > $SQLSCRIPT
    echo 'set -x' >> $SQLSCRIPT
    echo "mysqldump -u root cdash | gzip > /home/vagrant/default_cdash_database.sql.gz" >> $SQLSCRIPT
    echo "mv /home/vagrant/default_cdash_database.sql.gz /vagrant" >> $SQLSCRIPT
    echo "echo Finished." >> $SQLSCRIPT
    chmod 755 $SQLSCRIPT
    chown vagrant:vagrant $SQLSCRIPT
    
    apache2ctl restart
fi

# Clone a base netcdf-c directory to work from and to monitor for changes.
clone git://github.com/Unidata/netcdf-c /vagrant/netcdf-c

exit 0




