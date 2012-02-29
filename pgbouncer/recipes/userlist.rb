#
# Cookbook Name:: pgbouncer
# Recipe:: userlist
# Author:: Bryan W. Berry (<bryan.berry@gmail.com>)
#
# Copyright 2011, Christoph Krybus
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

sql_cmd = %Q['SELECT $$"$$ || replace( usename, $$"$$, $$""$$) || $$" "$$ || replace( passwd, $$"$$, $$""$$ ) || $$"$$ from pg_shadow where passwd is not null and (usename = '"'"'postgres'"'"' or usename like '"'"'%_ds'"'"') order by 1']

psql_cmd = %Q[psql -h #{node[:pgbouncer]['pghost']} \
     -p #{node[:pgbouncer]["pgport"]} -U #{node[:pgbouncer]["pguser"]}  \
     #{node[:pgbouncer]['psqlopts']} -c #{sql_cmd}]

shell_cmd = %Q[ su - postgres; #{psql_cmd} ]

cron_cmd = %Q[
# this file was placed by chef

tmpfile=$(mktemp);
#{psql_cmd} > $tmpfile;
tmp_sum=$(md5sum $tmpfile)
cur_sum=$(md5sum $tmpfile)
if [  "$tmpsum" != "$cur_sum" ] ; then
  cat $tmpfile > #{node[:pgbouncer][:auth_file]}
fi
  
]
                   
# add users (clients) that will access this bouncer
ruby_block "initial_get_userlist" do
  block do
    cmd = Chef::ShellOut.new(shell_cmd).run_command
    unless cmd.exitstatus == 0
      Chef::Application.fatal!(%Q[ Failed to build userlist for pgbouncer."\n" STDERR is #{cmd.stderr} ])
    end
    list_of_users = []
    cmd.stdout.split("\n").each do |entry|
        user, md5hash = entry.scan(/\w+/)
        list_of_users << [user, md5hash]
    end
    node['pgbouncer']['userlist'] = list_of_users
  end
end

template node[:pgbouncer][:auth_file] do
  source "userlist.txt.erb"
  owner "root"
  group "postgres"
  mode "664"
  notifies :reload, resources(:service => "pgbouncer")
end

file "/usr/local/bin/cron_userlist.sh" do
  owner "postgres"
  group "postgres"
  mode "0755"
  content <<EOS

# this file was placed by chef, manual changes will be overwritten

tmpfile=$(mktemp);
#{psql_cmd} > $tmpfile;
tmp_sum=$(md5sum $tmpfile | awk '{print $1}')
cur_sum=$(md5sum #{node[:pgbouncer][:auth_file]} | awk '{print $1}')
if [  "$tmp_sum" != "$cur_sum" ] ; then
  cat $tmpfile > #{node[:pgbouncer][:auth_file]}
fi

rm -f $tmpfile
  
EOS
  action :create_if_missing
end

cron "pgbouncer" do
  hour "*"
  minute "0"
  user "postgres"
  shell "/bin/bash"
  command "/home/postgres/cron_userlist.sh"
end
