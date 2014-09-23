#!/usr/bin/env bash
# Bootstrap a system with parallel libraries using MPICH.
# Determine if we're using apt-get or yum
PKG_CMD=""
USE_APT=""
USE_YUM=""
#### Install base development packages.
if [ `which apt-get | wc -w` -gt 0 ]; then
    USE_APT="TRUE"
    PKG_CMD=`which apt-get`
    PKG_UPDATE="$PKG_CMD update"
    PKG_LIST="ubuntu-dev-tools m4 git libjpeg-dev libcurl4-openssl-dev wget htop libtool bison flex autoconf curl g++ midori mpich libmpich-dev emacs24"
    GRP_LIST=""
elif [ `which yum | wc -w` -gt 0 ]; then
    USE_YUM="TRUE"
    PKG_UPDATE=""
    PKG_CMD=`which yum`
    PKG_LIST="m4 git libjpeg-turbo-devel libcurl-devel wget nano libtool bison flex autoconf curl"
    GRP_LIST="yum -y groupinstall 'Development tools'"
fi

$PKG_UPDATE
$PKG_CMD -y install $PKG_LIST
$GRP_LIST
#####
# Enable Cron to run automatically.
#####
if [ `which update-rc.d | wc -w` -gt 0 ]; then
    update-rc.d crond defaults
elif [ `which chkconfig | wc -w` -gt 0 ]; then
    chkconfig crond on
fi

#####
# Set the proper timezone.
#####

if [ -f "/usr/sbin/dpkg-reconfigure" ]; then
    echo "US/Mountain" | tee /etc/timezone
    dpkg-reconfigure --frontend noninteractive tzdata
elif [ -f /usr/share/zoneinfo/America/Denver ]; then
    mv /etc/localtime /etc/localtime.bak
    ln -s /usr/share/zoneinfo/America/Denver /etc/localtime
fi

#####
# Install ctest as a script.
# It is installed into /etc/init.d/ctest
#####
if [ `which update-rc.d | wc -w` -gt 0 ]; then
    update-rc.d cron defaults
elif [ `which chkconfig | wc -w` -gt 0 ]; then
    chkconfig crond on
fi

#####
# Install CTest as a script in the 'vagrant' home directory.
#####
CTEST_INIT="/home/vagrant/ctest_service.sh"
LOCKFILE="/vagrant/NOTEST"

echo '#!/bin/bash' > $CTEST_INIT
echo 'sleep 10' >> $CTEST_INIT
echo "LFILE=\"$LOCKFILE\"" >> $CTEST_INIT
echo 'CTEST_HOME="/home/vagrant/ctest_scripts"' >> $CTEST_INIT
echo 'DASH="$CTEST_HOME/Dashboards"' >> $CTEST_INIT
echo 'rm -rf $CTEST_HOME' >> $CTEST_INIT
echo '/bin/mkdir -p $CTEST_HOME' >> $CTEST_INIT

echo "count=0" >> $CTEST_INIT
echo 'while [ $count -lt 10 ]; do' >> $CTEST_INIT
echo " if [ -f /vagrant/Vagrantfile ]; then" >> $CTEST_INIT
echo "   count=50" >> $CTEST_INIT
echo " else" >> $CTEST_INIT
echo '   echo "Waiting for /vagrant to be mounted."' >> $CTEST_INIT
echo '   count=`expr $count + 1`' >> $CTEST_INIT
echo '   sleep 5' >> $CTEST_INIT
echo ' fi' >> $CTEST_INIT
echo 'done' >> $CTEST_INIT

echo "if [ -d /vagrant ]; then" >> $CTEST_INIT
echo "     find -L /vagrant -maxdepth 1 -type f -exec cp {} /home/vagrant/ctest_scripts \;" >> $CTEST_INIT
echo "else" >> $CTEST_INIT
echo "     exit 1" >> $CTEST_INIT
echo "fi" >> $CTEST_INIT

#echo "chown -R vagrant:vagrant /home/vagrant/ctest_scripts" >> $CTEST_INIT

echo ' if [ ! -f /usr/local/bin/ctest ]; then' >> $CTEST_INIT
echo '    echo "ctest not found"' >> $CTEST_INIT
echo '    exit 1' >> $CTEST_INIT
echo ' fi' >> $CTEST_INIT
echo '      /bin/rm -rf $DASH' >> $CTEST_INIT
echo '	    echo "Starting ctest"' >> $CTEST_INIT
echo '      cd /home/vagrant/ctest_scripts/' >> $CTEST_INIT
echo '      /usr/local/bin/ctest -V -S PARCI.cmake > continuous_test.out 2>&1 &' >> $CTEST_INIT


echo 'exit $RETVAL' >> $CTEST_INIT
chmod 755 $CTEST_INIT
#update-rc.d ctest defaults 99


####
# End installation of ctest as a script.
# Note: We can't start it yet, ctest and hdf libraries
# haven't been installed yet.
####

### Install a crontab for running nightly tests.
sudo -i -u vagrant echo "@reboot $CTEST_INIT" > /home/vagrant/crontab.in
sudo -i -u vagrant echo '01 0 * * * cd /home/vagrant/ctest_scripts && /home/vagrant/ctest_scripts/run_nightly_test.sh > nightly_log.txt' >> /home/vagrant/crontab.in

sudo -i -u vagrant crontab < /home/vagrant/crontab.in
rm /home/vagrant/crontab.in


## Install several packages from source.
# * cmake
# * hdf4
# * hdf5

CMAKE_VER="cmake-3.0.2"
HDF4_VER="hdf-4.2.10"
HDF5_VER="hdf5-1.8.13"

# Install cmake from source
if [ ! -f /usr/local/bin/cmake ]; then
    CMAKE_FILE="$CMAKE_VER".tar.gz
    if [ ! -f "/vagrant/$CMAKE_FILE" ]; then
	wget http://www.cmake.org/files/v3.0/$CMAKE_FILE
	cp "$CMAKE_FILE" /vagrant
    else
	cp "/vagrant/$CMAKE_FILE" .
    fi

    tar -zxf $CMAKE_FILE
    pushd $CMAKE_VER
    ./configure --prefix=/usr/local
    make install
    popd
    rm -rf $CMAKE_VER
fi

# Install hdf4 from source.
if [ ! -f /usr/local/lib/libhdf4.settings ]; then
    HDF4_FILE="$HDF4_VER".tar.bz2
    if [ ! -f "/vagrant/$HDF4_FILE" ]; then
	wget http://www.hdfgroup.org/ftp/HDF/HDF_Current/src/$HDF4_FILE
	cp "$HDF4_FILE" /vagrant
    else
	cp "/vagrant/$HDF4_FILE" .
    fi

    tar -jxf $HDF4_FILE
    pushd $HDF4_VER
    ./configure --disable-static --enable-shared --disable-netcdf --disable-fortran --prefix=/usr/local
    sudo make install
    popd
    rm -rf $HDF4_VER
fi

# Install hdf5 from source
if [ ! -f /usr/local/lib/libhdf5.settings ]; then
    HDF5_FILE="$HDF5_VER".tar.bz2
    if [ ! -f "/vagrant/$HDF5_FILE" ]; then
	wget http://www.hdfgroup.org/ftp/HDF5/current/src/$HDF5_FILE
	cp "$HDF5_FILE" /vagrant
    else
	cp "/vagrant/$HDF5_FILE" .
    fi

    tar -jxf $HDF5_FILE
    pushd $HDF5_VER
    CC=`which mpicc` ./configure --enable-shared --disable-static --disable-fortran --enable-hl --disable-fortran --enable-parallel --prefix=/usr/local
    make install
    popd
    rm -rf $HDF5_VER
fi

##
# In order to do netcdf-fortran testing, we need to
# install netcdf-c in an out-of-the-way place.
##
if [ ! -f /home/vagrant/local2/lib/libnetcdf.settings ]; then
    git clone http://github.com/Unidata/netcdf-c
    pushd netcdf-c
    mkdir build
    cd build
    cmake .. -DCMAKE_INSTALL_PREFIX=/home/vagrant/local2 -DENABLE_TESTS=OFF -DENABLE_PARALLEL=ON -DCMAKE_BUILD_TYPE="Release" -DCMAKE_C_COMPILER=`which mpicc`
    make
    make install
    popd
    rm -rf netcdf-c/
fi


#####
# Set up git
#####

sudo -i -u vagrant git config --global user.name "Ward Fisher"
sudo -i -u vagrant git config --global user.email "wfisher@unidata.ucar.edu"
sudo -i -u vagrant git config --global push.default simple

#####
# Set up .emacs file
#####
echo "(set-face-attribute 'default nil :height 130)" >> /home/vagrant/.emacs
echo '(custom-set-variables' >> /home/vagrant/.emacs
echo " '(inhibit-startup-screen t)" >> /home/vagrant/.emacs
echo " '(show-paren-mode t)" >> /home/vagrant/.emacs
echo " '(uniquify-buffer-name-style (quote forward) nil (uniquify)))" >> /home/vagrant/.emacs


chown -R vagrant:vagrant /home/vagrant
sudo -i -u vagrant $CTEST_INIT
