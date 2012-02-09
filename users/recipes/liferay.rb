#
# Cookbook Name:: users
# Recipe:: liferay
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

include_recipe "sudo"

liferay_user = "liferay"

# find all members of the liferay group, so we can make them members
liferay_members = Array.new
liferay_members << liferay_user

search(:users, "groups:liferay").each do |u|
  liferay_members << u.id
end

# create user
user liferay_user

ruby_block "find_local_users" do
  block do
    local_users = Array.new
    node['etc']['passwd'].each do |name,values|
      local_users << name
    end
    liferay_members = liferay_members & local_users
  end
  action :create
end

group liferay_user do
  # find all users that currently exist on the machine
  # then only add those liferay_members that already have
  # user accounts
  local_users = Array.new
  node['etc']['passwd'].each do |name,values|
    local_users << name
  end
  liferay_members = liferay_members & local_users
  members liferay_members
  action :modify
end

# add sudoers
sudo liferay_user do
  template "app.erb"
  variables(
            {
              "name" => liferay_user,
              "service" => liferay_user
            }
            )
end


