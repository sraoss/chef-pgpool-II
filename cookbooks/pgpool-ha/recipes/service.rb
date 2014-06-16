#
# Cookbook Name:: pgpool-ha
# Recipe:: service
#
# Copyright 2014, YOUR_COMPANY_NAME #
# All rights reserved - Do Not Redistribute
#

service 'httpd' do
	action [:enable, :start]
end
