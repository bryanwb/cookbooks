#
# Cookbook Name:: users
# Recipe:: hudson
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

hudson_user = "hudson"

# find all members of the hudson group, so we can make them members
hudson_members = Array.new
hudson_members << hudson_user

search(:users, "groups:hudson").each do |u|
  hudson_members << u.id
end

# create user
user hudson_user

ruby_block "find_local_users" do
  block do
    local_users = Array.new
    node['etc']['passwd'].each do |name,values|
      local_users << name
    end
    hudson_members = hudson_members & local_users
  end
  action :create
end

group hudson_user do
  members hudson_members
  action :modify
end

# add sudoers
sudo hudson_user do
  template "app.erb"
  variables(
            {
              "name" => hudson_user,
              "service" => hudson_user
            }
            )
end
