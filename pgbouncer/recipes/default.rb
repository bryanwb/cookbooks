#
# Cookbook Name:: pgbouncer
# Recipe:: default
# Author:: Christoph Krybus <ckrybus@googlemail.com>
# Author:: Bryan W. Berry (<bryan.berry@gmail.com>)
#
# Copyright 2011, Christoph Krybus
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



user_list = []  # list of users of pgbouncer

case platform
when "redhat","centos","scientific","fedora","suse"
  config_dir = "/etc"
  include_recipe "yumrepo::pgdg91"
when "ubuntu", "debian"
  config_dir = "/etc/pgbouncer"
end

package "pgbouncer" do
  action :upgrade
end

service "pgbouncer" do
  action :nothing
  supports :status => true, :start => true, :stop => true, :restart => true, :reload => true
end

template "#{config_dir}/pgbouncer.ini" do
  source "pgbouncer.ini.erb"
  owner "root"
  group "root"
  mode "644"
  notifies :reload, resources(:service => "pgbouncer")
end

template "#{config_dir}/userlist.txt" do
  source "userlist.txt.erb"
  owner "root"
  group "root"
  mode "644"
  notifies :reload, resources(:service => "pgbouncer")
end

if platform?("ubuntu", "debian")
  template "/etc/default/pgbouncer" do
    source "pgbouncer.default.erb"
    owner "root"
    group "root"
    mode "644"
    notifies :reload, resources(:service => "pgbouncer")
  end
end

ruby_block "get_users" do
  block do
    #!/usr/bin/ruby

    ENV["PSQLOPTS"] = "-qAtX"
    ENV["PGHOST"] = "localhost"
    ENV["PGHOSTADDR"] = ""
    ENV["PGPORT"] = "5432"
    ENV["PGDATABASE"] = "sdw_datastore"
    ENV["PGUSER"] = "postgres"
    ENV["PGPASSWORD"] = ""
    ENV["PGPASSFILE"] = "/home/postgres/.pgpass"

    cmd = Chef::ShellOut.new(%Q[ psql ${PSQLOPTS} -c 'SELECT $$"$$ || \
			 replace( usename, $$"$$, $$""$$) || \
			 $$" "$$ || \
			 replace( passwd, $$"$$, $$""$$ ) || \
			 $$"$$ from pg_shadow where passwd is not null and \
			 (usename = '"'"'postgres'"'"' or \
			 usename like '"'"'%_ds'"'"') order by 1' ]).run_command
    unless cmd.exitstatus == 0
      Chef::Application.fatal!(%Q[ Failed to build userlist for pgbouncer ])
    end
    user_list = cmd.stdout.split("\n")
  end
end

template "#{config_dir}/user_list.txt" do
  
  
end


service "pgbouncer" do
  action [:enable, :start]
end
