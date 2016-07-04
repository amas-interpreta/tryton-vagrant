# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "xcoo/xenial64"
  config.vm.network "private_network", ip: "192.168.33.10"
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
  end
  config.vm.provider :aws do |aws, override|
    override.ssh.username = "ubuntu"
    override.ssh.private_key_path = "~/.aws/msistemas_aws.pem"
    aws.ami = "ami-a4d44ed7"
    aws.instance_type = "t2.micro"
    aws.keypair_name = "msistemas_aws"
  end
  config.vm.provision "shell", path: "install.sh"
end
