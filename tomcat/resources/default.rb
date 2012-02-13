#
# Author:: Bryan W. Berry (<bryan.berry@gmail.com>)
# Cookbook Name:: tomcat
# Resource:: default
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

actions :install, :remove

attribute :http_port, :kind_of => Integer, :default => 8080
attribute :ajp_port, :kind_of => Integer, :default => 8009
attribute :shutdown_port, :kind_of => Integer, :default => 8005
attribute :host_name, :kind_of => String, :default => "localhost"
attribute :unpack_wars, :equal_to => [true, false], :default => true
attribute :auto_deploy, :equal_to => [true, false], :default => true
attribute :version, :equal_to => ["6", "7", 6, 7], :default => 7
attribute :jvm_opts, :kind_of => Array, :default =>
  ["-Djava.awt.headless=true", "-Xmx128M"]
attribute :jmx_opts, :kind_of => Array, :default => []
attribute :webapp_opts, :kind_of => Array, :default => []
attribute :user, :kind_of => String, :required => true
attribute :java_home, :kind_of => String

# we have to set default for the supports attribute
# in initializer since it is a 'reserved' attribute name
def initialize(*args)
  super
  @action = :install
  @supports = {:report => true, :exception => true}
end
