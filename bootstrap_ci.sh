#!/usr/bin/env bash
# Local copy of bootstrap script, for testing purposes.
# Determine if we're using apt-get or yum
PKG_CMD=""
USE_APT=""
USE_YUM=""
#### Install base development packages.
if [ `which apt-get | wc -w` -gt 0 ]; then
USE_APT="TRUE"
PKG_CMD=`which apt-get`
PKG_UPDATE="$PKG_CMD update"
PKG_LIST="ubuntu-dev-tools m4 git libjpeg-dev libcurl4-openssl-dev wget htop libtool bison flex autoconf curl g++ midori"
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
# Install ctest as a system service.
# It is installed into /etc/init.d/ctest
#####

# Create a ctest user.
useradd ctest

CTEST_INIT="/etc/init.d/ctest"

echo '#!/bin/bash' > $CTEST_INIT
echo 'CTEST_HOME="/home/vagrant/ctest_scripts"' >> $CTEST_INIT
echo 'DASH="$CTEST_HOME/Dashboards"' >> $CTEST_INIT
echo '/bin/su vagrant -c "/bin/mkdir -p $CTEST_HOME"' >> $CTEST_INIT

echo "if [ -d /media/psf/vagrant ]; then" >> /$CTEST_INIT
echo "find /media/psf/vagrant -maxdepth 1 -type f -exec cp {} /home/vagrant/ctest_scripts \;" >> /$CTEST_INIT
echo "fi" >> /$CTEST_INIT
echo "" >> /$CTEST_INIT

echo "if [ -d /vagrant ]; then" >> /$CTEST_INIT
echo "find /vagrant -maxdepth 1 -type f -exec cp {} /home/vagrant/ctest_scripts \;" >> /$CTEST_INIT
echo "fi" >> /$CTEST_INIT

echo 'case "$1" in' >> $CTEST_INIT
echo ' start)' >> $CTEST_INIT
echo ' if [ ! -f /usr/local/bin/ctest ]; then' >> $CTEST_INIT
echo '    echo "ctest not found"' >> $CTEST_INIT
echo '    exit 1' >> $CTEST_INIT
echo ' fi' >> $CTEST_INIT
echo '      /bin/su vagrant -c "/bin/rm -rf $DASH"' >> $CTEST_INIT
echo '	    echo $"Starting ctest"' >> $CTEST_INIT
echo '      cd /home/vagrant/ctest_scripts/' >> $CTEST_INIT
echo '      /bin/su vagrant -c "/usr/local/bin/ctest -V -S CI.cmake > continuous_test.out 2>&1 &"' >> $CTEST_INIT
echo '	;;' >> $CTEST_INIT
echo ' stop)' >> $CTEST_INIT
echo '	    echo $"Stopping ctest"' >> $CTEST_INIT
echo '      /bin/su vagrant -c "/usr/bin/killall ctest"' >> $CTEST_INIT
echo ' 	;;' >> $CTEST_INIT
echo ' *)' >> $CTEST_INIT
echo ' 	echo $"Usage: $0 {start|stop}"' >> $CTEST_INIT
echo '	exit 1' >> $CTEST_INIT
echo '	;;' >> $CTEST_INIT
echo 'esac' >> $CTEST_INIT

echo 'exit $RETVAL' >> $CTEST_INIT
chmod 755 $CTEST_INIT
update-rc.d ctest defaults


####
# End installation of ctest as a system service.
# Note: We can't start it yet, ctest and hdf libraries
# haven't been installed yet.
####


## Install several packages from source.
# * cmake
# * hdf4
# * hdf5

CMAKE_VER="cmake-2.8.12.2"
HDF4_VER="hdf-4.2.10"
HDF5_VER="hdf5-1.8.12"

# Install cmake from source
if [ ! -f /usr/local/bin/cmake ]; then
CMAKE_FILE="$CMAKE_VER".tar.gz
wget http://www.cmake.org/files/v2.8/$CMAKE_FILE
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
wget http://www.hdfgroup.org/ftp/HDF/HDF_Current/src/$HDF4_FILE
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
wget http://www.hdfgroup.org/ftp/HDF5/current/src/$HDF5_FILE
tar -jxf $HDF5_FILE
pushd $HDF5_VER
./configure --disable-static --enable-shared --disable-fortran --enable-hl --disable-fortran --prefix=/usr/local
make install
popd
rm -rf $HDF5_VER
fi

####
# Start ctest system service.
####
/etc/init.d/ctest start

if [ -f /sbin/chkconfig ]; then
sleep 2
# For centos systems:
echo '/etc/init.d/ctest start' >> /etc/rc.local
fi
