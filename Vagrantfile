require 'yaml'
require 'vagrant-openstack-plugin' if ENV['USE_OS'] == 'true'
require 'vagrant-berkshelf'

config_yml = YAML.load(File.read('config.yml'))

require 'vagrant-omnibus' if config_yml['use_omnibus_plugin'] == true

Vagrant.configure("2") do |config|
  config.berkshelf.enabled = true
  config.omnibus.chef_version = :latest if config_yml['use_omnibus_plugin'] == true

  if ENV['USE_OS'] == 'true'
    config.vm.box = "dummy"
    config.vm.box_url = "https://github.com/cloudbau/vagrant-openstack-plugin/raw/master/dummy.box"
    config.ssh.private_key_path = config_yml['private_key_path'] || "#{ENV['HOME']}/.ssh/id_rsa"
    
    config.vm.provider :openstack do |os|
        os.username = config_yml['os_username']
        os.api_key  = config_yml['os_password']
        os.flavor   = /m1.small/
        os.image    = config_yml['os_image'] || /Ubuntu-Vagrant/
        os.network  = config_yml['os_network'] || 'default'
        os.endpoint = config_yml['os_endpoint']
        os.server_name  = config_yml['os_server_name'] || 'heat'
        os.floating_ip  = config_yml['os_floating_ip'] if config_yml['os_floating_ip']
        os.ssh_username = config_yml['os_ssh_username'] || "root"
        os.keypair_name = config_yml['os_keypair']
        os.user_data    = config_yml['os_user_data'] if config_yml['os_user_data'] 
    end
  else
    config.vm.box = "precise64"
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
        :admin_password => config_yml['heat_keystone_pass'],
        :auth_encryption_key => config_yml['heat_auth_encryption_key'],
        :public_ip => config_yml['os_floating_ip']
      }
    }
    chef.run_list = [
      "recipe[openstack-orchestration::default]"
    ]
  end
end
