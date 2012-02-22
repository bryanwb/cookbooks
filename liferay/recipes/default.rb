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
            "-Xmx1526m", "-Xms512m",
            "-XX:MaxPermSize=256m" ]
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


# unpack the main .war file
ark "liferay_war" do
  release_url node['liferay']['war_url']
  checksum node['liferay']['war_checksum']
  install_dir "#{base}/webapps/ROOT"
  home_dir "#{base}/webapps/ROOT"
  version "6.1.0"
  strip_leading_dir false
  user liferay_user
end

# ark "liferay_dependencies" do
#   release_url node['liferay']['dependencies_url']
#   checksum node['liferay']['dependencies_checksum']
#   user liferay_user
#   junk_paths true
#   version "6.1.0"
# end

# ark "liferay_client_dependencies" do
#   release_url node['liferay']['client_dependencies_url']
#   checksum node['liferay']['client_dependencies_checksum']
#   user liferay_user
#   junk_paths true
#   version "6.1.0"
# end

# remote_file "#{Chef::Config[:file_cache_path]}/mysql-jar.tar.gz" do
#   source "http://gd.tuwien.ac.at/db/mysql/Downloads/Connector-J/mysql-connector-java-5.0.8.tar.gz"
# end
  
# # unpack the main .war
# ruby_block "unpack_mysql_jar" do
#   block do
#     system("tar xvzf #{Chef::Config[:file_cache_path]}/mysql-jar.tar.gz --wildcards --no-anchored 'mysql-*bin.jar' -C #{base}/lib/")
#     FileUtils.chown_R  liferay_user, liferay_user, "#{base}/lib"
#   end
#   action :create
#   not_if { File.exist? "#{base}/lib/mysql.jar" }
# end

# # add ALL THE JARS
# node['liferay']['extra_jars'].each do |jar,url|
#   remote_file "#{base}/lib/#{jar}" do
#     source url
#     owner liferay_user
#   end
# end

# this lousy file properly sets liferay.home to CATALINA_BASE
cookbook_file "#{base}/webapps/ROOT/WEB-INF/classes/portal-ext.properties" do
  source "portal-ext.properties"
  owner liferay_user
  notifies :restart, t, :immediately
end

