provider "aws" {
  region  = "us-west-2"
  version = "~> 3.0"
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
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork?ref=v0.12.0"

  name = "${random_string.res_name.result}-EC2-AR-BaseNetwork-Test1"
}

module "internal_zone" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-route53_internal_zone//?ref=v0.12.0"

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
  source = "../../module"

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
  install_codedeploy_agent          = true
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

module "ec2_ar_centos7_no_codedeploy" {
  source = "../../module"

  ec2_os                       = "centos7"
  instance_count               = 1
  subnets                      = module.vpc.public_subnets
  security_groups              = [module.vpc.default_sg]
  key_pair                     = "CircleCI"
  instance_type                = "t2.micro"
  name                         = "${random_string.res_name.result}-ar_centos7_noncodedeploy"
  install_codedeploy_agent     = false
  enable_ebs_optimization      = false
  tenancy                      = "default"
  backup_tag_value             = "False"
  detailed_monitoring          = true
  ssm_patching_group           = "Group1Patching"
  primary_ebs_volume_size      = 60
  primary_ebs_volume_iops      = 0
  primary_ebs_volume_type      = "gp2"
  secondary_ebs_volume_size    = 60
  secondary_ebs_volume_iops    = 0
  secondary_ebs_volume_type    = "gp2"
  encrypt_secondary_ebs_volume = false

  environment                       = "Development"
  instance_role_managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEC2FullAccess", "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetRole", "arn:aws:iam::aws:policy/CloudWatchActionsEC2Access"]
  perform_ssm_inventory_tag         = true
  cloudwatch_log_retention          = 30
  ssm_association_refresh_rate      = "rate(1 day)"
  notification_topic                = ""
  disable_api_termination           = false
  t2_unlimited_mode                 = "standard"
  creation_policy_timeout           = "20m"
  cw_cpu_high_operator              = "GreaterThanThreshold"
  cw_cpu_high_threshold             = 90
  cw_cpu_high_evaluations           = 15
  cw_cpu_high_period                = 60
  eip_allocation_id_count           = 1
  eip_allocation_id_list            = [aws_eip.test_eip_2.id]

  ebs_volume_tags = local.tags

  tags = local.tags
}

module "ec2_ar_windows_with_codedeploy" {
  source = "../../module"

  ec2_os                            = "windows2016"
  instance_count                    = 1
  subnets                           = module.vpc.private_subnets
  security_groups                   = [module.vpc.default_sg]
  key_pair                          = "CircleCI"
  instance_type                     = "t2.micro"
  name                              = "${random_string.res_name.result}-ar_windows_codedeploy"
  install_codedeploy_agent          = true
  enable_ebs_optimization           = false
  tenancy                           = "default"
  backup_tag_value                  = "False"
  detailed_monitoring               = true
  ssm_patching_group                = "Group1Patching"
  primary_ebs_volume_size           = 60
  primary_ebs_volume_iops           = 0
  primary_ebs_volume_type           = "gp2"
  secondary_ebs_volume_size         = 60
  secondary_ebs_volume_iops         = 0
  secondary_ebs_volume_type         = "gp2"
  encrypt_secondary_ebs_volume      = false
  environment                       = "Development"
  instance_role_managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEC2FullAccess", "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetRole", "arn:aws:iam::aws:policy/CloudWatchActionsEC2Access"]
  perform_ssm_inventory_tag         = true
  cloudwatch_log_retention          = 30
  ssm_association_refresh_rate      = "rate(1 day)"
  notification_topic                = ""
  disable_api_termination           = false
  t2_unlimited_mode                 = "standard"
  creation_policy_timeout           = "20m"
  cw_cpu_high_operator              = "GreaterThanThreshold"
  cw_cpu_high_threshold             = 90
  cw_cpu_high_evaluations           = 15
  cw_cpu_high_period                = 60

  tags = local.tags
}

module "ec2_ar_windows_no_codedeploy" {
  source = "../../module"

  ec2_os         = "windows2016"
  instance_count = "3"
  subnets        = module.vpc.public_subnets

  security_groups = [module.vpc.default_sg]

  key_pair                     = "CircleCI"
  instance_type                = "t2.micro"
  name                         = "${random_string.res_name.result}-ar_windows_noncodedeploy"
  install_codedeploy_agent     = false
  enable_ebs_optimization      = false
  tenancy                      = "default"
  backup_tag_value             = "False"
  detailed_monitoring          = true
  ssm_patching_group           = "Group1Patching"
  primary_ebs_volume_size      = 60
  primary_ebs_volume_iops      = 0
  primary_ebs_volume_type      = "gp2"
  secondary_ebs_volume_size    = 60
  secondary_ebs_volume_iops    = 0
  secondary_ebs_volume_type    = "gp2"
  encrypt_secondary_ebs_volume = false
  environment                  = "Development"

  instance_role_managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetRole",
    "arn:aws:iam::aws:policy/CloudWatchActionsEC2Access",
  ]

  perform_ssm_inventory_tag    = true
  cloudwatch_log_retention     = 30
  ssm_association_refresh_rate = "rate(1 day)"
  notification_topic           = ""
  disable_api_termination      = false
  t2_unlimited_mode            = "standard"
  creation_policy_timeout      = "20m"
  cw_cpu_high_operator         = "GreaterThanThreshold"
  cw_cpu_high_threshold        = 90
  cw_cpu_high_evaluations      = 15
  cw_cpu_high_period           = 60

  tags = local.tags
}

module "sns" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-sns?ref=v0.12.0"

  name = "${random_string.res_name.result}-Test1-alarm-notification-topic"
}

module "unmanaged_ar" {
  source = "../../module"

  ec2_os             = "centos7"
  instance_count     = 1
  subnets            = module.vpc.private_subnets
  security_groups    = [module.vpc.default_sg]
  instance_type      = "t2.micro"
  name               = "${random_string.res_name.result}-test1-unmanaged_instance"
  notification_topic = module.sns.topic_arn
  rackspace_managed  = false
}

module "zero_count_ar" {
  source = "../../module"

  ec2_os             = "centos7"
  instance_count     = 0
  subnets            = []
  security_groups    = [module.vpc.default_sg]
  instance_type      = "t2.micro"
  name               = "${random_string.res_name.result}-nonexistent_instance"
  notification_topic = module.sns.topic_arn
  rackspace_managed  = false
}

resource "aws_ebs_volume" "nfs" {
  availability_zone = "us-west-2a"
  size              = 60
  encrypted         = true

  tags = merge(
    local.tags,
    {
      Name = "${random_string.res_name.result}-ar-nfs"
    },
  )
}

resource "aws_ebs_snapshot" "encrypted_nfs" {
  volume_id = aws_ebs_volume.nfs.id

  tags = merge(
    local.tags,
    {
      Name = "${random_string.res_name.result}-ar-nfs"
    },
  )
}

module "ec2_nfs" {
  source = "../../module"

  ec2_os                           = "amazon2"
  instance_count                   = 1
  subnets                          = module.vpc.private_subnets
  security_groups                  = [module.vpc.default_sg]
  key_pair                         = "CircleCI"
  instance_type                    = "t2.micro"
  name                             = "${random_string.res_name.result}-ar-nfs"
  install_nfs                      = true
  primary_ebs_volume_size          = 60
  primary_ebs_volume_iops          = 0
  primary_ebs_volume_type          = "gp2"
  encrypt_primary_ebs_volume       = true
  secondary_ebs_volume_size        = 60
  secondary_ebs_volume_iops        = 0
  secondary_ebs_volume_type        = "gp2"
  secondary_ebs_volume_existing_id = aws_ebs_snapshot.encrypted_nfs.id

  tags = local.tags
}

module "ar_r53" {
  source = "../../module"

  create_internal_route53 = true
  ec2_os                  = "centos7"
  instance_count          = 2
  subnets                 = module.vpc.private_subnets
  security_groups         = [module.vpc.default_sg]
  instance_type           = "t2.micro"
  internal_zone_id        = module.internal_zone.internal_hosted_zone_id
  internal_zone_name      = module.internal_zone.internal_hosted_name
  name                    = "${random_string.res_name.result}-test1-instance_r53"
  notification_topic      = module.sns.topic_arn
  rackspace_managed       = false

  tags = local.tags
}
