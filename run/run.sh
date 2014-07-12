#!/bin/sh
mkdir -p /etc/chef
cp "solo.rb" /etc/chef/solo.rb
cp "node.json" /etc/chef/node.json
#installing cookbooks from $CHEF_COOKBOOKS_URL
if ! test "x$CHEF_COOKBOOKS_URL" = "x"; then
  rm -rf "$CHEF_COOKBOOK_PATH"
  #avoid errors during extraction run.
  mkdir -p "$CHEF_COOKBOOK_PATH/noop"
  #Download a tar.gz with chef-solo itself.
  chef-solo -o '' -r "$CHEF_COOKBOOKS_URL"
  #A bug in chef-solo exists where downloads always extract out of /var/chef. No matter what configuration.
  #if tar folder is set, we completely replace the cookbooks folder.
  #if it is not, we assume that the tar.gz has a structure that allows chef-solo to extract and interpret the cookbooks by itself
  if ! test "x$CHEF_COOKBOOKS_TAR_PATH" = "x"; then
    #tar path set to $CHEF_COOKBOOKS_TAR_PATH. Removing old cookbooks and replacing it."
    #todo: test if folder actually exists before doing anything.
    rm -rf "$CHEF_COOKBOOK_PATH"
    mv "/var/chef/$CHEF_COOKBOOKS_TAR_PATH" "$CHEF_COOKBOOK_PATH"
  fi
fi

#run with the configuration in node.json
chef-solo -j /etc/chef/node.json