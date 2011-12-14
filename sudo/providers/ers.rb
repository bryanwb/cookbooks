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

def check_inputs user, group
    # if both group and user nil, throw an exception
  if user == nil and group == nil
    Chef::Application.fatal!("You must provide a user or a group")
  elsif user != nil and group != nil
    Chef::Application.fatal!("You cannot specify both a user and a group. You" +
                             " can only specify one or the other")
  end
end


action :install do
  user = new_resource.user
  group = new_resource.group
  pattern = new_resource.pattern
  cmds = new_resource.cmds
  check_inputs user, group

  if user
    sudoers_name = user
    group_prefix = false
  else 
    sudoers_name = group
    group_prefix = true
  end
  
  # if one of the commands is all, set pattern to super pattern
  if cmds.grep(/all/i).length > 0
    pattern = "super"
  end
  sudoers_path = "/etc/sudoers.d/#{sudoers_name}"
    
  tmpl = template sudoers_path do
    cookbook "sudo"
    source "#{pattern}.erb"
    mode 0440
    owner "root"
    group "root"
    variables( :cmds => cmds,
                :name => sudoers_name,
                :passwordless => new_resource.passwordless,
                :pattern => pattern,
                :group_prefix => group_prefix
               )
    action :nothing
  end
  tmpl.run_action(:create)
  
end

action :remove do
  user = new_resource.user
  group = new_resource.group
  check_inputs user, group
  sudoers_file_name = user ? user : group
  sudoers_path = "/etc/sudoers.d/#{sudoers_file_name}"
  require 'fileutils'
  FileUtils.rm_f sudoers_path
end
