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

# get the postgres jdbc driver
maven 'postgresql' do
  groupId 'postgresql'
  version '9.0-801.jdbc4'
  dest "#{jboss_home}/modules/org/postgresql"
  owner jboss_user
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
