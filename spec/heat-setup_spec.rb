require "spec_helper"

describe "openstack-orchestration::default" do
  
  before do
    @chef_run = ::ChefSpec::ChefRunner.new ::UBUNTU_OPTS
    @chef_run.converge "openstack-orchestration::default"
  end

  it "runs mysql recipe" do
    expect(@chef_run).to include_recipe "mysql::server"
  end

  it "runs rabbit recipe" do
    expect(@chef_run).to include_recipe "rabbitmq::default"
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


