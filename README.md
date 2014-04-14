bootstrap-chef
==============

chef-solo runner for ozone.io

Installs, configures and runs chef solo with some configuration.

#### Credits
The install script comes from opscode. Thanks!

### OS supported

Tested with vagrant:

* _Ubuntu_: 12.04, 12.10, 13.04, 13.10
* _CentOS_: 5.8, 5.10, 6.5
* _Debian_: 6.0.8 (Squeeze), 7.4 (Wheezy)
* _fedora_: 19,20


### Purpose:
This script as well as its cousin [bootstrap-puppet](https://github.com/ozone-io/bootstrap-puppet) and its future cousins are part of the [ozone.io](http://ozone.io) project.
Ozone.io can deploy complex multi-tier infrastructure to any target such as ec2, openstack, physical and more by the push of a button.

Underlying principles:

* Any state introduced except by your configuration management tool "taints" the image, as your actions will be not be reproducable by your co-workers or those that will inherit your work.
* Reap the benefits of using vanilla cloud images by experimenting with various operating system versions. Upgrading a distribution will never be easier than this and at most involve you to change your configuation management parameters accordingly, which is what the cm-tool is expected of.

### How to use:
If not used with ozone, look at the embedded script in the Vagrantfile.

There you can change config:

* CHEF_COOKBOOKS_URL: The url at which cookbooks can be downloaded. For example: `https://github.com/ozone-io/bootstrap-chef-test-cookbooks/archive/master.tar.gz`
* CHEF_COOKBOOKS_TAR_PATH: The path in the tar where the cookbooks are located. For example `bootstrap-chef-test-cookbooks-master/cookbooks`

Or you can change files in steps/run/files:

* solo.rb: This sets the configuration of chef solo and defines the content of the `solo.rb` file.
* node.json: This sets the configuration for chef solo.

### Test

The Vagrantfile will install and configure ntp, nginx and mysql on each vm.

Examine the Vagrantfile for the distro you would like to test. Then for i.e. fedora20, excute the following:

    vagrant up fedora20

* Requires vagrant 1.5+ (uses the Vagrantcloud for boxes)
