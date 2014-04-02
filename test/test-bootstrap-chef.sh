#/bin/sh

# The url of which the cookbooks can be downloaded. Should always be a tar.gz. Use github and specific branches for more control.
export CHEF_COOKBOOKS_URL="https://github.com/ozone-io/bootstrap-chef-test-cookbooks/archive/master.tar.gz"
# The path in the tar.gz that contains all the cookbooks.
export CHEF_COOKBOOKS_TAR_PATH="bootstrap-chef-test-cookbooks-master/cookbooks"
# This installs chef even if chef-solo exists.
export CHEF_ALWAYS_INSTALL_CHEF="true"
# The arguments to the chef install script. The following arg is the specification of a version.
export CHEF_INSTALL_SCRIPT_ARGS="-v11.10.4"

## Start of environment variable settings. The following method of using heredoc and cat works on most (if not all) distributions.

#The content of the solo.rb file: http://docs.opscode.com/config_rb_solo.html
export CHEF_SOLORB=$(cat << "EOF"
cookbook_path [
	"/var/chef/cookbooks"
]
data_bag_path "/var/chef/databags"
EOF
)

#The content of the node attribute data. See the chef website
export CHEF_NODE_JSON=$(cat << "EOF"
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
)

# In vagrant we expect the /vagrant folder to be available. It runs the bootstrap-chef.sh script. See README.md to see how to test.
/vagrant/bootstrap-chef.sh