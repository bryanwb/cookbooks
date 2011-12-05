#
# Cookbook Name:: users
# Recipe:: sysadmins
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

tcdr_sysadmins_group = Array.new

search(:users, 'groups:tcdr-sysadmins') do |u|
  tcdr_sysadmins_group << u['id']
  home_dir = "/home/#{u[:id]}"
  
  user u['id'] do
    if u['uid']
      uid u['uid']
    end
    shell u['shell']
    comment u['comment']
    supports :manage_home => true
    home home_dir
   end

  directory "#{home_dir}/.ssh" do
    owner u['id']
    group u['id']
    mode "0700"
  end

  template "#{home_dir}/.ssh/authorized_keys" do
    source "authorized_keys.erb"
    owner u['id']
    group u['id']
    mode "0600"
    variables :ssh_keys => u['ssh_keys']
  end
end

group "tcdr-sysadmins" do
  members tcdr_sysadmins_group
end

template "/etc/sudoers.d/tcdr-sysadmins" do
  source "sysadmins_sudoers.erb"
  variables :group_name => "tcdr-sysadmins"
  mode 0440
  owner "root"
  group "root"
end



