#
# Cookbook Name::       jira
# Description::         installs jira
# Recipe::              default
# Author::              Bryan W. Berry
#
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
include_recipe "tomcat::base"
include_recipe "ivy"
base = "/tmp/"

t = tomcat "jira" do
  user node['jira']['user']
  action :install
end

# get mysql connector
ivy "mysql-connector-java" do
  groupId "mysql"
  version "5.1.18"
  dest_attr  ":tomcat:base:/lib"
end

# ark "jira_war" do
#   release_url node['jira']['war_url']
#   version "5.0"
#   install_dir     "/usr/local/tomcat/jira/webapps/ROOT"
#   no_symlink      true
# end
