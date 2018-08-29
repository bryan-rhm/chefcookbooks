#
# Cookbook:: redis
# Recipe:: configure
# Author:: Bryan Recinos
# Copyright:: 2018, The Authors, All Rights Reserved.
template "/etc/redis/redis.conf" do
	source "redis.rb"
	mode "0644"
	isMaster ="#"
	master = "NO ONE"
	port = ""
	instance = search("aws_opsworks_instance", "self:true").first
	if instance["hostname"] != "redis1"
		isMaster=""
		search("aws_opsworks_instance").each do |instance|
			if instance["hostname"] == "redis1"
				master = instance["public_ip"]
				port = "6379"
			end
		end
	end
	variables(
		:master_ip => master,
		:master_port => port,
		:is_master => isMaster
		)
end

template "/etc/redis/sentinel.conf" do
	source "sentinel.rb"
	mode "0644"
	master = ""
	port = ""
	search("aws_opsworks_instance").each do |instance|
		if instance["hostname"] == "redis1"
			master = instance["public_ip"]
			port = "6379"
		end
	end
	variables(
		:master_ip => master,
		:master_port => port
		)
end

execute "start-redis" do
	command "sudo systemctl restart redis"
end

execute "start-sentinel" do
	command "sudo systemctl restart sentinel"
end