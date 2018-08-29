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
	instance = search("aws_opsworks_instance", "self:true").first
	if instance["hostname"] != "redis1"
		search("aws_opsworks_instance").each do |instance|
			if instance["hostname"] == "redis1"
				master = instance["private_ip"]
				port = "6379"
			end
		end
	end
	variables(
		:master_ip => master,
		:master_port => port
		)
end

template "#{homefolder}/redis-stable/sentinel.conf" do
	source "sentinel.rb"
	mode "0644"
	master = ""
	port = ""
	search("aws_opsworks_instance").each do |instance|
		if instance["hostname"] == "redis1"
			master = instance["private_ip"]
			port = "6379"
		end
	end
	variables(
		:master_ip => master,
		:master_port => port
		)
end

execute "kill-redis-server" do
	command "pkill redis-server"
end

execute "kill-redis-sentinel" do
	command "pkill redis-sentinel"
end

execute "start-redis" do
	command "redis-server ../redis.conf &"
	pwd "#{homefolder}/redis-stable/src"
end

execute "start-sentinel" do
	command "redis-sentinel ../sentinel.conf  &"
	pwd "#{homefolder}/redis-stable/src"
end