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

> Note that if you change the credentials (or, in fact, any settings of the project) you need to run the script `export_mysql.sh` on the `dash` VM to create a new default database file. This file lives in `/home/vagrant`.

# Usage

The goal of this project is to allow for a local Continuous Integration platform.  On most machines, you will want to run only one or two VM's at a time, unless your computer has a large amount of available resources.  By default, the *source* git repository is named `netcdf-c`, and is located inside the `tiny-ci` directory, e.g.:

* `tiny-ci/`
	* `netcdf-c/`
	* `Vagrantfile`
	* `README.md`
	* ...

## Instantiate VM's

1. Create the dashboard:

> $ vagrant up dash

This will create a dashboard which may be accessed at http://192.168.55.10/CDash.

2. Create Continuous-Integration instances:

> $ vagrant up [CI instance name]

For a full list of CI instance names, run vagrant from the command line, e.g.:

> $ vagrant status

The dashboard instance is required to be built and running in order for any of the other instances to work. 






## Development

Once the dashboard and at least one CI instance is provisioned and running, you may begin working.  As stated above, the CI instance(s) will monitor the `netcdf-c` directory for changes and, when found, will run the CI tests.  The repository is polled for changes every `60` seconds, allow for fairy rapid responses.

If you want to change branches in `netcdf-c` on the host machine, you will need to restart the CI instances.  This can be done very easily, as follows:

> $ vagrant halt

> $ vagrant up

Note that every time you restart the CI instance, it will repeate the *initial* CI analysis, which may lead to multiple listings in the Dashboard.  
