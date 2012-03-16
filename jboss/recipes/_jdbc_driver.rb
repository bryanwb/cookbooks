#
# Cookbook Name:: jboss
# Recipe:: _jdbc_driver
# Author:: Bryan W. Berry (<bryan.berry@gmail.com>)
# Copyright 2012, Food and Agriculture Organization of the United Nations
#
# license Apache v2.0
#


if node['jboss']['jdbc']['driver']['name'] != 'h2'
  maven node['jboss']['jdbc']['driver']['name'] do
    groupId node['jboss']['jdbc']['driver']['name'] 
    version  node['jboss']['jdbc']['driver']['version']
    dest "#{node['jboss']['home']}/modules/org/#{node['jboss']['jdbc']['driver']['name']}/main"
    owner node['jboss']['user']
  end
  # jboss needs module.xml that matches the jdbc driver
  template "#{node['jboss']['home']}/modules/org/#{node['jboss']['jdbc']['driver']['name']}/main/module.xml" do
    source "#{node['jboss']['jdbc']['driver']['name']}.module.xml.erb"
    owner node['jboss']['user']
  end
end
