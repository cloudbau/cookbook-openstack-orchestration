require_relative "./spec_helper"

describe "openstack-orchestration::default" do

  before do
    @chef_run = ::ChefSpec::ChefRunner.new ::UBUNTU_OPTS do |n|
      # The mysql cookbook will raise an "uninitialized constant
      # Chef::Application" error without this attribute when running
      # the tests
      n.set["mysql"] = {
        "server_debian_password" => "server-debian-password",
        "server_root_password" => "server-root-password",
        "server_repl_password" => "server-repl-password"
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

  describe "heat-engine.conf" do
    it "is" do
      chef_run = ::ChefSpec::ChefRunner.new(::UBUNTU_OPTS)
      chef_run.converge "openstack-orchestration::default"
    end
  end

  describe "heat-api.conf" do
    before do
      @file = @chef_run.template "/etc/heat/heat-api.conf"
    end
  end

  describe "heat-api-cloudwatch.conf" do
    before do
      @file = @chef_run.template "/etc/heat/heat-api-cloudwatch.conf"
    end
  end

  describe "heat-api-cfn.conf" do
    before do
      @file = @chef_run.template "/etc/heat/heat-api-cfn.conf"
    end

    it "should have rabbit rpc configured" do
      expect(@chef_run).to create_file_with_content "/etc/heat/heat-api-cfn.conf",
        "rpc_backend=heat.openstack.common.rpc.impl_kombu"
    end
  end

end
