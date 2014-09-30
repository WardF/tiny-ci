#!/bin/bash

# Utility script to package up a given image as a
# prebuilt image.

vagrant up t64
vagrant package t64 --output prebuilt_t64.box
vagrant box remove prebuilt_t64
vagrant box add prebuilt_t64.box --name prebuilt_t64

vagrant up t32
vagrant package t32 --output prebuilt_t32.box
vagrant box remove prebuilt_t32
vagrant box add prebuilt_t32.box --name prebuilt_t32
