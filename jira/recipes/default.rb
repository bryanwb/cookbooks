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

jira_user = node['jira']['user']

t = tomcat "jira" do
  user jira_user
  action :install
end

# get mysql connector
ivy "mysql-connector-java" do
  groupId "mysql"
  version "5.1.18"
  owner jira_user
  dest  "#{t.base}/lib"
end

ark "jira_war" do
  release_url node['jira']['war_url']
  version "5.0"
  install_dir     "#{t.base}/webapps/ROOT"
  user jira_user
  no_symlink      true
end

remote_file "balsamiq" do
  source node['jira']['balsamiq_url']
  path "#{t.base}/webapps/ROOT/webapp/WEB-INF/lib/mockups-2.1.13.jar"
  owner jira_user
end

ark "additional_jars" do
  release_url node['jira']['jars_url']
  install_dir  "#{t.base}/webapps/ROOT/webapp/WEB-INF/lib"
  user jira_user
  stop_file "commons-logging-1.1.1.jar"
  no_symlink  true
end
