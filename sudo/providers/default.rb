#
# Author:: Bryan W. Berry (<bryan.berry@gmail.com>)
# Cookbook Name:: sudo
# Provider:: default
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

require 'fileutils'

def check_inputs user, group, foreign_template, foreign_vars
    # if group, user, and template are nil, throw an exception
  if user == nil and group == nil and foreign_template == nil
    Chef::Application.fatal!("You must provide a user, group, or template")
  elsif user != nil and group != nil and template != nil
    Chef::Application.fatal!("You cannot specify user, group or template")
  end
end

def visudo_check tmpl_name
  success = system("visudo -cf #{tmpl_name}")
  unless success
    Chef::Application.fatal!("Sudoers fragment failed parsing check!")
  end
end

def render_from_foreign_template name, foreign_template, foreign_vars
  Dir.mktmpdir do |tmpdir|
    template_path = "#{tmpdir}/#{name}"
    tmpl = template template_path do
      source "#{foreign_template}"
      mode 0440
      owner "root"
      group "root"
      variables foreign_vars
      action :nothing
    end
    tmpl.run_action(:create)
    visudo_check template_path
    FileUtils.mv template_path, "/etc/sudoers.d/"
  end
end

action :install do
  name = new_resource.name
  user = new_resource.user
  group = new_resource.group
  pattern = new_resource.pattern
  cmds = new_resource.cmds || []
  foreign_template = new_resource.template
  foreign_vars = new_resource.variables
  check_inputs user, group, foreign_template, foreign_vars
     
  if foreign_template
    render_from_foreign_template name, foreign_template, foreign_vars
  else 
    if user
      sudoers_name = user
      group_prefix = false
    else 
      sudoers_name = group
      group_prefix = true
    end

    if pattern == "app"
      if new_resource.service
        service = new_resource.service
      elsif user
        service = user
      else
        service = group
      end
    else
      service = nil
    end
    
    # if one of the commands is all, set pattern to super pattern
    if cmds.grep(/all/i).length > 0
      pattern = "super"
    end
    
    Chef::Log.debug "The pattern is #{pattern}"
    Dir.mktmpdir do |tmpdir|
      template_path = "#{tmpdir}/#{name}"
      tmpl = template template_path do
        cookbook "sudo"
        source "#{pattern}.erb"
        mode 0440
        owner "root"
        group "root"
        variables( :cmds => cmds,
                   :name => sudoers_name,
                   :passwordless => new_resource.passwordless,
                   :pattern => pattern,
                   :service => service,
                   :group_prefix => group_prefix
                   )
        action :nothing
      end
      tmpl.run_action(:create)
      visudo_check template_path
      FileUtils.mv template_path, "/etc/sudoers.d/"
    end
  end
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
