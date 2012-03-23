#
# Cookbook Name:: users
# Recipe:: as
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

as_user = "as"

# find all members of the as group, so we can make them members
as_members = Array.new
as_members << as_user

search(:users, "groups:as").each do |u|
  as_members << u.id
end

# create user
user as_user

ruby_block "find_local_users" do
  block do
    local_users = Array.new
    node['etc']['passwd'].each do |name,values|
      local_users << name
    end
    as_members = as_members & local_users
  end
  action :create
end

group as_user do
  members as_members
  action :modify
end

# add sudoers
sudo as_user do
  template "app.erb"
  variables(
            {
              "name" => as_user,
              "service" => as_user
            }
            )
end
