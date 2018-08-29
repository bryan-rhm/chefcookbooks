#
# Cookbook:: redis
# Recipe:: default
#
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

template "#{homefolder}/redis-stable/redis.conf" do
	source "redis.rb"
	mode "0644"
	master = "NO ONE"
	port = ""
	if node["opsworks"]["instance"]["hostname"] == "redis1"
		master = node["opsworks"]["instance"]["private_ip"]
		port = "6379"
	variables(
		:master_ip => master
		:master_port => port
		)
end

template "#{homefolder}/redis-stable/sentinel.conf" do
	source "sentinel.rb"
	layer =node["opsworks"]["instance"]["layers"][0]
	mode "0644"
	master = "NO ONE"
	port = ""
	node["opsworks"]["layers"]["#{layer}"]["instances"].each  do |instance,properties|
		if instance == "redis1"
			master = properties["private_ip"]
			port = "6379"
	end
	variables(
		:master_ip => master
		:master_port => port
		)
end
