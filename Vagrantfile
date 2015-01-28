# -*- mode: ruby -*-
# vi: set ft=ruby :


$masterscript = <<TESTSCRIPT
set -e
#!/bin/sh
# Set TEST_JOB to specify which test in /test to executes
if test "x$1" = "x"; then
  export TEST_JOB=$(ls /vagrant/test | sort -n | sed 's%\/$%%' | head -1)
fi

#set temp dir to $TMPDIR or /tmp
if test "x$TMPDIR" = "x"; then
  export TMPDIR="/tmp"
fi
export OZONE_TMP_DIR="$TMPDIR/ozone/ozone.$$"
export OZONE_FILES="/vagrant/test/$TEST_JOB/files"
(umask 077 && mkdir -p "$OZONE_TMP_DIR/workingfolder") || exit 1

#load test specific variables
if test -f "/vagrant/test/$TEST_JOB/variables.sh"; then
  . /vagrant/test/$TEST_JOB/variables.sh
fi

start_script () {
  export OZONE_RUNNER="/vagrant/$1/files"
  ( cd "$OZONE_TMP_DIR/workingfolder" && exec "/vagrant/$1/script.sh" ) || exit 1
}

################
# Run the following scripts for this runner
start_script "install"
start_script "run"
################

TESTSCRIPT
Vagrant.configure(2) do |config|
    
    config.vm.network "forwarded_port", guest: 80, host: 9100, auto_correct: true
    
    config.vm.provision "shell", inline: $masterscript, args: ENV['TEST_JOB']

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
