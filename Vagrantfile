# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.provision "shell", path: "bootstrap-chef.sh"

  #config.vm.network :forwarded_port, host: 4567, guest: 80

  config.vm.define "precise" do |precise|
    precise.vm.box = "precise64"
    precise.vm.box_url = "http://files.vagrantup.com/precise64.box"
  end

  config.vm.define "saucy" do |saucy|
    saucy.vm.box = "saucy"
    saucy.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/saucy/current/saucy-server-cloudimg-i386-vagrant-disk1.box"
  end

  config.vm.define "centos6" do |centos6|
    centos6.vm.box = "centos65"
    centos6.vm.box_url = "https://github.com/2creatives/vagrant-centos/releases/download/v6.5.1/centos65-x86_64-20131205.box"
  end

  config.vm.define "centos5" do |centos5|
    centos5.vm.box = "centos58"
    centos5.vm.box_url = "https://dl.dropbox.com/u/17738575/CentOS-5.8-x86_64.box"
  end

  config.vm.define "wheezy" do |wheezy|
    wheezy.vm.box = "wheezy"
    wheezy.vm.box_url = "http://downloads.shadoware.org/wheezy64.box"
  end
  
end
