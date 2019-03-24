Vagrant.configure("2") do |config|
  ## Choose your base box
  config.vm.box = "ubuntu/bionic64"
  config.vm.provider "virtualbox" do |v|
    v.memory = 512
    v.cpus = 2
  end

  ## For masterless, mount your salt file root
  config.vm.synced_folder "salt/", "/srv/salt/", SharedFoldersEnableSymlinksCreate: false
  config.vm.synced_folder "pillar/", "/srv/pillar/", SharedFoldersEnableSymlinksCreate: false

  config.vm.provision :salt do |salt|
    salt.masterless = true
    salt.minion_config = "salt/minion"
    salt.run_highstate = true
    salt.log_level = "info"
    salt.verbose = true
  end

end
