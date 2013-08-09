#
# Cookbook Name:: cookbook-openstack-orchestration
# Recipe:: default
#
# Copyright (C) 2013 cloudbau GmbH
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# 

include_recipe "apt"
resources(:execute => 'apt-get update').run_action(:run)

include_recipe "mysql::server"
include_recipe "rabbitmq::default"

node[:heat][:platform][:dependencies].each do |pkg|
  package pkg do
    action :install
  end
end

# needed by heat's setup.py
python_pip "pbr"

git "heat" do
  repository node[:heat][:git_repository]
  reference node[:heat][:git_revision]
  destination "/tmp/heat"
  action :sync
  notifies :run, "bash[install_heat]"
end

# needs python-pip
bash "install_heat" do
  code "cd /tmp/heat && ./install.sh"
  action :nothing
end


template "/etc/heat/heat-api.conf" do 
  source "heat-api.conf.erb"
  variables({
    :rpc_backend => "heat.openstack.common.rpc.impl_kombu",
    :auth_host => node[:heat][:auth_host],
    :auth_port => node[:heat][:auth_port],
    :auth_protocol => node[:heat][:auth_protocol],
    :auth_uri => node[:heat][:auth_uri],
    :admin_tenant_name => node[:heat][:admin_tenant_name],
    :admin_user => node[:heat][:admin_user],
    :admin_password => node[:heat][:admin_password]
    })
  notifies :restart, 'service[heat-api]', :delayed
end

template "/etc/heat/heat-api-cloudwatch.conf" do 
  source "heat-api-cloudwatch.conf.erb"
  variables({
    :rpc_backend => "heat.openstack.common.rpc.impl_kombu",
    :auth_host => node[:heat][:auth_host],
    :auth_port => node[:heat][:auth_port],
    :auth_protocol => node[:heat][:auth_protocol],
    :auth_uri => node[:heat][:auth_uri],
    :admin_tenant_name => node[:heat][:admin_tenant_name],
    :admin_user => node[:heat][:admin_user],
    :admin_password => node[:heat][:admin_password]
    })
  notifies :restart, 'service[heat-api-cloudwatch]', :delayed
end

template "/etc/heat/heat-api-cfn.conf" do
  source "heat-api-cfn.conf.erb"
  variables({
    :rpc_backend => "heat.openstack.common.rpc.impl_kombu",
    :auth_host => node[:heat][:auth_host],
    :auth_port => node[:heat][:auth_port],
    :auth_protocol => node[:heat][:auth_protocol],
    :auth_uri => node[:heat][:auth_uri],
    :admin_tenant_name => node[:heat][:admin_tenant_name],
    :admin_user => node[:heat][:admin_user],
    :admin_password => node[:heat][:admin_password]
    })
  notifies :restart, 'service[heat-api-cfn]', :delayed
end

if node[:cloud]
  public_ip = node[:heat][:public_ip] || node[:cloud][:public_ipv4] 
else
  public_ip = node[:heat][:public_ip] || node[:ipaddress]
end

template "/etc/heat/heat-engine.conf" do
  source "heat-engine.conf.erb"
  variables({
    :rpc_backend => "heat.openstack.common.rpc.impl_kombu",
    :watch_server_url => "http://#{public_ip}:8003",
    :waitcondition_server_url => "http://#{public_ip}:8000/v1/waitcondition",
    :metadata_server_url => "http://#{public_ip}:8000",
    :auth_encryption_key => node[:heat][:auth_encryption_key]
    })
  notifies :restart, 'service[heat-engine]', :delayed
end

bash "setup heat db" do
  code "heat-db-setup deb -r #{node[:mysql][:server_root_password]}"
end

# create and start the services
%w{ heat-engine heat-api heat-api-cfn heat-api-cloudwatch }.each do |srv|
  service_factory srv do
    service_desc "#{srv} service"
    exec "/usr/local/bin/#{srv}"
    run_user "root"
    run_group "root"
    action :create # https://github.com/org-binbab/cookbook-service_factory/issues/2
  end

  service srv do
    provider node[:heat][:platform][:service_provider]
    action [:enable, :start]
  end

end
