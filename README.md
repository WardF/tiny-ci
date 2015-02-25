# Tiny-CI

A Tiny, Self-Contained NetCDF-C Continuous Integration/Development Instance and Dashboard.  By using lock files (see [Suppressing Continuous Integration Testing](#suppress)).

> See [Important Notes](#important_notes) at the bottom of the page for things to keep in mind when working with these VMs!

# Overview

The VM's defined in the accompanying `Vagrantfile` are used for testing netcdf in a local Continuous-Integration environment.  They also provide various platforms to test and develop on. The bulk of the platforms are Ubuntu-based distributions.

## Requirements

* `Vagrant`: http://vagrantup.com
* `Virtualbox`: http://virtualbox.org

> Note, you must also install the VirtualBox tools, available as a separate download on the same page as the VirtualBox download.

### Vagrant Boxes

Note that the vagrant config file, `Vagrantfile`, makes assumptions as to what Vagrant boxes are available on your system.  If you do not have any Vagrant boxes, there are two choices:

1. Ask Ward to provide them.  They are available via `Bittorrent Sync`, and I will provide the read-only key most of the time.
2. Replace the 'local' definitions with cloud-based ones.  You can make the substitutions for the main boxes as follows:

Local Box | Cloud Equivalent
----|----
unicorn64 | bunchc/utopic-x64
trusty64 | ubuntu/trusty64
trusty32 | ubuntu/trusty32

You would make the change in `Vagrantfile` as follows:

~~~.bash
v.vm.box = "trusty64"
~~~

becomes

~~~.bash
v.vm.box = "ubuntu/trusty64"
~~~

You can search for additional boxes at http://www.vagrantcloud.com, or talk to me (Ward). I've built a number of boxes from scratch, including many Ubuntu, CentOS, Fedora and Debian distributions.  

# Using Tiny-CI for local Continuous Integration, Development

In order for these VM's to run their CI scripts, the `netcdf-c/` and `netcdf-fortran/` directories must exist in the `tiny-ci/` directory.

In order for the VM's to run continuous integration, the relevant project directories must exist.  The projects which are checked for are:

* `netcdf-c/` - The netcdf-c project.
* `netcdf-fortran/` - The netcdf-fortran project.

Changes made to these local git repositories will be tested by the CI instances.

    Note: If you change branches in the repository on the host machine, you *must* restart the VM in order for the CI script to begin watching this new branch.

## <a name="suppress"></a> Suppressing Continuous Integration Testing

In the event that you want to use a VM for development or on-the-spot tests, instead of Continuous Integration testing, you would create the following files in the root `tiny-ci/` directory (`/vagrant/` on the VM).

* `NOTEST` - Prevents any CI tests from running.
* `NOTESTC` - Prevents CI tests for `netcdf-c` from running.
* `NOTESTF` - Prevents CI tests for `netcdf-fortran` from running.

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

## <a name="important_notes"></a>Important Notes

* If a CI system is halted and then restarted, it will ***usually*** start the CI process on boot.  If not you'll need to log in and run the `/home/vagrant/ctest_service.sh` script manually.
* For whatever reason, the `CDash` dashboard does not work properly if the VM is halted and restarted.  You must either ***suspend*** the VM, or destroy/create it as needed.

