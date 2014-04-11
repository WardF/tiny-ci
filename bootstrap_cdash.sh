#!/bin/bash
#
# Bootstrap a CDash installation.  The mysql data will live in /vagrant/mysql.
# 
apt-get update

export DEBIAN_FRONTEND=noninteractive
apt-get -y -q install wget apache2 mysql-server php5 php5-mysql php5-xsl php5-curl php5-gd

