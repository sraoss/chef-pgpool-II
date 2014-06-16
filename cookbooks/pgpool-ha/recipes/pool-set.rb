#
# Cookbook Name:: pgpool-ha
# Recipe:: pool-set
#
# Copyright 2014, YOUR_COMPANY_NAME #
# All rights reserved - Do Not Redistribute
#

accounts = data_bag('pgpool-ha_accounts')
item = data_bag_item('pgpool-ha_accounts', accounts[0])
apache_home_dir = item['users'].select {|i| i['name'] == 'apache'}[0]['home']

if node['master_db'] then
	bash 'pgpool-extenstions' do
		user 'postgres'
		group 'postgres'
		code <<-EOT
		#{node['pg_home']}/bin/pg_ctl -D #{node['pg_data']} -w start
		#{node['pg_home']}/bin/psql -c 'CREATE EXTENSION pgpool_regclass'
		#{node['pg_home']}/bin/psql -c 'CREATE EXTENSION pgpool_recovery'
		#{node['pg_home']}/bin/psql -d template1 -c 'CREATE EXTENSION pgpool_regclass'
		#{node['pg_home']}/bin/psql -d template1 -c 'CREATE EXTENSION pgpool_recovery'
		#{node['pg_home']}/bin/pg_ctl -D #{node['pg_data']} stop
		EOT
	end
end

directory "#{apache_home_dir}/sbin" do
	owner 'apache'
	group 'apache'
	mode 00700
	action :create
end

bash 'copy ping commands' do
	code <<-EOT
	cp /sbin/ifconfig #{apache_home_dir}/sbin
	cp /sbin/arping
	chown apache. #{apache_home_dir}/sbin/*
	chmod 4755 #{apache_home_dir}/sbin/*
	EOT
end

template "/etc/pgpool-II/pgpool.conf" do
	owner 'apache'
	group 'root'
	mode 0644
end

template "/etc/pgpool-II/pcp.conf" do
	owner 'apache'
	group 'root'
	mode 0644
end

if node['master_db'] then
	template "#{node['pg_data']}/recovery_1st_stage" do
		owner 'postgres'
		group 'postgres'
		mode 0755
	end
end

if node['master_db'] then
	template "#{node['pg_data']}/pgpool_remote_start" do
		owner 'postgres'
		group 'postgres'
		mode 0755
	end
end

template '/etc/pgpool-II/failover.sh' do
	owner 'root'
	group 'root'
	mode 0755
end

%W[/var/run/pgpool #{node['pgpool_logdir']}].each do |path|
	directory path do
		owner 'apache'
		group 'apache'
		mode 0755
	end
end

if node['master_db'] then
	bash 'master pgsql start' do
		user 'postgres'
		group 'postgres'
		code <<-EOT
		#{node['pg_home']}/bin/pg_ctl -D #{node['pg_data']} -w start
		EOT
	end
end

template "/var/www/html/pgpoolAdmin/conf/pgmgt.conf.php" do
	owner 'apache'
	group 'root'
	mode 0644
end

if node['master_pgpool'] then
	bash 'master pgpool start' do
		user 'apache'
		group 'apache'
		code <<-EOT
		/usr/bin/pgpool -n -d > #{node['pgpool_logdir']}/pgpool.log 2>&1 &
		EOT
	end
end
