# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "precise64"





  config.vm.define :server1 do |server|
    server.vm.hostname = "server1"
    server.vm.box      = "precise64"
    server.vm.provision :shell, :path => "shell/bootstrap.sh"
    server.vm.network :private_network, ip: "192.168.33.10"
  end

  config.vm.define :server2 do |server|
    server.vm.hostname = "server2"
    server.vm.box      = "precise64"
    server.vm.provision :shell, :path => "shell/bootstrap.sh"
    server.vm.network :private_network, ip: "192.168.33.11"
  end



  # config.vm.network :forwarded_port, guest: 80, host: 8080
  # config.vm.network :private_network, ip: "192.168.33.10"
  # config.vm.network :public_network
  # config.ssh.forward_agent = true
  # config.vm.synced_folder "../data", "/vagrant_data"

  # config.vm.provider :virtualbox do |vb|
  #   # Don't boot with headless mode
  #   vb.gui = true
  #
  #   # Use VBoxManage to customize the VM. For example to change memory:
  #   vb.customize ["modifyvm", :id, "--memory", "1024"]
  # end

  # config.vm.network :forwarded_port, {:guest => 4567, :host => 4567, :id => "dashboard", :auto_correct => true}
  # config.vm.network :forwarded_port, {:guest => 5555, :host => 5555, :id => "riemann", :auto_correct => true, :protocol => "udp"}
  # config.vm.provision :shell, :path => "shell/bootstrap.sh"
end
