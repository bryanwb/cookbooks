#
# Cookbook Name:: jboss
# Recipe:: _load_app_params
# Author:: Bryan W. Berry (<bryan.berry@gmail.com>)
# Copyright 2012, Food and Agriculture Organization of the United Nations
#
# license Apache v2.0
#

ruby_block "set jdbc parameters" do
  block do
    app_name = node['jboss']['application']

    db = data_bag_item("apps", app_name)[node['app_env']]
    Chef::Log.debug("application name is #{app_name} and env is #{node['app_env']}")
    Chef::Log.debug("databag contents are #{db.inspect}")
    node['jboss']['java_opts'] = db['java_opts']
    node['jboss']['jdbc']['schema'] = db['jdbc']['schema']
    node['jboss']['jdbc']['user'] = db['jdbc']['user']
    node['jboss']['jdbc']['host'] = db['jdbc']['host']
  end
end
