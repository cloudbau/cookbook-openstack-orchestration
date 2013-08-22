#
# Cookbook Name:: openstack-orchestration
# Recipe:: identity_registration
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

if node[:cloud]
  public_ip = node[:heat][:public_ip] || node[:cloud][:public_ipv4]
else
  public_ip = node[:heat][:public_ip] || node[:ipaddress]
end

openstack_identity_register "Register Service Tenant" do
  auth_uri node[:heat][:auth_uri]
  bootstrap_token node[:heat][:admin_token]
  tenant_name node[:heat][:admin_tenant_name]
  tenant_description "Service Tenant"

  action :create_tenant
end

openstack_identity_register "Register Heat User" do
  auth_uri node[:heat][:auth_uri]
  bootstrap_token node[:heat][:admin_token]
  tenant_name node[:heat][:admin_tenant_name]
  user_name node[:heat][:admin_user]
  user_pass node[:heat][:admin_password]

  action :create_user
end

openstack_identity_register "Register Heat Cloudformation API Service" do
  auth_uri node[:heat][:auth_uri]
  bootstrap_token node[:heat][:admin_token]
  # service_name 'OpenStack Orchestration Cloudformation Service'
  service_name 'heat'
  service_type 'cloudformation'
  service_description "OpenStack Orchestration Cloudformation Service"

  action :create_service
end

openstack_identity_register "Grant 'admin' Role to heat User for service Tenant" do
  auth_uri node[:heat][:auth_uri]
  bootstrap_token node[:heat][:admin_token]
  tenant_name node[:heat][:admin_tenant_name]
  user_name node[:heat][:admin_user]
  role_name 'admin'

  action :grant_role
end

openstack_identity_register "Register Heat API Service" do
  auth_uri node[:heat][:auth_uri]
  bootstrap_token node[:heat][:admin_token]
  # service_name 'OpenStack Orchestration Service'
  service_name 'heat'
  service_type 'orchestration'
  service_description "OpenStack Orchestration Service"

  action :create_service
end

openstack_identity_register "Register Heat Endpoint" do
  auth_uri node[:heat][:auth_uri]
  bootstrap_token node[:heat][:admin_token]
  service_name 'heat'
  service_type 'orchestration'
  endpoint_region 'RegionOne'
  endpoint_adminurl "http://#{public_ip}:8004/v1/%(tenant_id)s"
  endpoint_internalurl "http://#{public_ip}:8004/v1/%(tenant_id)s"
  endpoint_publicurl "http://#{public_ip}:8004/v1/%(tenant_id)s"

  action :create_endpoint
end

openstack_identity_register "Register Heat Cloudformation Endpoint" do
  auth_uri node[:heat][:auth_uri]
  bootstrap_token node[:heat][:admin_token]
  service_name 'heat'
  service_type 'cloudformation'
  # service_name 'cloudformation'
  endpoint_region 'RegionOne'
  endpoint_adminurl "http://#{public_ip}:8000/v1"
  endpoint_internalurl "http://#{public_ip}:8000/v1"
  endpoint_publicurl "http://#{public_ip}:8000/v1"

  action :create_endpoint
end

