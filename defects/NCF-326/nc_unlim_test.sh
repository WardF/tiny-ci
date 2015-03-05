#!/bin/bash
#
# Script to check for regression described in bug
# QCX-463169.

if [ -f unlim_test ]; then
    rm unlim_test
fi

if [ -d /Users/wfisher/local-test ]; then
    rm -rf /Users/wfisher/local-test
fi

autoreconf -if
./configure --prefix=/Users/wfisher/local-test
make -j 4
make install

#mkdir -p build-test
#cd build-test

#cmake .. -DENABLE_TESTS=OFF
#make -j 4

cp /sandbox/gitprojects/tiny-ci/unlim_test.c .
echo "Compiling unlim_test.c"
gcc unlim_test.c -I/Users/wfisher/local-test/include -L/Users/wfisher/local-test/lib -lnetcdf -o unlim_test
echo "Running unlim_test.c"
LD_LIBRARY_PATH=/Users/wfisher/local-test/lib ./unlim_test
STATUS=$?
git clean -fd
git reset --hard
exit $STATUS
