#
# Cookbook Name:: maven
# Recipe:: maven2
#
# Copyright 2011, Bryan W. Berry (<bryan.berry@gmail.com>)
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

include_recipe "java"
maven_home = node['maven']["maven_home"]
maven_root = maven_home.split('/')[0..-2].join('/')

java_cpr "maven2" do
  url node['maven']['2']['url']
  checksum node['maven']['2']['checksum']
  app_root maven_root
  bin_cmds ["mvn"]
  action :install
end
