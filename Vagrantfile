# -*- mode: ruby -*-
# vi: set ft=ruby :

$masterscript = <<TESTSCRIPT
set -e
#!/bin/sh
################
# Runs a TEST_JOB for a runner across multiple Operating systems to test the runner
################
# Define runner name
RUNNER_NAME=chef-solo
# Define which test in /test you would like to run
TEST_JOB=ntp-nginx
################ See end

# Random function since not all shells have $RANDOM
random () {
    hexdump -n 2 -e '/2 "%u"' /dev/urandom
}

#set temp dir to $TMPDIR or /tmp
if test "x$TMPDIR" = "x"; then
  export TMPDIR="/tmp"
fi
export OZONE_TMP_DIR="$TMPDIR/ozone/chef.$$.`random`"
(umask 077 && mkdir -p "$OZONE_TMP_DIR/workingfolder") || exit 1

define_step () {
  mkdir -p "$OZONE_TMP_DIR/runners/$RUNNER_NAME_$1/files"
  cp -r "/vagrant$2/"* "$OZONE_TMP_DIR/runners/$RUNNER_NAME_$1/"
  cp -r "$OZONE_TMP_DIR/runners/$RUNNER_NAME_$1/files/"* "$OZONE_TMP_DIR/workingfolder/" 2>/dev/null || true
}

start_step () {
  ( cd "$OZONE_TMP_DIR/workingfolder" && exec "$OZONE_TMP_DIR/runners/$RUNNER_NAME_$1/$1.sh" ) || exit 1
}

#load test specific variables
if test -f "/vagrant/test/$TEST_JOB/variables.sh"; then
  . /vagrant/test/$TEST_JOB/variables.sh
fi

################
# For each runner step define name and relative folder
define_step "install" "/install"
define_step "run" "/run"
################

# Copy test files. Will overwrite runnerfiles if available.
cp -r "/vagrant/test/$TEST_JOB/files/"* "$OZONE_TMP_DIR/workingfolder/" 2>/dev/null || true

################
# Run each step in the following order
start_step "install"
start_step "run"
################

TESTSCRIPT

Vagrant.configure(2) do |config|
    
    config.vm.provision "shell", inline: $masterscript

    config.vm.define "centos65" do |centos65|
      centos65.vm.box = "chef/centos-6.5"
    end

    config.vm.define "precise64" do |precise64|
      precise64.vm.box = "chef/ubuntu-12.04"
    end

    config.vm.define "quantal64" do |quantal64|
      quantal64.vm.box = "chef/ubuntu-12.10"
    end

    config.vm.define "raring64" do |raring64|
      raring64.vm.box = "chef/ubuntu-13.04"
    end

    config.vm.define "saucy64" do |saucy64|
      saucy64.vm.box = "chef/ubuntu-13.10"
    end

    config.vm.define "centos510" do |centos510|
      centos510.vm.box = "chef/centos-5.10"
    end

    config.vm.define "wheezy" do |wheezy|
      wheezy.vm.box = "chef/debian-7.4"
    end

    config.vm.define "squeeze" do |squeeze|
      squeeze.vm.box = "chef/debian-6.0.8"
    end

    config.vm.define "fedora20" do |fedora20|
      fedora20.vm.box = "chef/fedora-20"
    end

    config.vm.define "fedora19" do |fedora19|
      fedora19.vm.box = "chef/fedora-19"
    end

end
