#Test variables that install nginx/ntp

# The url of which the cookbooks can be downloaded. Should always be a tar.gz. Use github and specific branches for more control.
export CHEF_COOKBOOKS_URL="https://github.com/ozone-io/bootstrap-chef-test-cookbooks/archive/master.tar.gz"
# The path in the tar.gz that contains all the cookbooks.
export CHEF_COOKBOOKS_TAR_PATH="bootstrap-chef-test-cookbooks-master/cookbooks"
# This installs chef even if chef-solo exists.
export CHEF_ALWAYS_INSTALL_CHEF="false"
# The arguments to the chef install script. The following arg is the specification of a version.
export CHEF_INSTALL_SCRIPT_ARGS="-v11.10.4"
# The installl script location
export CHEF_INSTALL_SCRIPT="https://www.opscode.com/chef/install.sh"
# The cookbook path
export CHEF_COOKBOOK_PATH="/var/chef/cookbooks"
