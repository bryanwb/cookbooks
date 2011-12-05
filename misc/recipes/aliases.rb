execute 'newaliases' do
	action :nothing
end

template '/etc/aliases' do
	source 'aliases.erb'
	variables( :aliases => [ ['root' , 'unix-system-adm@fao.org'] ] )
	notifies :run, "execute[newaliases]"
end
