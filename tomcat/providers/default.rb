#
# Author:: Bryan W. Berry (<bryan.berry@gmail.com>)
# Cookbook Name:: tomcat
# Provider:: default
#
# Copyright 2012, Bryan w. Berry
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

# checks password file to see if user already exists
def check_username!(username)
  require 'etc'
  user_exists = true
  begin 
    Etc.getpwnam(username)
  rescue ArgumentError
    user_exists = false
  end
  unless user_exists
    Chef::Application::fatal!("The user specified #{username} already exists, pick a new one")
  end
end

action :install do
  require 'pathname'
  catalina_home = node['tomcat']['home']

  catalina_parent = Pathname.new(catalina_home).parent.to_s
  catalina_base = "#{catalina_parent}/#{new_resource.name}"
  tomcat_user = 
  # set the base for this instance
  node['tomcat']['base'] = catalina_base
  node['tomcat']['tmp_dir'] = "#{catalina_base}/temp"
  
  # if this is the first time this recipe run
  unless Dir.exists? catalina_base
    check_username! new_resource.user
    user new_resource do
      supports :manage_home => true
    end
  end

  
#  %w{ conf logs temp }

  


end


action :remove do

end
