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
        @owner = :owner
        @url = :url
        @append_env_path = :append_env_path
        @strip_leading_dir = true
        @checksum = :checksum
        @release_ext = parse_file_name
        set_paths
        @expand_cmd = :expand_cmd
        @has_binaries = :has_binaries
        @allowed_actions.push(:install)
        @action = :install
        @provider = Chef::Provider::ArkBase
      end

      attr_reader @install_dir, @release_file

      def owner(arg=nil)
        set_or_return(
                      :owner,
                      arg,
                      :kind_of => String)
      end
      
      def checksum(arg=nil)
        set_or_return(
                      :checksum,
                      arg,
                      :regex => /^[a-zA-Z0-9]{64}$/)
      end

      def has_binaries(arg=nil)
        set_or_return(
                      :has_binaries,
                      arg,
                      :kind_of => Array)
      end

      def append_env_path(arg=nil)
        set_or_return(
                      :append_env_path,
                      arg,
                      :kind_of => [TrueClass, FalseClass])
      end
      
      def url(arg=nil)
        if arg
          unless @url =~ /^(http|ftp).*$/
            arg = set_apache_url
          end
        end
        set_or_return(
                      :url,
                      arg,
                      :kind_of => String,
                      :required => true)
      end

      def parse_file_name
        release_basename = ::File.basename(@url.gsub(/\?.*\z/, '')).gsub(/-bin\b/, '')
        # (\?.*)? accounts for a trailing querystring
        release_basename =~ %r{^(.+?)\.(tar\.gz|tar\.bz2|zip|war|jar)(\?.*)?}
        @release_ext      = $2
      end
      
      def set_paths
        parse_file_name(@url)
        @install_dir      = ::File.join(@install_dir, "#{@name}")
        @release_file     = ::File.join(@install_dir,  "#{@name}.#{@release_ext}")
      end

      def set_apache_url(url)
        raise "Missing required resource attribute url" unless url
        url.gsub!(/:name:/,          name.to_s)
        url.gsub!(/:version:/,       version.to_s)
        url.gsub!(/:apache_mirror:/, node['install_from']['apache_mirror'])
        url
      end

      def expand_cmd
        cmd = case @release_ext
              when 'tar.gz'  then untar_cmd('xzf')
              when 'tar.bz2' then untar_cmd('xjf')
              when /zip|war|jar/ then unzip_cmd
              else raise "Don't know how to expand #{url} which has extension '#{release_ext}'"
              end
      end

      private
      
      def unzip_cmd
        ::Proc.new {|r|
          FileUtils.mkdir_p r.install_dir
          if r.strip_leading_dir
            require 'tmpdir'
            tmpdir = Dir.mktmpdir
            system("unzip  -q -u -o '#{r.release_file}' -d '#{tmpdir}'")
            subdirectory_children = Dir.glob("#{tmpdir}/**")
            FileUtils.mv subdirectory_children, r.install_dir
            FileUtils.rm_rf tmpdir
          elsif r.junk_paths
            system("unzip  -q -u -o -j #{r.release_file} -d #{r.install_dir}")
          else
            system("unzip  -q -u -o #{r.release_file} -d #{r.install_dir}")
          end 
          FileUtils.chown_R r.owner, r.owner, r.install_dir
        }
      end

      def untar_cmd(sub_cmd)
        ::Proc.new {|r|
          FileUtils.mkdir_p r.install_dir
          if r.strip_leading_dir
            strip_argument = "--strip-components=1"
          else
            strip_argument = ""
          end
          system(%Q{tar '#{sub_cmd}' '#{r.release_file}' '#{strip_argument}' -C '#{r.install_dir}';})
          FileUtils.chown_R r.owner, r.owner, r.install_dir
        }
      end

    end
  end
end

