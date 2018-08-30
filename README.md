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


For more information related to this repo please see:

- [CloudFormation](https://aws.amazon.com/es/documentation/cloudformation/)
- [OpsWorks](https://aws.amazon.com/es/documentation/opsworks/)
- [Chef](https://www.chef.io/configuration-management/)
- [Redis Sentinel](https://redis.io/topics/sentinel)
