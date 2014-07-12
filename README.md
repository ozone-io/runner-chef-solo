Ozone Runner: chef-solo
==============

chef-solo runner for ozone.io

Installs, configures and runs chef solo with a certain configuration.

Use vagrant and test jobs to test chef-solo configuration across multiple distributions!

See `/test/ntp-nginx` and `Vagrantfile` for defining your own test jobs to evaluate this runner.

#### Credits
The install script comes from opscode. Thanks!

### Distributions supported and tested
* _Ubuntu_: 12.04, 12.10, 13.04, 13.10
* _CentOS_: 5.8, 5.10, 6.5
* _Debian_: 6.0.8 (Squeeze), 7.4 (Wheezy)
* _fedora_: 19,20

### Purpose:
This script as well as its cousin [bootstrap-puppet](https://github.com/ozone-io/bootstrap-puppet) and its future cousins are part of the TBA [ozone.io](http://ozone.io) project.

Ozonefile is used to install runners.

### How to create a test job:

1. Create a folder in `/test`
2. Define exports in `/test/yourjob/variables.sh`
3. Define files that should be used/overriden as configuration in `/test/yourjob/files/`

Look at `/test/ntp-nginx` as an example

### Run Test

The Vagrantfile will provision each vm with the configured test job. By default this is `ntp-nginx` to install nginx and ntp and configure it.
Set `TEST_JOB` in `Vagrantfile` to the folder holding your test job and run as follows:

Examine the Vagrantfile for the distro you would like to test. For example, for `fedora20`, excute the following:

    vagrant up fedora20

Test the job on all distro's by using:

    vagrant destroy -f && vagrant up && vagrant destroy -f

* Testing requires vagrant 1.5+ (uses the Vagrantcloud for boxes)
