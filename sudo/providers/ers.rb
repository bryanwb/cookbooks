#
# Author:: Bryan W. Berry (<bryan.berry@gmail.com>)
# Cookbook Name:: sudo
# Provider:: ers
#
# Copyright 2011, Bryan w. Berry
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


action :install do
  # if both group and user nil, throw an exception
  if new_resource.user == nil and new_resource.group == nil
    Chef::Application.fatal!("You must provide a user or a group")
  elsif new_resource.user != nil and new_resource.group != nil
    Chef::Application.fatal!("You cannot specify both a user and a group. You" +
                             " can only specify one or the other")
  end

  # should throw error if #includedir not in sudoers
  
  # create sudoers.d directory if it doesn't exist
  dir = directory "/etc/sudoers.d" do
    mode 0755
    owner "root"
    group "root"
    action :nothing
  end
  dir.run_action(:create)
  
  # create readme if it doesn't exist
  tmpl = template "/etc/sudoers.d/README" do
    cookbook "sudo"
    source "README.sudoers"
    mode 0440
    owner "root"
    group "root"
    action :nothing
  end
  tmpl.run_action(:create)

  if user
    sudoers_file "/etc/sudoers.d/#{user}"
    # throw error if file already exists
    if ::File.exists? sudoers_file
      Chef::Application.fatal!("sudoers file #{sudoers_file} already exists ")
    end
      
    template sudoers_file do
      cookbook "sudo"
      source ""
      mode 0440
      owner "root"
      group "root"
      variables ( :cmds => new_resource.cmds )
      action :create
    end
  else
    


  end

  
end

action :remove do


end
