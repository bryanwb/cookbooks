#
# Cookbook Name:: jboss
# Recipe:: esb
#
# Copyright 2012, Food and Agriculture Organization of the United Nations
#
# license Apache v2.0
#

include_recipe "java::oracle"
include_recipe "maven"

jboss_home = node['jboss']['home']
jboss_user = node['jboss']['user']

bag, item = node['jboss']['jdbc']['passwd_data_bag'].split('/')
password = Chef::EncryptedDataBagItem.load(bag, item)['passwd']


# create user
user node['jboss']['user']
group node['jboss']['user']

ark 'jboss' do
  release_url node['jboss']['url']
  checksum node['jboss']['checksum']
  home_dir jboss_home
  version "7.1.0"
  user jboss_user
end

# template environment variables used by init file
template "/etc/default/#{jboss_user}" do
  source "default.erb"
  mode "0755"
end

# template init file
template "/etc/init.d/#{jboss_user}" do
  if platform? ["centos", "redhat"] 
    source "init_standalone_el.erb"
  else
    source "init_deb.erb"
  end
  mode "0755"
  owner "root"
  group "root"
end

# get the jdbc driver
if node['jboss']['jdbc']['driver']['name'] != 'h2'
  maven node['jboss']['jdbc']['driver']['name'] do
    groupId node['jboss']['jdbc']['driver']['name'] 
    version  node['jboss']['jdbc']['driver']['version']
    dest "#{jboss_home}/modules/org/#{node['jboss']['jdbc']['driver']['name']}/main"
    owner jboss_user
  end
  # jboss needs module.xml that matches the jdbc driver
  template "#{jboss_home}/modules/org/#{node['jboss']['jdbc']['driver']['name']}/main/module.xml" do
    source "#{node['jboss']['jdbc']['driver']['name']}.module.xml.erb"
    owner jboss_user
  end
end



template "#{jboss_home}/standalone/configuration/standalone.xml" do
  source 'standalone.xml.erb'
  variables( :password => password )
  owner jboss_user
end

# start service
service jboss_user do
  subscribes :restart, resources( :template => "#{jboss_home}/standalone/configuration/standalone.xml"), :immediately
  action [ :enable, :start ]
end
