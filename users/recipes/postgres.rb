#
# Cookbook Name:: users
# Recipe:: postgres
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

postgres_user = "postgres"

# find all members of the postgres group, so we can make them members
postgres_members = Array.new
postgres_members << postgres_user

search(:users, "groups:postgres").each do |u|
  postgres_members << u.id
end

# create user
user postgres_user

ruby_block "find_local_users" do
  block do
    local_users = Array.new
    node['etc']['passwd'].each do |name,values|
      local_users << name
    end
    postgres_members = postgres_members & local_users
  end
  action :create
end

group postgres_user do
  # find all users that currently exist on the machine
  # then only add those postgres_members that already have
  # user accounts
   members postgres_members
  action :modify
end

# add sudoers
sudo_ers "postgres" do
  group postgres_user
  service "postgresql"
  pattern "app"
end
