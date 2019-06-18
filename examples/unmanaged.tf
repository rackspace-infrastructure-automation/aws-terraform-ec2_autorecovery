provider "aws" {
  version = "~> 1.2"
  region  = "us-west-2"
}

module "vpc" {
  source   = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork?ref=v0.0.9"
  vpc_name = "EC2-AR-BaseNetwork-Test1"
}

data "aws_region" "current_region" {}

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
  source     = "git@github.com:rackspace-infrastructure-automation/aws-terraform-sns//?ref=v0.0.2"
  topic_name = "my-alarm-notification-topic"
}

module "unmanaged_ar" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-ec2_autorecovery?ref=v0.0.17"

  ec2_os              = "centos7"
  instance_count      = "1"
  subnets             = "${module.vpc.private_subnets}"
  security_group_list = ["${module.vpc.default_sg}"]
  image_id            = "${data.aws_ami.amazon_centos_7.image_id}"
  instance_type       = "t2.micro"
  resource_name       = "my_unmanaged_instance"
  notification_topic  = "${module.sns.topic_arn}"
  rackspace_managed   = false
}
