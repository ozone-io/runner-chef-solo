#/bin/sh
#temp file for reading constants
OUT="$(mktemp)"

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

/vagrant/bootstrap-chef.sh
