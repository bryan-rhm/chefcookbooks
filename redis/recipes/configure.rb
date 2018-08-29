#
# Cookbook:: redis
# Recipe:: configure
# Author:: Bryan Recinos
# Copyright:: 2018, The Authors, All Rights Reserved.
homefolder = "/home/ubuntu"
template "#{homefolder}/redis-stable/redis.conf" do
	source "redis.rb"
	mode "0644"
	master = "NO ONE"
	port = ""
	hostname = node["opsworks"]["instance"]["hostname"]
	if hostname == "redis1"
		master = node["opsworks"]["instance"]["private_ip"]
		port = "6379"
	end
	variables(
		:master_ip => master,
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
	end
	variables(
		:master_ip => master,
		:master_port => port
		)
end