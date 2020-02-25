provider "aws" {
  version = "~> 2.2"
  region  = "us-west-2"
}

module "vpc" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork?ref=v0.12.0"

  name = "EC2-AR-BaseNetwork-Test1"
}

data "aws_region" "current_region" {
}

# Lookup the correct AMI based on the region specified
data "aws_ami" "amazon_centos_7" {
  most_recent = true

  owners = [
    "679593333241",
  ]

  filter {
    name = "name"

    values = [
      "CentOS Linux 7 x86_64 HVM EBS*",
    ]
  }
}

module "sns" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-sns//?ref=v0.0.2"

  topic_name = "my-alarm-notification-topic"
}

module "unmanaged_ar" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-ec2_autorecovery?ref=v0.12.4"

  ec2_os              = "centos7"
  image_id            = data.aws_ami.amazon_centos_7.image_id
  instance_count      = 1
  instance_type       = "t2.micro"
  notification_topic  = module.sns.topic_arn
  rackspace_managed   = false
  resource_name       = "my_unmanaged_instance"
  security_group_list = [module.vpc.default_sg]
  subnets             = module.vpc.private_subnets
}
