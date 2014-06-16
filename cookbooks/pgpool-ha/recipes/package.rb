#
# Cookbook Name:: pgpool-ha
# Recipe:: package
#
# Copyright 2014, YOUR_COMPANY_NAME #
# All rights reserved - Do Not Redistribute
#

node['rpm'].each do |rpm_name, rpm_checksum|
	cookbook_file "/tmp/#{rpm_name}" do
		mode 00644
		checksum rpm_checksum
	end
	package rpm_name do
		action :install
		source "/tmp/#{rpm_name}"
	end
end

bash 'postgresql93* install' do
	code <<-EOT
	yum install -y postgresql93*
	EOT
end

node['yum-package'].each do |pkg|
	package pkg do
		action :install
	end
end
