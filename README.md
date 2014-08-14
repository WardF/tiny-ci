# Tiny-CI

A Tiny, Self-Contained NetCDF-C Continuous Integration/Development Instance and Dashboard

# Overview

The VM's defined in the accompanying `Vagrantfile` are used for testing netcdf in a local Continuous-Integration environment.  They also provide various platforms to test and develop on. The bulk of the platforms are Ubuntu-based distributions.

## Requirements

* Vagrant
* VM Software:
	* VirtualBox

# Usage

In order for these VM's to run their CI scripts, the `netcdf-c/` and `netcdf-fortran/` directories must exist in the `tiny-ci/` directory.

In order for the VM's to run continuous integration, the relevant project directories must exist.  The projects which are checked for are:

* `netcdf-c/` - The netcdf-c project.
* `netcdf-fortran/` - The netcdf-fortran project.
* `netcdf-image/` - Ward's pilot project which may or may not go anywhere.

Changes made to these local git repositories will be tested by the CI instances.

    Note: If you change branches in the repository on the host machine, you *must* restart the VM in order for the CI script to begin watching this new branch.

## Suppressing Continuous Integration Testing

In the event that you want to use a VM for development or on-the-spot tests, instead of Continuous Integration testing, you would create the following files in the root `tiny-ci/` directory (`/vagrant/` on the VM).

* `NOTEST` - Prevents any CI tests from running.
* `NOTESTC` - Prevents CI tests for `netcdf-c` from running.
* `NOTESTF` - Prevents CI tests for `netcdf-fortran` from running.
* `NOTESTI` - Prevents CI tests for `netcdf-image` from running.

Note: 

    These files may be created and deleted on-the-fly.  The CI script will run at boot, but it checks for the presence of these files before running any tests.  If they are present, no tests are run.



## Instantiate VM's

1. Create the dashboard:

> $ vagrant up dash

This will create a dashboard which may be accessed at http://10.1.2.10/CDash.

### Default Credentials

By default, the dashboard VM is on a local private network and is not exposed to the outside world.  As a result, there should not be a security issue. 

* Username: `admin@localhost`
* Password: `cdash`

> Note that if you change the credentials (or, in fact, any settings of the project) you need to run the script `export_mysql.sh` on the `dash` VM to create a new default database file. This file lives in `/home/vagrant`.


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

Note that every time you restart the CI instance, it will repeat the *initial* CI analysis, which may lead to multiple listings in the Dashboard. 


