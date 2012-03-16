#
# Cookbook Name:: jboss
# Recipe:: _jdbc_password
# Author:: Bryan W. Berry (<bryan.berry@gmail.com>)
# Copyright 2012, Food and Agriculture Organization of the United Nations
#
# license Apache v2.0
#

app_name = node['jboss']['application']
app_env = node['app_env']

# get password
bag, item = node[:passwd_data_bag].split('/')
db = Chef::EncryptedDataBagItem.load(bag, item)
node['jboss']['jdbc']['password'] = db[app_name][app_env]['jdbc']

