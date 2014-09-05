Ozone Runner: chef-solo
==============

chef-solo runner for ozone.io

Installs, configures and runs chef solo with a certain state configuration (see `/test`).

Use vagrant and test states to test chef-solo configuration across multiple distributions.

See `/test/ntp-nginx` and `Vagrantfile` for defining your own test jobs.

#### Credits
The install script for chef is created and maintained by Opscode!

### Distributions supported and tested
* _Ubuntu_: 12.04, 12.10, 13.04, 13.10 14.04
* _CentOS_: 5.8, 5.10, 6.5
* _Debian_: 6.0.8 (Squeeze), 7.4 (Wheezy)
* _fedora_: 19,20

### Purpose:
This script as well as its cousin [bootstrap-puppet](https://github.com/ozone-io/bootstrap-puppet) and its future cousins are part of the TBA [ozone.io](http://ozone.io) project.

### How to create a test job:

1. Create a folder in `/test`
2. (Optionally) Define exports in `/test/yourtest/variables.sh`
3. (Optionally) Define files that should be used/overriden as configuration in `/test/yourtest/files/`

Look at `/test/ntp-nginx` as an example

### Run Test

The Vagrantfile will provision each vm with the configured test job. By default this is the first item in `/test` to install nginx and ntp and configure it.

Examine the Vagrantfile for the distro you would like to test. For example, for `fedora20` and execute the following:

    vagrant up fedora20

Test a specific configuration by using the following command:

    TEST_JOB=ntp-nginx vagrant up fedora20

Test some job on all distro's and clean up afterwards with:

    TEST_JOB=ntp-nginx vagrant destroy -f && vagrant up && vagrant destroy -f

* Testing requires vagrant 1.5+ (uses the Vagrantcloud for boxes)