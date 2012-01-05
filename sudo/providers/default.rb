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
    Chef::Application.fatal!("You cannot specify user, group, and template")
  end
end

def sudo_test tmpl_name
  cmd = Chef::ShellOut.new(
                           %Q[ visudo -cf #{tmpl_name} ]
                           ).run_command
  unless cmd.exitstatus == 0
    FileUtils.rm_f tmpl_name
    Chef::Application.fatal!("sudoers template #{tmpl_name} failed parsing validation!")
  end
end

def render_sudo_template new_resource
  Dir.mktmpdir do |tmpdir|
    template_path = "#{tmpdir}/#{new_resource.name}"
    tmpl = template template_path do
      source new_resource.template
      mode 0440
      owner "root"
      group "root"
      variables new_resource.variables
      action :nothing
    end
    tmpl.run_action(:create)
    sudo_test template_path
    FileUtils.mv template_path, "/etc/sudoers.d/"
  end
  new_resource.updated_by_last_action(true)
end

def render_sudo_attributes new_resource
  require 'tempfile'
  sudo_user = new_resource.user
  sudo_group = new_resource.group
  commands = new_resource.commands
  host = new_resource.host
  runas = new_resource.runas
  nopasswd = new_resource.nopasswd
  sudo_entries = Array.new
  
  if sudo_group
    # prepend % to name if group name if it isn't already there
    if sudo_group !~ /^%.*$/
      sudo_name = "%#{sudo_group}"
    else
      sudo_name = sudo_group
    end
  else
    sudo_name = sudo_user
  end
  commands.each do |cmd|
    entry = ""
    entry << sudo_name
    entry << " ALL=(#{runas}) "
    if nopasswd
      entry << "NOPASSWD:"
    end
    entry << cmd
    sudo_entries << entry
  end

  tmpfile = Tempfile.new "d"
  tmpfile_path = tmpfile.path
  tmpfile.write sudo_entries.join "\n"
  tmpfile.close
  sudo_test tmpfile_path
  FileUtils.chmod 0440, tmpfile_path
  FileUtils.mv tmpfile_path, "/etc/sudoers.d/"
  new_resource.updated_by_last_action(true)
  
end

action :install do
  if new_resource.template
    Chef::Log.debug "template attribute provided to sudo lwrp, all other attributes ignored" +
      " except for variables attribute"
    render_sudo_template new_resource
  else
    render_sudo_attributes new_resource
  end
end

action :remove do
  sudoers_path = "/etc/sudoers.d/#{new_resource.name}"
  require 'fileutils'
  FileUtils.rm_f sudoers_path
  new_resource.updated_by_last_action(true)
end
