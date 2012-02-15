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

def get_distro
  if platform? [ "centos","redhat","fedora"]
    package "redhat-lsb"
    "el"
  else
    "debian"
  end
end

def get_resource_hash(resource)
  require 'pathname'
  resource_h = Hash.new
  catalina_parent = Pathname.new(node['tomcat']['home']).parent.to_s
  resource_h['name'] = resource.name
  resource_h['base'] = "#{catalina_parent}/#{resource_h['name']}"
  resource_h['context_dir'] = "#{resource_h['base']}/conf/Catalina/localhost"
  resource_h['log_dir'] = "#{resource_h['base']}/logs"
  resource_h['tmp_dir'] = "#{resource_h['base']}/temp"
  resource_h['work_dir'] = "#{resource_h['base']}/work"
  resource_h['webapp_dir'] = "#{resource_h['base']}/webapps"
  resource_h['pid_file'] = "#{resource_h['name']}.pid"
  resource_h['use_security_manager'] = node['tomcat']['use_security_manager']
  resource_h['user'] = resource.user
  resource_h['group'] = resource.user
  resource_h['port'] = resource.port
  resource_h['ajp_port'] = resource.ajp_port
  resource_h['ssl_port'] = resource.ssl_port
  resource_h['shutdown_port'] = resource.shutdown_port
  resource_h['jvm_opts'] = resource.jvm_opts
  resource_h['jmx_opts'] = resource.jmx_opts
  resource_h['webapp_opts'] = resource.webapp_opts
  resource_h['more_opts'] = resource.more_opts
  resource_h
end
  
action :install do
  distro = get_distro

  resource_h = get_resource_hash new_resource

  Chef::Log.debug("#{resource_h}")

  u = user resource_h['user'] do
    action :nothing
  end
  u.run_action(:create)

  d = directory resource_h['base'] do
    owner resource_h['user']
    group resource_h['user']
    mode 0775
    action :nothing
  end
  d.run_action(:create)
  
  %w{ common conf logs server shared temp webapps work }.each do |dir|
    d = directory "#{resource_h['base']}/#{dir}" do
      owner resource_h['user']
      group resource_h['user']
      mode 0775
      action :nothing
    end
    d.run_action(:create)
  end
  
  t_init = template new_resource.name do
    cookbook "tomcat"
    path "/etc/init.d/#{new_resource.name}"
    source "tomcat.init.#{distro}.erb"
    owner "root"
    group "root"
    mode "0774"
    variables( :name => new_resource.name )
    action :nothing
  end
  t_init.run_action(:create)
  
  t_default = template "/etc/default/#{new_resource.name}" do
    cookbook "tomcat"
    source "default_tomcat.erb"
    owner "root"
    group "root"
    variables(:tomcat => resource_h)
    mode "0644"
    action :nothing
  end
  t_default.run_action(:create)

  t_server_xml = template "#{resource_h['base']}/conf/server.xml" do
    cookbook "tomcat"
    source "server.tomcat#{node['tomcat']['version']}.xml.erb"
    owner "#{resource_h['user']}"
    group "#{resource_h['user']}"
    variables(:tomcat => resource_h)
    mode "0644"
    action :nothing
  end
  t_server_xml.run_action(:create)

  s = service new_resource.name do
    service_name new_resource.name
    supports :restart => true, :reload => true, :status => true
    action :nothing
  end
  s.run_action(:enable)
  s.run_action(:start)

  # we can't notify a service until after it has been created
# t_init.notifies( :restart,
#                   resources(:service => resource_h['name']) )
#  t_server_xml.notifies( :restart,
 #                        t_server_xml.resources(:service => new_resource.name) ) 
 # t_default.notifies( :restart, resources(:service => new_resource.name) ) 
  
end


action :remove do
  
end
