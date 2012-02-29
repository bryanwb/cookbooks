#
# Cookbook Name:: ivy
# Recipe:: default
# Author:: Bryan W. Berry (<bryan.berry@gmail.com>)
# Copyright 2012, Bryan W. Berry
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

include_recipe "ark"

a = ark "ivy" do
  release_url node['ivy']['url']
  checksum node['ivy']['checksum']
  version node['ivy']['version']
end

ruby_block "build the ivy command" do
  block do
    java_cmd = "#{node['java']['java_home']}/bin/java"
    ivy_jar = "#{a.home_dir}/ivy-#{node['ivy']['version']}.jar"
    node['ivy']['command'] = "#{java_cmd} -jar #{ivy_jar} "
    Chef::Log.debug("ivy command is #{node['ivy']['command']}")
  end
end
