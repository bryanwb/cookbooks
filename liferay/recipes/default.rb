#
# Cookbook Name:: liferay
# Recipe:: default
# Author:: Bryan W. Berry (<bryan.berry@gmail.com>)
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

require 'pathname'
require 'fileutils'
include_recipe "tomcat::base"
include_recipe "ark"
include_recipe 'maven'

liferay_user = node['liferay']['user']
catalina_parent = Pathname.new(node['tomcat']['home']).parent.to_s
base = "#{catalina_parent}/#{liferay_user}"

user liferay_user do
  action :create
  supports :manage_home => true
end

t = tomcat "liferay" do
  user liferay_user
  action :install
  jvm_opts [
            "-Djava.awt.headless=true",
            "-Xmx2048m", "-Xms512m",
            "-XX:MaxPermSize=512m" ]
  webapp_opts [
                "-Dfile.encoding=UTF8",
                "-Duser.timezone=Europe/Rome",
                "-Djava.security.auth.login.config=#{base}/conf/jaas.config",
                "-Dorg.apache.catalina.loader.WebappClassLoader.ENABLE_CLEAR_REFERENCES=false"
               ]  
end

cookbook_file "#{base}/conf/jaas.config" do
  source "jaas.config"
  owner liferay_user 
end

# jta, persistence, jms, postgresql
maven "javax.persistence"  do
  groupId "org.eclipse.persistence"
  version "2.0.0"
  dest "#{base}/lib"
end

maven "jta"  do
  groupId "javax.transaction"
  version "1.1"
  dest "#{base}/lib"
end

maven "jms" do
  groupId "com.sun.messaging.mq"
  version "4.4"
  dest "#{base}/lib"
end

maven "postgresql" do
  groupId "postgresql"
  version "9.0-801.jdbc4"
  dest "#{base}/lib"
end

# unpack the main .war file
ark_put "ROOT" do
  url node['liferay']['war_url']
  checksum node['liferay']['war_checksum']
  path "#{base}/webapps"
  strip_leading_dir false
  owner liferay_user
end

ark_dump "liferay_dependencies" do
  url node['liferay']['dependencies_url']
  checksum node['liferay']['dependencies_checksum']
  owner liferay_user
  path   "#{base}/lib" 
  creates "portlet.jar"
end

ark_dump "liferay_client_dependencies" do
  url node['liferay']['client_dependencies_url']
  checksum node['liferay']['client_dependencies_checksum']
  owner liferay_user
  path   "#{base}/lib"
  creates "wsdl4j.jar"
end


# this lousy file properly sets liferay.home to CATALINA_BASE
cookbook_file "#{base}/webapps/ROOT/WEB-INF/classes/portal-ext.properties" do
  source "portal-ext.properties"
  owner liferay_user
  notifies :restart, t, :immediately
end

