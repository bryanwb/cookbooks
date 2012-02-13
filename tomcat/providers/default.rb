#
# Author:: Bryan W. Berry (<bryan.berry@gmail.com>)
# Cookbook Name:: tomcat
# Provider:: default
#
# Copyright 2012, Bryan w. Berry
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

# checks password file to see if user already exists
def check_username!(username)
  require 'etc'
  user_exists = true
  begin 
    Etc.getpwnam(username)
  rescue ArgumentError
    user_exists = false
  end
  unless user_exists
    Chef::Application::fatal!("The user specified #{username} already exists, pick a new one")
  end
end

def get_distro
  if platform? [ "centos","redhat","fedora"]
    package "redhat-lsb"
    "el"
  else
    "debian"
  end
end

def populate_params(resource)
  require 'pathname'
  tomcat = Hash.new
  tomcat['name'] = resource.name
  tomcat['catalina_home'] = node['tomcat']['home']
  catalina_parent = Pathname.new(catalina_home).parent.to_s
  tomcat['base'] = "#{catalina_parent}/#{resource.name}"
  tomcat["context_dir"] = "#{tomcat['base']}/conf/Catalina/localhost"
  tomcat["log_dir"] = "#{tomcat['base']}/logs"
  tomcat["tmp_dir"] = "#{tomcat['base']}/temp"
  tomcat["work_dir"] = "#{tomcat['base']}/work"
  tomcat["webapp_dir"] = "#{tomcat['base']}/webapps"
  tomcat["use_security_manager"] = node['tomcat']['use_security_manager']
  tomcat["user"] = resource.user
  tomcat["group"] = resource.user
  tomcat["port"] = resource.http_port
  tomcat["ssl_port"] = resource.ssl_port
  tomcat["ajp_port"] = resource.ajp_port
  tomcat["shutdown_port"] = resource.shutdown_port
  tomcat["unpack_wars"] = resource.unpack_wars
  tomcat["auto_deploy"] = resource.auto_deploy
  tomcat["jvm_opts"] = resource.jvm_opts
  tomcat["jmx_opts"] = resource.jmx_opts
  tomcat["webapp_opts"] = resource.webapp_opts
  tomcat["more_opts"] = resource.more_opts
  tomcat
end
  
action :install do
  distro = get_distro
  tomcat = populate_params new_resource

  # if this is the first time this recipe run
  unless Dir.exists? catalina_base
    check_username! new_resource.user
    user new_resource do
      supports :manage_home => true
    end
  end

  d = directory catalina_base do
    owner new_resource.user
    group new_resource.user
    mode 0775
    action :nothing
  end
  d.run_action(:create)
  
  %w{ conf logs temp work }.each do |dir|
    d = directory "#{catalina_base}/#{dir}" do
      owner new_resource.user
      group new_resource.user
      mode 0775
      action :nothing
    end
    d.run_action(:create)
  end

  t_init = template tomcat['name'] do
    path "/etc/init.d/"
    source "tomcat.init.#{distro}.erb"
    owner "root"
    group "root"
    mode "0774"
    variables( :name => tomcat['name'] )
  end

  t_default = template "/etc/default/#{tomcat['name']}" do
    source "default_tomcat.erb"
    owner "root"
    group "root"
    variables(:tomcat => tomcat)
    mode "0644"
  end

  service tomcat['name'] do
    service_name tomcat['name']
    supports :restart => true, :reload => true, :status => true
    action [:enable, :start]
  end

  # we can't notify a service until after it has been created
  t_init.notifies :restart, resources(:service => "tomcat")
  t_default.notifies :restart, resources(:service => "tomcat")

end


action :remove do

end
