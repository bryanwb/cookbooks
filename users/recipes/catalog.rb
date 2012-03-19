#
# Cookbook Name:: users
# Recipe:: catalog
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

catalog_user = "catalog"

# find all members of the catalog group, so we can make them members
catalog_members = Array.new
catalog_members << catalog_user

search(:users, "groups:catalog").each do |u|
  catalog_members << u.id
end

# create user
user catalog_user

ruby_block "find_local_users" do
  block do
    local_users = Array.new
    node['etc']['passwd'].each do |name,values|
      local_users << name
    end
    catalog_members = catalog_members & local_users
  end
  action :create
end

group catalog_user do
  members catalog_members
  action :modify
end

# add sudoers
sudo catalog_user do
  template "app.erb"
  variables(
            {
              "name" => catalog_user,
              "service" => catalog_user
            }
            )
end
