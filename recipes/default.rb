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

# TODO: Use apt recipe 
bash "force apt update" do
  code "apt-get update"
end

include_recipe "mysql::server"
include_recipe "rabbitmq::default"

%w{
  libxml2-dev 
  libxslt-dev  
  python-mysqldb
  git
  python2.7
  python-setuptools
  python-qpid
  python-dev
  libxml2-dev
  libxslt-dev
}.each do |pkg|
  package pkg do
    action :install
  end
end

git "heat" do
  repository node[:heat][:git_repository]
  reference node[:heat][:git_revision]
  destination "/tmp/heat"
  action :sync
  notifies :run, "bash[install_heat]"
end

bash "install_heat" do
  code "cd /tmp/heat && ./install.sh"
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
end

bash "setup heat db" do
  code "heat-db-setup deb -r #{node[:mysql][:server_root_password]}"
end

# Start the services
# TODO: Use service manager like upstart or runit for this
bash "start heat engine" do
  code "heat-engine &"
end

bash "start heat-api" do
  code "heat-api &"
end

bash "start heat-api-cfn" do
  code "heat-api-cfn &"
end

bash "start heat-api-cloudwatch" do
  code "heat-api-cloudwatch &"
end
