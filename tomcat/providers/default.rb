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

def update_resource(resource)
  require 'pathname'
  catalina_parent = Pathname.new(node['tomcat']['home']).parent.to_s
  resource.base = "#{catalina_parent}/#{resource.name}"
  resource.context_dir = "#{resource.base}/conf/Catalina/localhost"
  resource.log_dir = "#{resource.base}/logs"
  resource.tmp_dir = "#{resource.base}/temp"
  resource.work_dir = "#{resource.base}/work"
  resource.webapp_dir = "#{resource.base}/webapps"
  resource.pid_file = "#{resource.name}.pid"
  resource.use_security_manager = node['tomcat']['use_security_manager']
  resource.group = resource.owner
end
  
action :install do
  distro = get_distro

  update_resource new_resource

  Chef::Log.debug("#{new_resource.to_hash}")

  u = user new_resource.owner do
    action :nothing
  end
  u.run_action(:create)

  d = directory new_resource.base do
    owner new_resource.owner
    group new_resource.owner
    mode 0775
    action :nothing
  end
  d.run_action(:create)
  
  %w{ common conf logs server shared temp webapps work }.each do |dir|
    d = directory "#{new_resource.base}/#{dir}" do
      owner new_resource.owner
      group new_resource.owner
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
    variables(:tomcat => new_resource.to_hash)
    mode "0644"
    action :nothing
  end
  t_default.run_action(:create)

  t_server_xml = template "#{new_resource.base}/conf/server.xml" do
    cookbook "tomcat"
    source "server.tomcat#{node['tomcat']['version']}.xml.erb"
    owner "#{new_resource.owner}"
    group "#{new_resource.owner}"
    variables(:tomcat => new_resource.to_hash)
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
#  t_init.notifies( :restart, resources(:service => new_resource.name) )
#  t_server_xml.notifies( :restart, resources(:service => new_resource.name) ) 
#  t_default.notifies( :restart, resources(:service => new_resource.name) ) 
  
end


action :remove do
  
end
