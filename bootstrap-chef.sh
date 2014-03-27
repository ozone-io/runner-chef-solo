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

set -e

#default variables
CHEF_DEFAULT_ALWAYS_INSTALL_CHEF="true"
CHEF_DEFAULT_INSTALL_SCRIPT="https://www.opscode.com/chef/install.sh"
CHEF_DEFAULT_INSTALL_SCRIPT_ARGS=""
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
CHEF_INSTALL_SCRIPT_ARGS=${CHEF_INSTALL_SCRIPT_ARGS:-$CHEF_DEFAULT_INSTALL_SCRIPT_ARGS}
CHEF_SOLORB=${CHEF_SOLORB:-$CHEF_DEFAULT_SOLORB}
CHEF_COOKBOOK_PATH=${CHEF_COOKBOOK_PATH:-$CHEF_DEFAULT_COOKBOOK_PATH}
CHEF_NODE_JSON=${CHEF_NODE_JSON:-$CHEF_DEFAULT_NODE_JSON}

# Set up colours
if tty -s;then
    RED=${RED:-$(tput setaf 1)}
    GREEN=${GREEN:-$(tput setaf 2)}
    YLW=${YLW:-$(tput setaf 3)}
    BLUE=${BLUE:-$(tput setaf 4)}
    RESET=${RESET:-$(tput sgr0)}
else
    RED=
    GREEN=
    YLW=
    BLUE=
    RESET=
fi

# Timestamp
now () {
    date +'%H:%M:%S %z'
}

# Logging functions instead of echo
log () {
    echo "${BLUE}`now`${RESET} ${1}"
}

info () {
    log "${GREEN}INFO${RESET}: ${1}"
}

warn () {
    log "${YLW}WARN${RESET}: ${1}"
}

critical () {
    log "${RED}CRIT${RESET}: ${1}"
}

# Check whether a command exists - returns 0 if it does, 1 if it does not
exists() {
  if command -v $1 >/dev/null 2>&1
  then
    return 0
  else
    return 1
  fi
}

# Retrieve Platform and Platform Version
if test -f "/etc/lsb-release" && grep -q DISTRIB_ID /etc/lsb-release; then
  platform=`grep DISTRIB_ID /etc/lsb-release | cut -d "=" -f 2 | tr '[A-Z]' '[a-z]'`
  platform_version=`grep DISTRIB_RELEASE /etc/lsb-release | cut -d "=" -f 2`
elif test -f "/etc/debian_version"; then
  platform="debian"
  platform_version=`cat /etc/debian_version`
elif test -f "/etc/redhat-release"; then
  platform=`sed 's/^\(.\+\) release.*/\1/' /etc/redhat-release | tr '[A-Z]' '[a-z]'`
  platform_version=`sed 's/^.\+ release \([.0-9]\+\).*/\1/' /etc/redhat-release`

  # If /etc/redhat-release exists, we act like RHEL by default
  if test "$platform" = "fedora"; then
    # Change platform version for use below.
    platform_version="6.0"
  fi
  platform="el"
elif test -f "/etc/system-release"; then
  platform=`sed 's/^\(.\+\) release.\+/\1/' /etc/system-release | tr '[A-Z]' '[a-z]'`
  platform_version=`sed 's/^.\+ release \([.0-9]\+\).*/\1/' /etc/system-release | tr '[A-Z]' '[a-z]'`
  # amazon is built off of fedora, so act like RHEL
  if test "$platform" = "amazon linux ami"; then
    platform="el"
    platform_version="6.0"
  fi
elif test -f "/etc/release"; then
  platform="solaris2"
  machine=`/usr/bin/uname -p`
  platform_version=`/usr/bin/uname -r`
elif test -f "/etc/SuSE-release"; then
  if grep -q 'Enterprise' /etc/SuSE-release;
  then
      platform="sles"
      platform_version=`awk '/^VERSION/ {V = $3}; /^PATCHLEVEL/ {P = $3}; END {print V "." P}' /etc/SuSE-release`
  else
      platform="suse"
      platform_version=`awk '/^VERSION =/ { print $3 }' /etc/SuSE-release`
  fi
elif test "x$os" = "xFreeBSD"; then
  platform="freebsd"
  platform_version=`uname -r | sed 's/-.*//'`
elif test "x$os" = "xAIX"; then
  platform="aix"
  platform_version=`uname -v`
  machine="ppc"
fi

# Mangle $platform_version to pull the correct build
# for various platforms
major_version=`echo $platform_version | cut -d. -f1`
case $platform in
  "el")
    platform_version=$major_version
    ;;
  "debian")
    case $major_version in
      "5") platform_version="6";;
      "6") platform_version="6";;
      "7") platform_version="6";;
    esac
    ;;
  "freebsd")
    platform_version=$major_version
    ;;
  "sles")
    platform_version=$major_version
    ;;
  "suse")
    platform_version=$major_version
    ;;
esac

if test "x$platform_version" = "x"; then
  critical "Unable to determine platform version!"
  report_bug
  exit 1
fi

if test "x$platform" = "xsolaris2"; then
  # hack up the path on Solaris to find wget
  PATH=/usr/sfw/bin:$PATH
  export PATH
fi

checksum_mismatch() {
  critical "Package checksum mismatch!"
  report_bug
  exit 1
}

if test "x$platform" = "x"; then
  critical "Unable to determine platform version!"
  report_bug
  exit 1
fi

if test "x$TMPDIR" = "x"; then
  tmp="/tmp"
else
  tmp=$TMPDIR
fi

# Random function since not all shells have $RANDOM
random () {
    hexdump -n 2 -e '/2 "%u"' /dev/urandom
}

# do_wget URL FILENAME
do_wget() {
  info "Trying wget..."
  wget -O "$2" "$1" 2>$tmp_stderr
  rc=$?

  # check for 404
  grep "ERROR 404" $tmp_stderr 2>&1 >/dev/null
  if test $? -eq 0; then
    critical "ERROR 404"
    unable_to_retrieve_package
  fi

  # check for bad return status or empty output
  if test $rc -ne 0 || test ! -s "$2"; then
    capture_tmp_stderr "wget"
    return 1
  fi

  return 0
}

# do_curl URL FILENAME
do_curl() {
  info "Trying curl..."
  curl -sL -D $tmp_stderr "$1" > "$2"
  rc=$?
  # check for 404
  grep "404 Not Found" $tmp_stderr 2>&1 >/dev/null
  if test $? -eq 0; then
    critical "ERROR 404"
    unable_to_retrieve_package
  fi

  # check for bad return status or empty output
  if test $rc -ne 0 || test ! -s "$2"; then
    capture_tmp_stderr "curl"
    return 1
  fi

  return 0
}

# do_fetch URL FILENAME
do_fetch() {
  info "Trying fetch..."
  fetch -o "$2" "$1" 2>$tmp_stderr
  # check for bad return status
  test $? -ne 0 && return 1
  return 0
}

# do_perl URL FILENAME
do_perl() {
  info "Trying perl..."
  perl -e 'use LWP::Simple; getprint($ARGV[0]);' "$1" > "$2" 2>$tmp_stderr
  rc=$?
  # check for 404
  grep "404 Not Found" $tmp_stderr 2>&1 >/dev/null
  if test $? -eq 0; then
    critical "ERROR 404"
    unable_to_retrieve_package
  fi

  # check for bad return status or empty output
  if test $rc -ne 0 || test ! -s "$2"; then
    capture_tmp_stderr "perl"
    return 1
  fi

  return 0
}

do_checksum() {
  if exists sha256sum; then
    checksum=`sha256sum $1 | awk '{ print $1 }'`
    if test "x$checksum" != "x$2"; then
      checksum_mismatch
    else
      info "Checksum compare with sha256sum succeeded."
    fi
  elif exists shasum; then
    checksum=`shasum -a 256 $1 | awk '{ print $1 }'`
    if test "x$checksum" != "x$2"; then
      checksum_mismatch
    else
      info "Checksum compare with shasum succeeded."
    fi
  elif exists md5sum; then
    checksum=`md5sum $1 | awk '{ print $1 }'`
    if test "x$checksum" != "x$3"; then
      checksum_mismatch
    else
      info "Checksum compare with md5sum succeeded."
    fi
  elif exists md5; then
    checksum=`md5 $1 | awk '{ print $4 }'`
    if test "x$checksum" != "x$3"; then
      checksum_mismatch
    else
      info "Checksum compare with md5 succeeded."
    fi
  else
    warn "Could not find a valid checksum program, pre-install shasum, md5sum or md5 in your O/S image to get valdation..."
  fi
}

checksum_mismatch() {
  critical "checksum mismatch!"
  report_bug
  exit 1
}

# do_download URL FILENAME
do_download() {
  info "Downloading $1"
  info "  to file $2"

  # we try all of these until we get success.
  # perl, in particular may be present but LWP::Simple may not be installed

  if exists wget; then
    do_wget $1 $2 && return 0
  fi

  if exists curl; then
    do_curl $1 $2 && return 0
  fi

  if exists fetch; then
    do_fetch $1 $2 && return 0
  fi

  if exists perl; then
    do_perl $1 $2 && return 0
  fi

  critical "Could not download file. No download methods available."
}

# Helper bug-reporting text
report_bug() {
  critical "Please file a bug report at https://github.com/ozone-io/bootstrap-chef"
  critical ""
  critical "Version: $version"
  critical "Platform: $platform"
  critical "Platform Version: $platform_version"
  critical "Machine: $machine"
  critical "OS: $os"
  critical ""
  critical "Please detail your operating system type, version and any other relevant details"
}


#set temp stuff
tmp_dir="$tmp/install.sh.$$.`random`"
(umask 077 && mkdir $tmp_dir) || exit 1

tmp_stderr="$tmp/stderr.$$.`random`"

#start main script logic

info "-- start script $0"
info "-- detected os details:"
info ""
info "Version: $version"
info "Platform: $platform"
info "Platform Version: $platform_version"
info "Machine: $machine"
info "OS: $os"
info ""

if [ "x$CHEF_ALWAYS_INSTALL_CHEF" = "xtrue" ] || ! chef-solo --version >/dev/null 2>&1; then
	info "-- chef not detected or installation is forced"
	info "-- download chef install script to $tmp_dir/chef-solo-install.sh"
	do_download "$CHEF_INSTALL_SCRIPT" "$tmp_dir/chef-solo-install.sh" 
	info "-- run chef install script: sh $tmp_dir/chef-solo-install.sh $CHEF_INSTALL_SCRIPT_ARGS"
	sh "$tmp_dir/chef-solo-install.sh" "$CHEF_INSTALL_SCRIPT_ARGS" 
	info "-- finished chef install script"
else
	info "-- chef-solo found. skipping chef installation."
fi

info "-- creating and filling /etc/chef/solo.rb "
mkdir -p /etc/chef
echo "$CHEF_SOLORB" > /etc/chef/solo.rb
info "-- finished filling /etc/chef/solo.rb"

info "-- filling /etc/chef/node.json"
echo "$CHEF_NODE_JSON" > /etc/chef/node.json
info "-- finished filling /etc/chef/node.json"

if ! test "x$CHEF_COOKBOOKS_URL" = "x"; then
	info "-- downloading and installing cookbook(s) from $CHEF_COOKBOOKS_URL"
	rm -rf "$CHEF_COOKBOOK_PATH"
	#avoid errors during extraction run.
	mkdir -p "$CHEF_COOKBOOK_PATH/noop"
	#downloads always extract out of /var/chef. No matter what
	chef-solo -o '' -r "$CHEF_COOKBOOKS_URL"
	#if tar folder is set, we completely replace the cookbooks folder.
	#if it is not, we assume that the tar.gz has a structure that allows chef-solo to extract and interpret the cookbooks by itself
	if ! test "x$CHEF_COOKBOOKS_TAR_PATH" = "x"; then
		warn "-- tar path set to $CHEF_COOKBOOKS_TAR_PATH. Removing old cookbooks and replacing it."
		#todo: test if folder actually exists before doing anything.
		rm -rf "$CHEF_COOKBOOK_PATH"
		mv "/var/chef/$CHEF_COOKBOOKS_TAR_PATH" "$CHEF_COOKBOOK_PATH"
	fi
	info "-- done installing cookbooks"
else
	warn "-- no cookbook-url. not replacing cookbooks."
fi


info "-- run chef-solo -j /etc/chef/node.json"
chef-solo -j /etc/chef/node.json
info "-- finished chef-solo run" 
