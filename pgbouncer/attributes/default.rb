
default[:pgbouncer][:databases] = {}
default[:pgbouncer][:userlist] = {}

# Administrative settings
if platform?("redhat", "centos", "scientific", "fedora")
  # this value is hardcoded into rpm from yum.postgresql.org
  # yet still required as commandline parameter WTF
  default[:pgbouncer][:initfile] = "/etc/pgbouncer.ini"
  default[:pgbouncer][:additional_config_file]  "/etc/sysconfig/pgbouncer"
  default[:pgbouncer][:pidfile] = "/var/run/pgbouncer/pgbouncer.pid"

else
  default[:pgbouncer][:initfile] = "/etc/pgbouncer/pgbouncer.ini"
  default[:pgbouncer][:additional_config_file] = "/etc/default/pgbouncer"
  default[:pgbouncer][:pidfile] = "/var/run/postgresql/pgbouncer.pid"
end

default[:pgbouncer][:logfile] = "/var/log/postgresql/pgbouncer.log"

# Where to wait for clients
default[:pgbouncer][:listen_addr] = "127.0.0.1"
default[:pgbouncer][:listen_port] = "6432"
default[:pgbouncer][:unix_socket_dir] = "/var/run/postgresql"

# Authentication settings
default[:pgbouncer][:auth_type] = "trust"
default[:pgbouncer][:auth_file] = "/etc/pgbouncer/userlist.txt"

# Users allowed into database 'pgbouncer'
default[:pgbouncer][:admin_users] = ""
default[:pgbouncer][:stats_users] = ""

# Pooler personality questions
default[:pgbouncer][:pool_mode] = "session"
default[:pgbouncer][:server_reset_query] = ""
default[:pgbouncer][:server_check_query] = "select 1"
default[:pgbouncer][:server_check_delay] = "10"

# Connection limits
default[:pgbouncer][:max_client_conn] = "100"
default[:pgbouncer][:default_pool_size] = "20"
default[:pgbouncer][:log_connections] = "1"
default[:pgbouncer][:log_disconnections] = "1"
default[:pgbouncer][:log_pooler_errors] = "1"

# Connection to Postgres

default[:pgbouncer]['PSQLOPTS'] = "-qAtX"
default[:pgbouncer]['PGHOST'] = "localhost"
default[:pgbouncer]["PGHOSTADDR"] = ""
default[:pgbouncer]["PGPORT"] = "5432"
default[:pgbouncer]["PGDATABASE"] = "postgres"
default[:pgbouncer]["PGUSER"] = "postgres"
default[:pgbouncer]["PGPASSWORD"] = ""
default[:pgbouncer]["PGPASSFILE"] = "/home/postgres/.pgpass"


# Timeouts

# Low-level tuning options

