#
# Cookbook Name:: ark
# Resource:: ArkBase
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

require 'chef/resource'

class Chef
  class Resource
    class ArkBase < Chef::Resource

      def initialize(name, run_context=nil)
        super
        @resource_name = :ark
        @owner = 'root'
        @url = nil
        @append_env_path = false
        @strip_leading_dir = true
        @checksum = nil
        @release_ext = nil
        @expand_cmd = nil
        @release_file = nil
        @has_binaries = []
        @allowed_actions.push(:install)
        @action = :install
        @provider = Chef::Provider::ArkBase
      end

      def checksum(arg=nil)
        set_or_return(
                      :checksum,
                      arg,
                      :regex => /^[a-zA-Z0-9]{64}$/)
      end

      def url(arg=nil)
        
        set_or_return(
                      :url,
                      arg,
                      :kind_of => String )
      end

      
      def set_paths(path, name, release_ext)
        install_dir      = ::File.join(path, "#{name}")
        release_file     = ::File.join(install_dir,  "#{name}.#{release_ext}")
        [ install_dir, release_file ]
      end

      def opened?(resource)
        if @stop_file and !(@stop_file.empty?)
          if  ::File.exist?(::File.join(@install_dir,
                                        @stop_file))
            true
          else
            false
          end
        elsif !::File.exists?(@install_dir) or
            ::File.stat("#{@install_dir}/").nlink == 2
          Chef::Log.debug("ark is empty")
          false
        else
          true
        end
      end

      def set_apache_url(url)
        raise "Missing required resource attribute url" unless url
        url.gsub!(/:name:/,          name.to_s)
        url.gsub!(/:version:/,       version.to_s)
        url.gsub!(/:apache_mirror:/, node['install_from']['apache_mirror'])
        url
      end

      
    end
  end
end

