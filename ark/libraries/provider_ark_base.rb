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

require 'chef/provider'

class Chef
  class Resource
    class ArkBase < Chef::Provider
      
      def load_current_resource
        @current_resource = Chef::Resource::ArkBase.new(@new_resource.name)
      end

      def action_create
        action_parse
        unless exists?


        end
      end

      private

      def exists?
        if new_resource.stop_file and !(new_resource.stop_file.empty?)
          if  ::File.exist?(::File.join(new_resource.install_dir,
                                        new_resource.stop_file))
            true
          else
            false
          end
        elsif !::File.exists?(new_resource.install_dir) or
            ::File.stat("#{new_resource.install_dir}/").nlink == 2
          Chef::Log.debug("ark")
          false
        else
          true
        end
      end

      end
    end
  end
end

