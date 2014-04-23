# Tiny-CI

A Tiny, Self-Contained NetCDF-C Continuous Integration Instance and Dashboard

# Overview

## Requirements

* Vagrant
* VM Software:
	* VirtualBox
	* Parallels

## Default Credentials

By default, the dashboard VM is on a local private network and is not exposed to the outside world.  As a result, there should not be a security issue. 

* Username: `admin@localhost`
* Password: `cdash`

> Note that if you change the credentials (or, in fact, any settings of the project) you need to run the export_mysql script on the dashboard VM to create a new default database file. 

# Usage

1. Create the dashboard:

> $ vagrant up dash

This will create a dashboard which may be accessed at http://192.168.55.10/CDash.

2. Create Continuous-Integration instances:

> $ vagrant up [CI instance name]

For a full list of CI instance names, invoke `vagrant 
