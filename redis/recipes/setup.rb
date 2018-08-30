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
execute "download-redis" do
	command "curl -O http://download.redis.io/redis-stable.tar.gz && tar xzvf redis-stable.tar.gz"
	cwd "/tmp"
end

execute "install-redis" do
	command "make && make test && sudo make install"
	cwd "/tmp/redis-stable"
end

execute "move-folder" do
	command "sudo cp ./redis-stable /etc/redis"
	cwd "/tmp"
end

execute "create-redis-user" do
	command "sudo adduser --system --group --no-create-home redis"
end

systemd_unit "redis.service" do 
	content({Unit:{
		Description: 'Redis In-Memory Data Store',
		After: 'network.target'
	},Service: {
		User: 'redis',
		Group: 'redis',
		ExecStart: '/etc/redis/src/redis-server /etc/redis/redis.conf',
		ExecStop: '/etc/redis/src/redis-cli shutdown',
		Restart: 'always',
	},Install: {
		WantedBy: 'multi-user.target',
	}})
  action :create
end

systemd_unit "sentinel.service" do 
	content({Unit:{
		Description: 'Sentinel for redis',
		After: 'network.target'
	},Service: {
		LimitNOFILE:'64000',
		User: 'redis',
		Group: 'redis',
		ExecStart: '/etc/redis/src/redis-sentinel /etc/redis/sentinel.conf --daemonize no',
	},Install: {
		WantedBy: 'multi-user.target',
	}})
  action :create
end

execute "change-own" do
	command "sudo chown redis:redis /etc/redis/sentinel.conf"
end
