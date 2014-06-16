#
# Cookbook Name:: pgpool-ha
# Recipe:: pg-set
#
# Copyright 2014, YOUR_COMPANY_NAME #
# All rights reserved - Do Not Redistribute
#

accounts = data_bag('pgpool-ha_accounts')
item = data_bag_item('pgpool-ha_accounts', accounts[0])
pg_home_dir = item['users'].select {|i| i['name'] == 'postgres'}[0]['home']

template "#{pg_home_dir}/.bash_profile" do
	owner 'postgres'
	group 'postgres'
	mode 0644
	source 'dot.bash_profile.erb'
end

if node['master_db'] then
	bash 'initdb' do
		user 'postgres'
		group 'postgres'
		code <<-EOT
		if [ -e #{node['pg_data']} ]; then
			rm -rf #{node['pg_data']}
		fi
		#{node['pg_home']}/bin/initdb --no-locale --encoding=utf8 -D #{node['pg_data']}

		if [ -e #{node['pg_backups']} ]; then
			rm -rf #{node['pg_backups']}
		fi
		mkdir #{node['pg_backups']}
		EOT
	end

	pgdata_files = [
		"#{node['pg_data']}/postgresql.conf",
		"#{node['pg_data']}/pg_hba.conf"
	]
	pgdata_files.each do |file|
		template file do
			owner 'postgres'
			group 'postgres'
			mode 0600
		end
	end
end
