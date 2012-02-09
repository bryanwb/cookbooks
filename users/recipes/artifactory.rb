#
# Cookbook Name:: users
# Recipe:: artifactory
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

artifactory_user = "artifactory"

# find all members of the artifactory group, so we can make them members
artifactory_members = Array.new
artifactory_members << artifactory_user

search(:users, "groups:artifactory").each do |u|
  artifactory_members << u.id
end

# create user
user artifactory_user

ruby_block "find_local_users" do
  block do
    local_users = Array.new
    node['etc']['passwd'].each do |name,values|
      local_users << name
    end
    artifactory_members = artifactory_members & local_users
  end
  action :create
end

group artifactory_user do
  members artifactory_members
  action :modify
end

# add sudoers
sudo artifactory_user do
  template "app.erb"
  variables(
            {
              "name" => artifactory_user,
              "service" => artifactory_user
            }
            )
end
