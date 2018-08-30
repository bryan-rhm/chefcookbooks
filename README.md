# CloudFormation+OpsWorks+Chef+Redis
In this tutorial I will show you how to deploy a redis cluster with High Availability using redis and redis-sentinel


![redis diagram](https://i.stack.imgur.com/CHHzq.png)


## Prerequisites
- AWS Account
- Key pair already created

## Downloading the source code

Clone the repository on a local directory
```
git clone https://github.com/bryan-rhm/chefcookbooks.git
```
Once downloaded you will see two folders
- cloudformation
- redis

You only need the cloudformation directory, is where the cloudformation templates that you will use later are located.

The other folder contains the Chef recipies to manage the configuration of the redis servers.

## Deploying the Cloudformation stacks

Open CloudFormation in the Amazon AWS control panel.

![cloudformation](https://www.webdigi.co.uk/blog/wp-content/uploads/2015/03/Cloud-Formation.png)

Start creating a stack with CloudFormation. Click on “Create Stack” button on top of the page.

![cloudformation](https://www.webdigi.co.uk/blog/wp-content/uploads/2015/03/CloudFormation-CreateStack.png)

The first stack that we need to upload is the vpc.yml

![cloudformation](https://www.webdigi.co.uk/blog/wp-content/uploads/2015/03/CloudFormation-CreateInProgress.png)

Once the VPC is created, go ahead and create another stack for the opswork.yaml template, this stack will ask you to enter some parameters:
- OpsWork Stackname
- Keypair
- Instance Type
- Git repository where the cookbooks are located

By default the git repository is this one.

Once the stack is deployed you should be able to see 4 instances on your ec2 dashboard and your cluster ready to go.

![ec2](https://community.hortonworks.com/storage/attachments/3224-ec2-dashboard.png)

## Test the High Availability cluster

Connect through ssh to one of the instances and execute the following commands:

```sh
$ redis-cli
$ redis-cli> INFO replication 
```
This will display the status of the current instance.
If it is the master node you will see something like this:
```
#Replication
role:master
connected_slaves:3
slave0:ip=54.236.39.207,port=6379,state=online,offset=86674,lag=1
slave1:ip=18.233.223.115,port=6379,state=online,offset=86674,lag=1
slave2:ip=34.201.1.111,port=6379,state=online,offset=86957,lag=0
```
If you are on a slave node you will see the ip of your master node

```
# Replication
role:slave
master_host:18.213.245.105
master_port:6379
master_link_status:up

```

Now, go ahead and connect to the master node and execute the following command

```sh
$ sudp pkill redis-server
```
This will kill the redis-server on the master node, and another node will be elected as the master.

Enter to another node and check the information again

```sh
$ redis-cli
$ redis-cli> INFO replication 
```

And this time you should be able to see a different ip as the master or there is a possibility  that you enter on the new master node.

```
# Replication
role:slave
master_host:35.213.24.10
master_port:6379
master_link_status:up
```

### How it works?

Sentinel always checks the MASTER and SLAVE instances in the Redis cluster, checking whether they working as expected. If sentinel detects a failure in the MASTER node in a given cluster, Sentinel will start a failover process. As a result, Sentinel will pick a SLAVE instance and promote it to MASTER. 

### Cloudformation
![Cloudformation](https://i1.wp.com/opentodo.net/wp-content/uploads/2015/01/aws-CloudFormation.png?resize=523%2C151)

To be able to deploy the entire infrastructure in an easily manner I created two templates, one for the VPC and another one for the OpsWorks stack and the layer.

On the vpc.yaml I exported the variables needed on my OpsWorks template

```
####OUTPUTS####
Outputs:
  RedisSecurityGroupId:
    Description: Id of the server security Group
    Value: !Ref RedisSecurityGroup
    Export:
      Name: RedisSecurityGroupId
  PublicSubnet1:
    Description: Public Subnet Id
    Value: !Ref PublicSubnet1
    Export:
      Name: PublicSubnet1
  VpcId:
    Description: Id of the Vpc
    Value: !Ref MyVPC
    Export:
      Name: VpcId
```

### Chef

![chef](https://cdn-images-1.medium.com/max/1600/1*fKfo3UH30hAqWK5GezMpxw@2x.png)


All the magic about how redis and sentinel works is located on the recipes, on the folder ./redis/recipes there are two recipes:

- Setup
- Configure

The setup recipe contains the commands to update the packages and install redis and sentinel.

```ruby
#Download and install redis
execute "download-redis" do
	command "curl -O http://download.redis.io/redis-stable.tar.gz && tar xzvf redis-stable.tar.gz"
	cwd "/tmp"
end

execute "install-redis" do
	command "make && make test && sudo make install"
	cwd "/tmp/redis-stable"
end
```

The setup recipe contains all the redis and sentinel configuration using the templates redis.rb and sentinel.rb.

On the templates we substitute the ip of the node elected as master

`<%= @is_master %>slaveof <%= @master_ip %> <%= @master_port %>`

To be able to determine wich node would be the master I checked the instances under the stack and selected the first one as master.

```ruby
	if instance["hostname"] != "#{layerName}1"
		isMaster=""
		search("aws_opsworks_instance").each do |instance|
			if instance["hostname"] == "#{layerName}1"
				master = instance["public_ip"]
				port = "6379"
			end
		end
	end
```

What OpsWorsk do, is to pull the recipes of git repository indicated and select wich recipe use under te different stages:
- setup
- configure
- deploy
- undeploy
- shutdown

I indicated what recipe use under the  Opswork.yaml template.

For more information related to this repo please see:

- [CloudFormation](https://aws.amazon.com/es/documentation/cloudformation/)
- [OpsWorks](https://aws.amazon.com/es/documentation/opsworks/)
- [Chef](https://www.chef.io/configuration-management/)
- [Redis Sentinel](https://redis.io/topics/sentinel)
