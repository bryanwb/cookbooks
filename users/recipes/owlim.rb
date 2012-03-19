#
# Cookbook Name:: users
# Recipe:: owlim
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

owlim_user = "owlim"

# find all members of the owlim group, so we can make them members
owlim_members = Array.new
owlim_members << owlim_user

search(:users, "groups:owlim").each do |u|
  owlim_members << u.id
end

# create user
user owlim_user

ruby_block "find_local_users" do
  block do
    local_users = Array.new
    node['etc']['passwd'].each do |name,values|
      local_users << name
    end
    owlim_members = owlim_members & local_users
  end
  action :create
end

group owlim_user do
  members owlim_members
  action :modify
end

# add sudoers
sudo owlim_user do
  template "app.erb"
  variables(
            {
              "name" => owlim_user,
              "service" => owlim_user
            }
            )
end
