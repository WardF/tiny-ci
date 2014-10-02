#!/bin/bash

# Utility script to package up a given image as a
# prebuilt image.

vagrant up t64
vagrant package t64 --output nc_t64.box
vagrant box remove nc_t64
vagrant box add nc_t64.box --name nc_t64

vagrant up t32
vagrant package t32 --output nc_t32.box
vagrant box remove nc_t32
vagrant box add nc_t32.box --name nc_t32
