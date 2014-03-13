#!/bin/sh

# 	Copyright 2014 Werner Buck
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

set -e -x

#temp file for reading constants
OUT="$(mktemp)"

#user input
export CHEF_COOKBOOKS_URL="https://github.com/ozone-io/bootstrap-chef-test-cookbooks/archive/master.tar.gz"
export CHEF_COOKBOOKS_PATH="bootstrap-chef-test-cookbooks-master/cookbooks"
export CHEF_ALWAYS_INSTALL_CHEF="false"

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

#end userinput
#helper functions
#does not work with multiline variables. (you shouldn't use it for that anyway)
getenvarray () { env | grep "^$1" | sed "s/$1.*=//"; }

#default variables
CHEF_DEFAULT_ALWAYS_INSTALL_CHEF="true"
CHEF_DEFAULT_INSTALL_SCRIPT="https://www.opscode.com/chef/install.sh"
CHEF_DEFAULT_COOKBOOK_PATH="/var/chef/cookbooks"
CHEF_DEFAULT_SOLORB="cookbook_path [
	\"/var/chef/cookbooks\",
	\"/var/chef/site-cookbooks\"
]
data_bag_path \"/var/chef/databags\""
CHEF_DEFAULT_NODE_JSON="{}"

#set default variables
CHEF_ALWAYS_INSTALL_CHEF=${CHEF_ALWAYS_INSTALL_CHEF:-$CHEF_DEFAULT_ALWAYS_INSTALL_CHEF}
CHEF_INSTALL_SCRIPT=${CHEF_INSTALL_SCRIPT:-$CHEF_DEFAULT_INSTALL_SCRIPT}
CHEF_SOLORB=${CHEF_SOLORB:-$CHEF_DEFAULT_SOLORB}
CHEF_COOKBOOK_PATH=${CHEF_COOKBOOK_PATH:-$CHEF_DEFAULT_COOKBOOK_PATH}
CHEF_NODE_JSON=${CHEF_NODE_JSON:-$CHEF_DEFAULT_NODE_JSON}

#if curl is missing, use wget
if [ "$CHEF_ALWAYS_INSTALL_CHEF" = "true" ] || ! chef-solo --version >/dev/null 2>&1; then
	echo "-- chef not detected, Installing.."
	echo "-- run chef install script"
	#install with wget or curl depending on which exists.
	( ! command -v curl >/dev/null 2>&1 && wget -q -O - "$CHEF_INSTALL_SCRIPT" | sudo bash ) || curl -L "$CHEF_INSTALL_SCRIPT" | sudo bash
	echo "-- finished chef install script"
else
	echo "-- chef-solo found. skipping chef installation."
fi

echo "-- creating and filling /etc/chef/solo.rb "
mkdir -p /etc/chef
echo "$CHEF_SOLORB" > /etc/chef/solo.rb
echo "-- finished filling /etc/chef/solo.rb"

echo "-- filling /etc/chef/node.json"
echo "$CHEF_NODE_JSON" > /etc/chef/node.json
echo "-- finished filling /etc/chef/node.json"

echo "-- downloading and installing cookbook(s) from $COOKBOOKS_URL"
#avoid errors during extraction run.
mkdir -p "$CHEF_COOKBOOK_PATH/noop"
#downloads always extract out of /var/chef. No matter what
chef-solo -o '' -r "$CHEF_COOKBOOKS_URL"
rm -rf /var/chef/cache
rm -rf /var/chef/recipes.tar.gz
rm -rf "$CHEF_COOKBOOK_PATH"
mv "/var/chef/$CHEF_COOKBOOKS_PATH" "$CHEF_COOKBOOK_PATH"
echo "-- done installing cookbooks"

echo "-- run chef-solo -j /etc/chef/node.json"
chef-solo -j /etc/chef/node.json
echo "-- finished chef-solo run" 
