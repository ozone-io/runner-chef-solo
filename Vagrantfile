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
export OZONE_TMP_DIR="$TMPDIR/ozone/ozone.$$.`random`"
(umask 077 && mkdir -p "$OZONE_TMP_DIR/workingfolder") || exit 1

start_step () {
  export OZONE_FILES="/vagrant/test/$TEST_JOB/files"
  export OZONE_RUNNER="/vagrant$2/files"
  ( cd "$OZONE_TMP_DIR/workingfolder" && exec "/vagrant$2/$1.sh" ) || exit 1
}

#load test specific variables
if test -f "/vagrant/test/$TEST_JOB/variables.sh"; then
  . /vagrant/test/$TEST_JOB/variables.sh
fi

################
# Run each step in the following order
start_step "install" "/install"
start_step "run" "/run"
################

TESTSCRIPT
Vagrant.configure(2) do |config|
    
    config.vm.network "forwarded_port", guest: 80, host: 9100, auto_correct: true
    
    config.vm.provision "shell", inline: $masterscript

    config.vm.define "centos65" do |centos65|
      centos65.vm.box = "chef/centos-6.5"
    end

    config.vm.define "precise64" do |precise64|
      precise64.vm.box = "chef/ubuntu-12.04"
    end

    #End-of-life since april
    #config.vm.define "quantal64" do |quantal64|
    #  quantal64.vm.box = "chef/ubuntu-12.10"
    #end

    #End-of-life since january 27
    #config.vm.define "raring64" do |raring64|
    #  raring64.vm.box = "chef/ubuntu-13.04"
    #end

    config.vm.define "saucy64" do |saucy64|
      saucy64.vm.box = "chef/ubuntu-13.10"
    end

    config.vm.define "trusty64" do |trusty64|
      trusty64.vm.box = "chef/ubuntu-14.04"
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

    #does not have iptables service
    #config.vm.define "fedora20" do |fedora20|
    #  fedora20.vm.box = "chef/fedora-20"
    #end

    #Does not have iptables service
    #config.vm.define "fedora19" do |fedora19|
    #  fedora19.vm.box = "chef/fedora-19"
    #end

end
