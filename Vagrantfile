require 'yaml'
require 'vagrant-openstack-plugin' if ENV['USE_OS'] == 'true'

config_yml = YAML.load(File.read('config.yml'))

Vagrant.configure("2") do |config|
  config.berkshelf.enabled = true
  if ENV['USE_OS'] == 'true'
    config.vm.box = "dummy"
    config.vm.box_url = "https://github.com/cloudbau/vagrant-openstack/raw/master/dummy.box"
    config.ssh.private_key_path = "#{ENV['HOME']}/.ssh/id_rsa"
    
    config.vm.provider :openstack do |os|
        os.username = config_yml['os_username']
        os.api_key  = config_yml['os_password']
        os.flavor   = /m1.small/
        os.image    = /Ubuntu-Vagrant/
        os.endpoint = config_yml['os_endpoint']
        os.ssh_username = "root"
        os.keypair_name = config_yml['os_keypair']
    end
  else
    config.vm.box = "precise64"
    #  config.vm.box_url = "https://dl.dropbox.com/u/31081437/Berkshelf-CentOS-6.3-x86_64-minimal.box"
  end

  config.ssh.max_tries = 40
  config.ssh.timeout   = 120

  config.vm.provision :chef_solo do |chef|
    chef.json = {
      :mysql => {
        :server_root_password => 'secretroot',
        :server_debian_password => 'secretdeb',
        :server_repl_password => 'secretrepl'
      },
      :heat => {
        :auth_host => config_yml['os_keystone_host'],
        :auth_port => "35357",
        :auth_protocol => "http",
        :auth_uri => "http://#{config_yml['os_keystone_host']}:5000/v2.0",
        :admin_tenant_name => "service",
        :admin_user => config_yml['heat_keystone_user'],
        :admin_password => config_yml['heat_keystone_pass']
      }
    }
    chef.run_list = [
      "recipe[cookbook-openstack-orchestration::default]"
    ]
  end
end
