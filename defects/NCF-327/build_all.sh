#!/bin/bash

set -x

gcc -I/usr/local/include -L/usr/local/lib -Wall -ggdb -O0 -o ncbug ncbug.c -lnetcdf

gcc -I/usr/local/include -L/usr/local/lib -Wall -ggdb -O0 -o h5bug h5bug.c -lhdf5 -lhdf5_hl
