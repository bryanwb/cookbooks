#
# Cookbook Name:: users
# Recipe:: jboss
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

jboss_user = "jboss"

# find all members of the jboss group, so we can make them members
jboss_members = Array.new
jboss_members << jboss_user

search(:users, "groups:jboss").each do |u|
  jboss_members << u.id
end

# create user
user jboss_user

ruby_block "find_local_users" do
  block do
    local_users = Array.new
    node['etc']['passwd'].each do |name,values|
      local_users << name
    end
    jboss_members = jboss_members & local_users
  end
  action :create
end

group jboss_user do
   members jboss_members
  action :modify
end

# add sudoers
sudo jboss_user do
  template "app.erb"
  variables(
            {
              "name" => jboss_user,
              "service" => jboss_user
            }
            )
end
