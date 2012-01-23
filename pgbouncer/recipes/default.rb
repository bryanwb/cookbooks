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

case node['platform']
when "redhat","centos","scientific","fedora","suse"
  include_recipe "yumrepo::postgresql9"
end

package "pgbouncer" do
  action :upgrade
end

service "pgbouncer" do
  action :nothing
  supports :status => true, :start => true, :stop => true, :restart => true, :reload => true
end

# EL rpms don't create this directory automatically
directory "/etc/pgbouncer" do
  owner "root"
  group "root"
  mode  "644"
end

template default[:pgbouncer][:initfile] do
  source "pgbouncer.ini.erb"
  owner "root"
  group "root"
  mode "644"
  notifies :reload, resources(:service => "pgbouncer")
end

# add users (clients) that will access this bouncer
ruby_block "get_users" do
  block do
    #!/usr/bin/ruby

    ENV["PSQLOPTS"] = node[:pgbouncer]['PSQLOPTS'] 
    ENV["PGHOST"] = node[:pgbouncer]['PGHOST']
    ENV["PGHOSTADDR"] = node[:pgbouncer]["PGHOSTADDR"]
    ENV["PGPORT"] = node[:pgbouncer]["PGPORT"] 
    ENV["PGDATABASE"] = node[:pgbouncer]["PGDATABASE"] 
    ENV["PGUSER"] = node[:pgbouncer]["PGUSER"]
    ENV["PGPASSWORD"] = node[:pgbouncer]["PGPASSWORD"]
    ENV["PGPASSFILE"] = node[:pgbouncer]["PGPASSFILE"]

    cmd = Chef::ShellOut.new(%Q[ su - postgres;
                         psql -h ${PGHOST} -p ${PGPORT} -U ${PGUSER}  ${PSQLOPTS} -c 'SELECT $$"$$ || \
			 replace( usename, $$"$$, $$""$$) || \
			 $$" "$$ || replace( passwd, $$"$$, $$""$$ ) || \
			 $$"$$ from pg_shadow where passwd is not null and \
			 (usename = '"'"'postgres'"'"' or \
			 usename like '"'"'%_ds'"'"') order by 1' ]).run_command
    unless cmd.exitstatus == 0
      Chef::Application.fatal!(%Q[ Failed to build userlist for pgbouncer."\n" STDERR is #{cmd.stderr} ])
    end
    node['pgbouncer']['userlist'] = cmd.stdout.split("\n")
  end
end

template node[:pgbouncer][:auth_file] do
  source "userlist.txt.erb"
  owner "root"
  group "root"
  mode "644"
  notifies :reload, resources(:service => "pgbouncer")
end

template default[:pgbouncer][:additional_config_file] do
  source "pgbouncer.sysconfig.erb"
  owner "root"
  group "root"
  mode "644"
  notifies :reload, resources(:service => "pgbouncer")
end

service "pgbouncer" do
  action [:enable, :start]
end
