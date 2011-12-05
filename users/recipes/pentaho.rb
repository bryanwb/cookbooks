#
# Cookbook Name:: users
# Recipe:: pentaho
#
# Copyright 2009-2011, Opscode, Inc.
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

pentaho_user = "pentaho"

# find all members of the pentaho group, so we can make them members
pentaho_members = Array.new
pentaho_members << pentaho_user

search(:users, "groups:pentaho").each do |u|
  pentaho_members << u.id
end

# create user
user pentaho_user

ruby_block "find_local_users" do
  block do
    local_users = Array.new
    node['etc']['passwd'].each do |name,values|
      local_users << name
    end
    pentaho_members = pentaho_members & local_users
  end
  action :create
end

group pentaho_user do
  # find all users that currently exist on the machine
  # then only add those pentaho_members that already have
  # user accounts
  local_users = Array.new
  node['etc']['passwd'].each do |name,values|
    local_users << name
  end
  pentaho_members = pentaho_members & local_users
  members pentaho_members
  action :modify
end

# add sudoers
template "/etc/sudoers.d/pentaho" do
  source "app_sudoers.erb"
  variables ({ :user => pentaho_user, :service => pentaho_user })
  mode 0440
  owner "root"
  group "root"
end


