provider "aws" {
  region  = "us-west-2"
  version = "3.27.0"
}

locals {
  tags = {
    Environment     = "Test"
    Purpose         = "Testing aws-terraform-ec2_autorecovery"
    ServiceProvider = "Rackspace"
    Terraform       = "true"
  }
}

resource "random_string" "res_name" {
  length  = 8
  upper   = false
  lower   = true
  special = false
  number  = false
}

module "vpc" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork?ref=v0.12.4"

  name = "${random_string.res_name.result}-EC2-AR-BaseNetwork-Test1"
}

module "internal_zone" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-route53_internal_zone//?ref=v0.12.1"

  environment = "Test"
  name        = "circlecitesting.local."
  vpc_id      = module.vpc.vpc_id
}


resource "aws_eip" "test_eip_1" {
  vpc = true

  tags = merge(
    local.tags,
    {
      Name = "-${random_string.res_name.result}-EC2-AR-Test1"
    },
  )
}

module "ec2_ar_centos7_with_codedeploy" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-ec2_autorecovery?ref=v0.12.19"

  backup_tag_value                  = "False"
  cloudwatch_log_retention          = 30
  creation_policy_timeout           = "20m"
  cw_cpu_high_evaluations           = 15
  cw_cpu_high_operator              = "GreaterThanThreshold"
  cw_cpu_high_period                = 60
  cw_cpu_high_threshold             = 90
  detailed_monitoring               = true
  disable_api_termination           = false
  eip_allocation_id_count           = 1
  eip_allocation_id_list            = [aws_eip.test_eip_1.id]
  enable_ebs_optimization           = false
  encrypt_secondary_ebs_volume      = false
  environment                       = "Development"
  install_codedeploy_agent          = false
  instance_count                    = 3
  instance_role_managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEC2FullAccess", "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetRole", "arn:aws:iam::aws:policy/CloudWatchActionsEC2Access"]
  instance_type                     = "t2.micro"
  key_pair                          = "CircleCI"
  name                              = "${random_string.res_name.result}-ar_centos7_codedeploy"
  notification_topic                = ""
  perform_ssm_inventory_tag         = true
  primary_ebs_volume_iops           = 0
  primary_ebs_volume_size           = 60
  primary_ebs_volume_type           = "gp2"
  security_groups                   = [module.vpc.default_sg]
  ssm_association_refresh_rate      = "rate(1 day)"
  ssm_patching_group                = "Group1Patching"
  subnets                           = module.vpc.public_subnets
  t2_unlimited_mode                 = "standard"
  tenancy                           = "default"
  ec2_os                            = "centos7"

  tags = local.tags
}

resource "aws_eip" "test_eip_2" {
  vpc = true

  tags = merge(
    local.tags,
    {
      Name = "${random_string.res_name.result}-EC2-AR-BaseNetwork-Test1-2"
    },
  )
}