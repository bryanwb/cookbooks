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

liferay_user = node['liferay']['user']
catalina_parent = Pathname.new(node['tomcat']['home']).parent.to_s
base = "#{catalina_parent}/#{liferay_user}"

t = tomcat "liferay" do
  user liferay_user
  action :install
  jvm_opts [
            "-Djava.awt.headless=true",
            "-Xmx1526m", "-Xms1024m",
            "-XX:MaxPermSize=1526m" ]
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

remote_file "#{Chef::Config[:file_cache_path]}/liferay-portal.war" do
  source "http://downloads.sourceforge.net/project/lportal/Liferay%20Portal/6.1.0%20GA1/liferay-portal-6.1.0-ce-ga1-20120106155615760.war?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Flportal%2Ffiles%2FLiferay%2520Portal%2F6.1.0%2520GA1%2F&ts=1329474724&use_mirror=freefr"
  checksum 'de5e2b65983b27c322b196ef975582d42746d670c0ca40e00c1e5369eb3a6972'
end

directory "#{base}/webapps/ROOT" do
  mode 0775
  owner liferay_user 
end

# unpack the main .war file
ruby_block "unpack_liferay_war" do
  block do
    system("unzip #{Chef::Config[:file_cache_path]}/liferay-portal.war -d #{base}/webapps/ROOT")
    FileUtils.chown_R  liferay_user, liferay_user, "#{base}/webapps/ROOT"
  end
  action :create
  not_if { Dir.exist? "#{base}/webapps/ROOT" }
end

# get and unpack additional jars to CATALINA_BASE/lib
remote_file "#{Chef::Config[:file_cache_path]}/liferay-dependencies.zip" do
  source "http://downloads.sourceforge.net/project/lportal/Liferay%20Portal/6.1.0%20GA1/liferay-portal-dependencies-6.1.0-ce-ga1-20120106155615760.zip?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Flportal%2Ffiles%2FLiferay%2520Portal%2F6.1.0%2520GA1%2F&ts=1329474759&use_mirror=netcologne"
  checksum 'd98e27627ae7689f254e1e3c7f3e92fcc4f3fb2537aa071a30f44311d24c49e7'
end

# unpack
ruby_block "unpack_liferay_dependencies" do
  block do
    system("unzip #{Chef::Config[:file_cache_path]}/liferay-dependencies.zip -d #{base}/lib/")
    FileUtils.chown_R  liferay_user, liferay_user, "#{base}/lib"
  end
  action :create
  not_if { File.exist? "#{base}/lib/portal.jar" }
end

remote_file "#{Chef::Config[:file_cache_path]}/liferay-client-dependencies.zip" do
  source "http://downloads.sourceforge.net/project/lportal/Liferay%20Portal/6.1.0%20GA1/liferay-portal-client-6.1.0-ce-ga1-20120106155615760.zip?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Flportal%2Ffiles%2FLiferay%2520Portal%2F6.1.0%2520GA1%2F&ts=1329490764&use_mirror=ignum"
  checksum 'd6b7f7801b02dafad318f2fb9a92cb9a7f0fe000f47590cc74d1c28cc17802f6'
end
  
# unpack the main .war
ruby_block "unpack_liferay_client_dependencies" do
  block do
    system("unzip #{Chef::Config[:file_cache_path]}/liferay-client-dependencies.zip -d #{base}/lib/")
    FileUtils.chown_R  liferay_user, liferay_user, "#{base}/lib"
  end
  action :create
  not_if { File.exist? "#{base}/lib/mail.jar" }
end


# add ALL THE JARS
node['liferay']['extra_jars'].each do |jar,url|
  remote_file "#{base}/lib/#{jar}" do
    source url
    owner liferay_user
  end
end

# this lousy file properly sets liferay.home to CATALINA_BASE
cookbook_file "#{base}/webapps/ROOT/WEB-INF/classes/portal-ext.properties" do
  source "portal-ext.properties"
  owner liferay_user
  notifies :restart => resources( :service => 'liferay' )
end

