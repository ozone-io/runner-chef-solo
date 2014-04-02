bootstrap-chef
==============

A script that installs, configures and runs chef solo, that works on all recent unix distributions.

The script takes most of the code from the chef installation script!

### Prerequisites
* Internet Access
* A Vanilla distribution: Do not have chef pre-installed by a third party.

### Purpose:
This script as well as its cousin [bootstrap-puppet](https://github.com/ozone-io/bootstrap-puppet) and its future cousins are part of the [ozone.io](http://ozone.io) project that aims to abstract various cloud providers and configuration management tools in a simple understandable manner to test and deploy large clusters.

Underlying principles:

* Any state introduced except by your configuration management tool "taints" the image, as your actions will be not be reproducable by your co-workers or those that will inherit your work.
* Do not use snapshots or cloning of your machines when launch-time is not important. Rather re-deploy the same base-image and provision it from beginning to end. This will make sure the state of your cluster is always reproducable.
* Reap the benefits of using vanilla cloud images by experimenting with various operating system versions. Upgrading a distribution will never be easier than this and at most involve you to change your configuation management parameters accordingly, which is what the cm-tool is expected of.

### How to use:
Default with no environment variables, only puppet is installed and nothing is done.

When you wish to add modules/configuration, you set the following environment variables:

* CHEF_COOKBOOKS_URL: The url at which cookbooks can be downloaded. For example: `https://github.com/ozone-io/bootstrap-chef-test-cookbooks/archive/master.tar.gz`
* CHEF_COOKBOOKS_TAR_PATH: The path in the tar where the cookbooks are located. For example `bootstrap-chef-test-cookbooks-master/cookbooks`
* CHEF_SOLORB: This sets the configuration of chef solo and defines the content of the `solo.rb` file.
* CHEF_NODE_JSON: This sets the configuration for chef solo.

--------------
For example, for installing modules nginx,ntp, the following configuration downloads the cookbooks from github, and installs and configures nginx and ntp.

    export CHEF_COOKBOOKS_URL="https://github.com/ozone-io/bootstrap-chef-test-cookbooks/archive/master.tar.gz"
    export CHEF_COOKBOOKS_TAR_PATH="bootstrap-chef-test-cookbooks-master/cookbooks"
    export CHEF_ALWAYS_INSTALL_CHEF="true"
    #leave empty for latest
    export CHEF_INSTALL_SCRIPT_ARGS="-v11.10.4"
    
    #set multiline variable CHEF_SOLORB
    cat > "$OUT" << EOF
    cookbook_path [
        "/var/chef/cookbooks"
    ]
    data_bag_path "/var/chef/databags"
    EOF
    export CHEF_SOLORB="$(cat "$OUT")"
    #end multiline variable CHEF_SOLORB
    
    #set multiline variable CHEF_NODE_JSON
    cat > "$OUT" << EOF
    {
    	"run_list": [
    		"apt::default",
    		"recipe[nginx]",
    		"recipe[ntp]"
    	],
    	"ntp": {
    		"is_server": false,
    		"servers": [
    			"0.pool.ntp.org",
    			"1.pool.ntp.org"
    		]
    	}
    }
    EOF
    export CHEF_NODE_JSON="$(cat "$OUT")"
    #end multiline variable CHEF_NODE_JSON

### Test

The test folder contains settings that will install and configure ntp, nginx and mysql.

Examine the Vagrantfile for the distro you would like to test. Then for i.e. fedora20, excute the following:

    vagrant up fedora20

Vagrant will automatically execute the test script and install chef, download cookbooks, and run chef solo.

* Requires vagrant 1.5+ (uses the Vagrantcloud for boxes)

### OS supported

Tested on the following using vagrant but should support more in the future. (Or already does)

* _Ubuntu_: 12.04, 12.10, 13.04, 13.10
* _CentOS_: 5.8, 5.10, 6.5
* _Debian_: 6.0.8 (Squeeze), 7.4 (Wheezy)
* _fedora_: 19,20

