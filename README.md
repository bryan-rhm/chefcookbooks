# CloudFormation+OpsWorks+Chef+Redis
Docker image to run aws cli commands

### Usage

```sh
$ docker pull bryanrhm/aws-cli
$ docker run -rm -e  AWS_ACCESS_KEY_ID=[YOUR AWS ACCESS KEY] -e AWS_SECRET_ACCESS_KEY=[YOUR AWS SECRET] aws-cli <command> <subcommand> [options and parameters]
```

For information about how to get your access key 
See [Configuring the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html)
For AWS CLI Documentation 
See [AWS CLI User Guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html)

