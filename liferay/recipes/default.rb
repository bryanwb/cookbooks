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
include_recipe "tomcat::base"

catalina_parent = Pathname.new(node['tomcat']['home']).parent.to_s
base = "#{catalina_parent}/#{node['liferay']['user']}"

t = tomcat "liferay" do
  user node['liferay']['user']
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
  owner node['liferay']['user'] 
end

# java_ark "http://downloads.sourceforge.net/project/lportal/Liferay%20Portal/6.1.0%20GA1/liferay-portal-6.1.0-ce-ga1-20120106155615760.war?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Flportal%2Ffiles%2FLiferay%2520Portal%2F6.1.0%2520GA1%2F&ts=1329474724&use_mirror=freefr" do
  
# end

# java_ark "http://downloads.sourceforge.net/project/lportal/Liferay%20Portal/6.1.0%20GA1/liferay-portal-dependencies-6.1.0-ce-ga1-20120106155615760.zip?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Flportal%2Ffiles%2FLiferay%2520Portal%2F6.1.0%2520GA1%2F&ts=1329474759&use_mirror=netcologne" do

# end

# # get the extra jars
# remote_file "#{t.base}/lib/jta.jar" do
#   source "http://download.java.net/maven/2/javax/transaction/jta/1.0.1B/jta-1.0.1B.jar"
#   owner node['liferay']['user'] 
# end

# # get the extra jars
# remote_file "#{t.base}/lib/persistence.jar" do
#   source "http://search.maven.org/remotecontent?filepath=org/glassfish/persistence/persistence-common/3.2-b06/persistence-common-3.2-b06.jar"
#   owner node['liferay']['user'] 
# end

# # unpack war file to ROOT



# cookbook_file "#{t.base}/webapps/ROOT/WEB-INF/classes/portal-ext.properties" do
#   source "portal-ext.properties"
#   owner node['liferay']['user']
#   notifies :restart => resources( service => 'liferay' )
# end
