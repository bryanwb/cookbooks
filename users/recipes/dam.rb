#
# Cookbook Name:: users
# Recipe:: dam
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

dam_user = "dam"

# find all members of the dam group, so we can make them members
dam_members = Array.new
dam_members << dam_user

search(:users, "groups:dam").each do |u|
  dam_members << u.id
end

# create user
user dam_user

ruby_block "find_local_users" do
  block do
    local_users = Array.new
    node['etc']['passwd'].each do |name,values|
      local_users << name
    end
    dam_members = dam_members & local_users
  end
  action :create
end

group dam_user do
  # find all users that currently exist on the machine
  # then only add those dam_members that already have
  # user accounts
   members dam_members
  action :modify
end

# add sudoers
sudo dam_user do
  template "app.erb"
  variables(
            {
              "name" => dam_user,
              "service" => dam_user
            }
            )
end

