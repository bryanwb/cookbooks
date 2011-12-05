#
# Cookbook Name:: users
# Recipe:: operators.rb 
#
# Copyright 2011, Bryan W. Berry 
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

operators = Array.new
operators_data_bags = search(:users, 'sudo_cmds:* AND groups:operators')

if operators_data_bags != nil
	operators_data_bags.each do |d|
			operators << d.raw_data
	end
end


operators.each do |u|

 
	home_dir = "/home/#{u['id']}"

  # fixes CHEF-1699
  ruby_block "reset group list" do
    block do
      Etc.endgrent
    end
    action :nothing
  end

	user u['id'] do
		uid u['uid']
		gid u['gid']
		shell u['shell']
		comment u['comment']
		supports :manage_home => true
		home home_dir
		if u['password']
			password u['password']	
		end
		notifies :create, "ruby_block[reset group list]", :immediately
	end

  directory "#{home_dir}/.ssh" do
    owner u['id']
    group u['gid'] || u['id']
    mode "0700"
  end

  template "#{home_dir}/.ssh/authorized_keys" do
    source "authorized_keys.erb"
    owner u['id']
    group u['gid'] || u['id']
    mode "0600"
    variables :ssh_keys => u['ssh_keys']
  end
end

template "/etc/sudoers.d/prodctl" do
	source "prodctl_sudoers.erb"
  mode 0440
  owner "root"
  group "root"
	variables( :sudoers => operators )
end
