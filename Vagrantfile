# -*- mode: ruby -*
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  vms = {
    :app1 => {
      :hostname  => 'app-server1',
      :ip        => '172.31.10.100',
      :ssh_port  => 22100,
      :http_port => 8080,
      :type      => 'server',
      :web       => 'true',
    },
    :app2 => {
      :hostname  => 'app-server2',
      :ip        => '172.31.10.101',
      :ssh_port  => 22101,
      :http_port => 8081,
      :type      => 'client',
      :web       => 'false',
    }
  }

  vms.each do |vm, params|
    config.vm.define vm do |cfg|
      cfg.vm.box = "consulbase"
      cfg.vm.box_url = "https://github.com/2creatives/vagrant-centos/releases/download/v6.4.2/centos64-x86_64-20140116.box"

      cfg.vm.hostname = params[:hostname]
      cfg.vm.network "private_network", ip: params[:ip]
      cfg.vm.network "forwarded_port", guest: 22, host: params[:ssh_port], id: "ssh"
      cfg.vm.network "forwarded_port", guest: 80, host: params[:http_port], id: "web"

      cfg.vm.synced_folder ".", "/tmp/bootstrap"

      cfg.vm.provision :shell do |shell|
        shell.path = "init/bootstrap.sh"
        shell.args = [ params[:type], params[:web] ]
      end
    end
  end
end