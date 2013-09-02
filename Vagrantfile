# -*- mode: ruby -*-
# vi: set ft=ruby :
#^syntax detection

Vagrant::Config.run do |config|

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "monitor"
  # config.vm.box_url = "https://dl.dropboxusercontent.com/s/tgk7203cbbq4ust/monitor.box?token_hash=AAEQGeu3SKXvoiEJaCniY4VSkKhJ6xEaUY8xN07qZZo0-w"

  # Forward a port from the guest to the host, which allows for outside
  # computers to access the VM, whereas host only networking does not.
  config.vm.forward_port 80, 8080
  config.vm.forward_port 8125, 8125, :protocol => 'udp'
  config.vm.forward_port 8126, 8126, :protocol => 'tcp'

$script = <<SCRIPT
echo Running the setup script
su vagrant -c /vagrant/setup.rb
SCRIPT
  
	config.vm.provision :shell, :inline => $script

end

