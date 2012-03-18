#
# Cookbook Name:: ark
# Resource::      put
#
# Author:: Bryan W. Berry <bryan.berry@gmail.com>
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

actions( :install )

attr_accessor :home_dir, :install_dir, :expand_cmd, :release_file

attribute :name,          :name_attribute => true
attribute :url,   :kind_of => String, :required => true
attribute :path,   :kind_of => String, :default  => "/usr/local"
attribute :append_env_path, :kind_of => [TrueClass, FalseClass], :default => false
attribute :owner,          :kind_of => String, :default => 'root'
attribute :has_binaries, :kind_of => Array, :default => []
attribute :checksum, :kind_of => String
attribute :release_ext,   :kind_of => String
attribute :strip_leading_dir, :kind_of => [TrueClass, FalseClass], :default => true
attribute :ark_check_cmd, :kind_of => [Proc, String]
attribute :expand_cmd,    :kind_of => [Proc, String]
attribute :release_file, :kind_of => String
attribute :stop_file, :kind_of => String, :default => nil

def initialize(*args)
  super
  # we can't use the node properties when initially specifying the resource
  @action = :install
end
