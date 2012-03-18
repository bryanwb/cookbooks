#
# Cookbook Name:: ark
# Resource::      default
#
# Author:: Philip (flip) Kromer <flip@infochimps.com>
# Author:: Bryan W. Berry <bryan.berry@gmail.com>
# Copyright 2011, Philip (flip) Kromer
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

require 'fileutils'

actions(
  :download,
  :unpack,
  :configure,
  :build,
  :install,
  :configure_with_autoconf,
  :build_with_make,
  :build_with_ant,
  :install_with_make,
  :install_binaries,
  :install_python
  )

attr_accessor :home_dir, :install_dir

attribute :name,          :name_attribute => true

# URL for the tarball/zip file to install from. If it is named something like
# pig-0.8.0.tar.gz and unpacks to ./pig-0.8.0 we can take it from there
# You may use the following recognized patterns:
#   :name:          -- value of resource's name
#   :version:       -- value of resource's version
#   :apache_mirror: -- node[:install_from][:apache_mirror]
#
attribute :url,   :kind_of => String, :required => true

# Prefix_Root directory -- other _dir attributes hang off this by default
attribute :prefix_root,   :kind_of => String, :default  => "/usr/local"

# version slug, appended to the name to get the install_dir
attribute :version,       :kind_of => String, :default => ""

# Directory for the unreleased contents,   eg /usr/local/share/pig-0.8.0. default: {prefix_root}/share/{name}-#{version}
attribute :install_dir,   :kind_of => String

# Directory as the project is referred to, eg /usr/local/share/pig. default: {prefix_root}/share/{name}
attribute :home_dir,      :kind_of => String

# don't create symlink home_dir to install_dir as home_dir and
# install_dir are the same directory
attribute :no_symlink,     :kind_of => [FalseClass, TrueClass], :default => false

# Checksum for the release file
attribute :checksum,      :kind_of => String, :default => nil

# Command to expand project
attribute :expand_cmd,    :kind_of => [Proc, String]

# Release file name, eg /usr/local/src/pig-0.8.0.tar.gz
attribute :release_file,  :kind_of => String

# Release file extension, if we can't guess it from the release file: one of 'tar.gz', 'tar.bz2' or 'zip'
attribute :release_ext,   :kind_of => String

# User to run as
attribute :owner,          :kind_of => String, :default => 'root'

# Environment to pass on to commands
attribute :environment,   :kind_of => Hash, :default => {}

# Binaries to install. Supply a path relative to install_dir, and it will be
# symlinked to prefix_root
attribute :has_binaries,  :kind_of => Array,  :default => []

# similar to has_binaries but less granular
attribute :append_env_path, :kind_of => [TrueClass, FalseClass], :default => false

# options to pass to the ./configure command for the configure_with_autoconf action
attribute :autoconf_opts, :kind_of => Array, :default => []

# by default, strip the leading directory from the extracted archive,
# this can cause unexpected results if there is more than one
# subdirectory in the archive
attribute :strip_leading_dir, :kind_of => [TrueClass, FalseClass], :default => true

# The  archive's  directory structure is not recreated;
# all files are deposited in the extraction directory
# only applies to zip archives
attribute :junk_paths, :kind_of => [TrueClass, FalseClass], :default => false

# if this file exists in the home_dir, ark resource doesn't need to
# open the ark again
attribute :stop_file, :kind_of => String, :default => ""

# used internally to check whether the ark has been opened
attribute :ark_check_cmd, :kind_of => [Proc, String]

def initialize(*args)
  super
  # we can't use the node properties when initially specifying the resource
  @prefix_root = node[:ark][:prefix_root]
  @action = :install
end


def assume_defaults!
  # construct the url if we use the auto-magic apache patterns
  unless @url =~ /^(http|ftp).*$/
    set_url
  end
  # the url 'http://apache.org/pig/pig-0.8.0.tar.gz' has
  # release_basename 'pig-0.8.0' and release_ext 'tar.gz'
  release_basename = ::File.basename(@url.gsub(/\?.*\z/, '')).gsub(/-bin\b/, '')
  # (\?.*)? accounts for a trailing querystring
  release_basename =~ %r{^(.+?)\.(tar\.gz|tar\.bz2|zip|war|jar)(\?.*)?}
  @release_ext      ||= $2
  
  @install_dir      ||= ::File.join(prefix_root, node[:ark][:prefix_install], "#{name}-#{version}")
  @home_dir         ||= ::File.join(prefix_root, node[:ark][:prefix_home], name)
  @release_file     ||= ::File.join(prefix_root, node[:ark][:prefix_src],  "#{name}-#{version}.#{release_ext}")
  @expand_cmd ||=
    case release_ext
    when 'tar.gz'  then untar_cmd('xzf')
    when 'tar.bz2' then untar_cmd('xjf')
    when /zip|war|jar/ then unzip_cmd
    else raise "Don't know how to expand #{url} which has extension '#{release_ext}'"
    end
  @ark_check_cmd ||= ark_opened?
  
  Chef::Log.info("at end of assume_defaults!")
  Chef::Log.info( [environment, install_dir, home_dir, release_file, release_basename, release_ext, url, prefix_root ].inspect )
end

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

def ark_opened?
  ::Proc.new {|r|
    if !(r.stop_file.empty?)
      if  ::File.exist?(::File.join(r.install_dir, r.stop_file))
        true
      else
        false
      end
    elsif !::File.exists?(r.install_dir) or ::File.stat("#{r.install_dir}/").nlink == 2
      Chef::Log.debug("ark is empty")
      false
    else
      true
    end
  }
end

def set_url
  raise "Missing required resource attribute url" unless @url
  @url.gsub!(/:name:/,          name.to_s)
  @url.gsub!(/:version:/,       version.to_s)
  @url.gsub!(/:apache_mirror:/, node['install_from']['apache_mirror'])
end
