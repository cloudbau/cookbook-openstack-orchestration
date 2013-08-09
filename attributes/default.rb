default[:heat][:git_repository] = "git://github.com/openstack/heat.git"
default[:heat][:git_revision] = "master"

default[:heat][:auth_host] = "127.0.0.1"
default[:heat][:auth_port] = "35357"
default[:heat][:auth_protocol] = "http"
default[:heat][:auth_uri] = "http://127.0.0.1:5000/v2.0"
default[:heat][:admin_tenant_name] = "service"
default[:heat][:admin_user] = "heat"
default[:heat][:admin_password] = "badpassword"
default[:heat][:auth_encryption_key] = nil

default[:heat][:user] = "heat"
default[:heat][:group] = "heat"

# TODO add more platforms
case platform
when "ubuntu"
  default[:heat][:platform] = {
    :dependencies => %w{
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
      python-pip
    },
    :service_provider => Chef::Provider::Service::Upstart,
    :service_template_source => 'heat.upstart.erb'
  }
end
