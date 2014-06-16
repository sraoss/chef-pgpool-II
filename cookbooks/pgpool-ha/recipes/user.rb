#
# Cookbook Name:: pgpool-ha
# Recipe:: user
#
# Copyright 2014, YOUR_COMPANY_NAME #
# All rights reserved - Do Not Redistribute
#

accounts = data_bag('pgpool-ha_accounts')
accounts.each do |id|
	item = data_bag_item('pgpool-ha_accounts', id)

	item['groups'].each do |g|
		group g['name'] do
			gid g['gid']
			action :create
		end
	end

	item['users'].each do |u|
		user u['name'] do
			home u['home']
			password u['password']
			shell u['shell']
			gid u['gid']
			uid u['uid']
			action :create
		end

		directory "#{u['home']}/.ssh" do
			owner u['name']
			group u['gid']
			mode 00700
			action :create
		end

		cookbook_file "#{u['home']}/.ssh/#{item['public_key']}" do
			owner u['name']
			group u['gid']
			mode 00400
		end
		cookbook_file "#{u['home']}/.ssh/#{item['secret_key']}" do
			owner u['name']
			group u['gid']
			mode 00400
		end
		cookbook_file "#{u['home']}/.ssh/#{item['public_key']}" do
			path "#{u['home']}/.ssh/authorized_keys"
			owner u['name']
			group u['gid']
			mode 00600
		end
		file "#{u['home']}/.ssh/config" do
			config_entry = ''
			node['host_entry'].each do |key, value|
				config_entry.concat("Host #{value}\n")
				config_entry.concat("GSSAPIAuthentication no\nGSSAPIDelegateCredentials no\nStrictHostKeyChecking no\n")
				config_entry.concat("IdentityFile ~/.ssh/#{item['secret_key']}\n")
				config_entry.concat("\n")
			end
			owner u['name']
			group u['gid']
			mode 00600
			content config_entry
			action :create
		end
	end
end
