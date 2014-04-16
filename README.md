# tiny-ci: A Tiny, Self-Contained NetCDF-C Continuous Integration Instance and Dashboard

# Overview

## Requirements

* Vagrant
* VM Software:
	* VirtualBox
	* Parallels

## Default Credentials

By default, the dashboard VM is on a local private network and is not exposed to the outside world.  As a result, there should not be a security issue. 

* Username: admin@localhost
* Password: cdash

> Note that if you change the credentials (or, in fact, any settings of the project) you need to run the export_mysql script on the dashboard VM to create a new default database file. 

# Usage