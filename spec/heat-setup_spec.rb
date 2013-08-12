require_relative "./spec_helper"

MYSQL_ATTRIBS = {
    "server_debian_password" => "server-debian-password",
    "server_root_password" => "server-root-password",
    "server_repl_password" => "server-repl-password"
}

describe "openstack-orchestration::default" do

  before do
    @chef_run = ::ChefSpec::ChefRunner.new ::UBUNTU_OPTS do |n|
      # The mysql cookbook will raise an "uninitialized constant
      # Chef::Application" error without this attribute when running
      # the tests
      n["mysql"] = MYSQL_ATTRIBS
      n["heat"] = { 
        "auth_encryption_key" => "random-key",
        "user" => "heat",
        "group" => "heat"
      }
    end
    @chef_run.converge "openstack-orchestration::default"
  end

  it "uses mysql database server recipe by default" do
    expect(@chef_run).to include_recipe "mysql::server"
  end

  it "uses rabbitmq::default recipe by default" do
    expect(@chef_run).to include_recipe "rabbitmq::default"
  end

  %w{ api api-cloudwatch api-cfn engine }.each do |srv|
    it "should have rabbit rpc configured" do
      file = @chef_run.template "/etc/heat/heat-#{srv}.conf"
      expect(@chef_run).to create_file_with_content "/etc/heat/heat-#{srv}.conf",
        "rpc_backend=heat.openstack.common.rpc.impl_kombu"
    end
  end

  %w{ metadata waitcondition watch }.each do |heatsrv|
    it "should include the node[:ipaddress] for #{heatsrv} in heat-engine.conf" do
      expect(@chef_run).to create_file_with_content "/etc/heat/heat-engine.conf",
        /heat_#{heatsrv}_server_url = .*10\.0\.0\.2/ # fauxhai's node[ipaddress] for Ubuntu 12.04
    end
  end

  %w{ metadata waitcondition watch }.each do |heatsrv|
    it "should prefer the node[:heat][:public_ip] for #{heatsrv} in heat-engine.conf" do
      chef_run = ::ChefSpec::ChefRunner.new ::UBUNTU_OPTS do |n|
        n.set["mysql"] = MYSQL_ATTRIBS
        n.set["heat"]["public_ip"] = "1.2.3.4"
      end
      chef_run.converge "openstack-orchestration::default"
      chef_run.should create_file_with_content "/etc/heat/heat-engine.conf",
        /heat_#{heatsrv}_server_url = .*1\.2\.3\.4/
    end
  end

  %w{ metadata waitcondition watch }.each do |heatsrv|
    it "should prefer the node[:cloud][:public_ipv4] for #{heatsrv} in heat-engine.conf" do
      chef_run = ::ChefSpec::ChefRunner.new ::UBUNTU_OPTS do |n|
        n.set["mysql"] = MYSQL_ATTRIBS
        n.set["cloud"] = { "public_ipv4" => "4.3.2.1" }
      end
      chef_run.converge described_recipe
      chef_run.should create_file_with_content "/etc/heat/heat-engine.conf",
        /heat_#{heatsrv}_server_url = .*4\.3\.2\.1/
    end
  end

  %w{ metadata waitcondition watch }.each do |heatsrv|
    it "should prefer the node[:heat][:public_ip] over  node[:cloud][:public_ip4] for #{heatsrv} in heat-engine.conf" do
      chef_run = ::ChefSpec::ChefRunner.new ::UBUNTU_OPTS do |n|
        n.set["mysql"] = MYSQL_ATTRIBS
        n.set["heat"]["public_ip"] = "1.2.3.4"
        n.set["cloud"]["public_ip4"] = "4.3.2.1"
      end
      chef_run.converge described_recipe
      chef_run.should create_file_with_content "/etc/heat/heat-engine.conf",
        /heat_#{heatsrv}_server_url = .*1\.2\.3\.4/
    end
  end





  it "should include the auth_encryption_key in heat-engine.conf" do
    expect(@chef_run).to create_file_with_content "/etc/heat/heat-engine.conf",
      'auth_encryption_key=random-key'
  end

end
