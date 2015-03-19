#!/bin/bash

set -u

apt-get update
apt-get -y upgrade
apt-get install -y ubuntu-dev-tools m4 git libjpeg-dev libcurl4-openssl-dev wget htop libtool bison flex autoconf curl g++ emacs valgrind gfortran zlib1g-dev


# Install Chrome
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
apt-get update
apt-get install -y google-chrome-stable

rm /home/vagrant/*.sh
chown -R vagrant:vagrant /home/vagrant
