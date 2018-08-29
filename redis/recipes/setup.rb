#
# Cookbook:: redis
# Recipe:: setup
# Author:: Bryan Recinos
# Copyright:: 2018, The Authors, All Rights Reserved.

#Updating and installing packages
execute "update" do 
	command "sudo apt-get update -y"
	action :run
end

package "build-essential" do
	action :install
end

package "tcl" do
	action :install
end

package "libjemalloc-dev" do
	action :install
end

#Download and install redis
homefolder = "/home/ubuntu"
execute "download-redis" do
	command "curl -O http://download.redis.io/redis-stable.tar.gz && tar xzvf redis-stable.tar.gz"
	cwd "#{homefolder}"
end

execute "install-redis" do
	command "make && make test && sudo make install"
	cwd "#{homefolder}/redis-stable"
end