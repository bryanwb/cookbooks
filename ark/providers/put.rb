#
# Author:: Bryan W. Berry (<bryan.berry@gmail.com>)
# Copyright:: 2012 Bryan W. Berry
# Cookbook Name:: ark
# Provider::      put
#
#
# This is modified version of Infochimps' install_from cookbook
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

action :install do

  url,basename,ext = parse_url(new_resource.url)
  install_dir, release_file = set_ark_put_paths(new_resource.path, new_resource.name, ext)
  new_resource.release_file = release_file
  new_resource.install_dir = install_dir
  new_resource.expand_cmd = get_expand_cmd(ext)

  directory(::File.dirname(release_file)) do
    mode        '0755'
    action      :create
    recursive   true
  end
  remote_file release_file do
    source      url
    mode        "0644"
    action      :create
    checksum    new_resource.checksum if new_resource.checksum
    not_if{     ::File.exists?(release_file) }
  end
  directory(::File.dirname(new_resource.install_dir)) do
    mode      '0755'
    action    :create
    recursive true
  end
  ruby_block "unpack #{new_resource.name} release" do
    block do
      new_resource.expand_cmd.call(new_resource)
      new_resource.updated_by_last_action(true)
    end
    not_if { ark_opened?(new_resource) }
  end
  new_resource.has_binaries.each do |bin|
    link ::File.join(new_resource.prefix_root,
                     'bin', ::File.basename(bin)) do
      to        ::File.join(new_resource.home_dir, bin)
      action    :create
    end
  end
  if new_resource.append_env_path
    file "/etc/profile.d/#{new_resource.name}.sh" do
      content <<-EOF
      export PATH=$PATH:#{::File.join(new_resource.install_dir, 'bin').to_s}
      EOF
      mode 0755
      owner 'root'
      group 'root'
    end
    ruby_block "export path" do
      block do
        ENV['PATH'] = ENV['PATH'] + ":" +
          ::File.join(new_resource.install _dir, 'bin').to_s
      end
    end
  end
  
end
