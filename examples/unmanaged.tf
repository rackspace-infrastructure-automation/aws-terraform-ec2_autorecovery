terraform {
  required_version = ">= 1.0.0"
}

provider "aws" {
  version = "~> 3.0"
  region  = "us-west-2"
}
module "vpc" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork?ref=v0.12.8"

  name = "EC2-AR-BaseNetwork-Test1"
}

data "aws_region" "current_region" {
}

module "sns" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-sns?ref=v0.12.2"

  name = "my-alarm-notification-topic"
}

module "unmanaged_ar" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-ec2_autorecovery?ref=v0.12.26"

  ec2_os             = "centos7"
  instance_count     = 1
  instance_type      = "t2.micro"
  notification_topic = module.sns.topic_arn
  rackspace_managed  = false
  name               = "my_unmanaged_instance"
  security_groups    = [module.vpc.default_sg]
  subnets            = module.vpc.private_subnets
}
