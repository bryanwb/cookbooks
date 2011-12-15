#
# Cookbook Name:: users
# Recipe:: prodctl.rb 
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

prodctl_db = search(:users, 'id:prodctl')[0]

user "prodctl" do
  uid prodctl_db['uid']
  gid prodctl_db['gid']
  shell prodctl_db['shell']
  comment prodctl_db['comment']
  supports :manage_home => true
  home "/home/prodctl"
  password prodctl_db['password']	
end

sudo "prodctl" do
  user "prodctl"
  cmds prodctl_db[:sudo_cmds]
end

