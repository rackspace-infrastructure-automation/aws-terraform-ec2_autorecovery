provider "aws" {
  version = "~> 2.2"
  region  = "us-west-2"
}

resource "random_string" "res_name" {
  length  = 8
  upper   = false
  lower   = true
  special = false
  number  = false
}

module "vpc" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork?ref=master"

  name = "${random_string.res_name.result}-EC2-AR-BaseNetwork-Test1"
}

data "aws_region" "current_region" {
}

resource "aws_eip" "test_eip_1" {
  vpc = true

  tags = {
    Name = "-${random_string.res_name.result}-EC2-AR-Test1"
  }
}

module "ec2_ar_centos7_with_codedeploy" {
  source = "../../module"

  backup_tag_value                  = "False"
  cloudwatch_log_retention          = "30"
  creation_policy_timeout           = "20m"
  cw_cpu_high_evaluations           = "15"
  cw_cpu_high_operator              = "GreaterThanThreshold"
  cw_cpu_high_period                = "60"
  cw_cpu_high_threshold             = "90"
  detailed_monitoring               = true
  disable_api_termination           = false
  eip_allocation_id_count           = "1"
  eip_allocation_id_list            = [aws_eip.test_eip_1.id]
  enable_ebs_optimization           = false
  encrypt_secondary_ebs_volume      = false
  environment                       = "Development"
  install_codedeploy_agent          = true
  instance_count                    = "3"
  instance_role_managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEC2FullAccess", "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetRole", "arn:aws:iam::aws:policy/CloudWatchActionsEC2Access"]
  instance_type                     = "t2.micro"
  key_pair                          = "CircleCI"
  name                              = "${random_string.res_name.result}-ar_centos7_codedeploy"
  notification_topic                = ""
  perform_ssm_inventory_tag         = true
  primary_ebs_volume_iops           = "0"
  primary_ebs_volume_size           = "60"
  primary_ebs_volume_type           = "gp2"
  security_groups                   = [module.vpc.default_sg]
  ssm_association_refresh_rate      = "rate(1 day)"
  ssm_patching_group                = "Group1Patching"
  subnets                           = module.vpc.public_subnets
  t2_unlimited_mode                 = "standard"
  tenancy                           = "default"
  ec2_os                            = "centos7"

  tags = {
    MyTag1 = "MyValue1"
    MyTag2 = "MyValue2"
    MyTag3 = "MyValue3"
  }
}

resource "aws_eip" "test_eip_2" {
  vpc = true

  tags = {
    Name = "${random_string.res_name.result}-EC2-AR-BaseNetwork-Test1-2"
  }
}

module "ec2_ar_centos7_no_codedeploy" {
  source = "../../module"

  ec2_os                       = "centos7"
  instance_count               = "3"
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
  primary_ebs_volume_size      = "60"
  primary_ebs_volume_iops      = "0"
  primary_ebs_volume_type      = "gp2"
  secondary_ebs_volume_size    = "60"
  secondary_ebs_volume_iops    = "0"
  secondary_ebs_volume_type    = "gp2"
  encrypt_secondary_ebs_volume = false



  environment                       = "Development"
  instance_role_managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEC2FullAccess", "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetRole", "arn:aws:iam::aws:policy/CloudWatchActionsEC2Access"]
  perform_ssm_inventory_tag         = true
  cloudwatch_log_retention          = "30"
  ssm_association_refresh_rate      = "rate(1 day)"
  notification_topic                = ""
  disable_api_termination           = false
  t2_unlimited_mode                 = "standard"
  creation_policy_timeout           = "20m"
  cw_cpu_high_operator              = "GreaterThanThreshold"
  cw_cpu_high_threshold             = "90"
  cw_cpu_high_evaluations           = "15"
  cw_cpu_high_period                = "60"
  eip_allocation_id_count           = "1"
  eip_allocation_id_list            = [aws_eip.test_eip_2.id]

  ebs_volume_tags = {
    MyTag1 = "MyValue1"
    MyTag2 = "MyValue2"
    MyTag3 = "MyValue3"
  }

  tags = {
    MyTag1 = "MyValue1"
    MyTag2 = "MyValue2"
    MyTag3 = "MyValue3"
  }
}

module "ec2_ar_centos7_no_scaleft" {
  source = "../../module"

  ec2_os                       = "centos7"
  instance_count               = "3"
  subnets                      = module.vpc.public_subnets
  security_groups              = [module.vpc.default_sg]
  key_pair                     = "CircleCI"
  instance_type                = "t2.micro"
  name                         = "${random_string.res_name.result}-ar_centos7_nonscaleft"
  install_codedeploy_agent     = false
  install_scaleft_agent        = false
  enable_ebs_optimization      = false
  tenancy                      = "default"
  backup_tag_value             = "False"
  detailed_monitoring          = true
  ssm_patching_group           = "Group1Patching"
  primary_ebs_volume_size      = "60"
  primary_ebs_volume_iops      = "0"
  primary_ebs_volume_type      = "gp2"
  secondary_ebs_volume_size    = "60"
  secondary_ebs_volume_iops    = "0"
  secondary_ebs_volume_type    = "gp2"
  encrypt_secondary_ebs_volume = false

  ebs_volume_tags = {
    MyTag1 = "MyValue1"
    MyTag2 = "MyValue2"
    MyTag3 = "MyValue3"
  }

  environment                       = "Development"
  instance_role_managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEC2FullAccess", "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetRole", "arn:aws:iam::aws:policy/CloudWatchActionsEC2Access"]
  perform_ssm_inventory_tag         = true
  cloudwatch_log_retention          = "30"
  ssm_association_refresh_rate      = "rate(1 day)"
  notification_topic                = ""
  disable_api_termination           = false
  t2_unlimited_mode                 = "standard"
  creation_policy_timeout           = "20m"
  cw_cpu_high_operator              = "GreaterThanThreshold"
  cw_cpu_high_threshold             = "90"
  cw_cpu_high_evaluations           = "15"
  cw_cpu_high_period                = "60"
  eip_allocation_id_count           = "1"
  eip_allocation_id_list            = [aws_eip.test_eip_2.id]

  tags = {
    MyTag1 = "MyValue1"
    MyTag2 = "MyValue2"
    MyTag3 = "MyValue3"
  }
}

module "ec2_ar_windows_with_codedeploy" {
  source = "../../module"

  ec2_os                            = "windows2016"
  instance_count                    = "3"
  subnets                           = module.vpc.public_subnets
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
  primary_ebs_volume_size           = "60"
  primary_ebs_volume_iops           = "0"
  primary_ebs_volume_type           = "gp2"
  secondary_ebs_volume_size         = "60"
  secondary_ebs_volume_iops         = "0"
  secondary_ebs_volume_type         = "gp2"
  encrypt_secondary_ebs_volume      = false
  environment                       = "Development"
  instance_role_managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEC2FullAccess", "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetRole", "arn:aws:iam::aws:policy/CloudWatchActionsEC2Access"]
  perform_ssm_inventory_tag         = true
  cloudwatch_log_retention          = "30"
  ssm_association_refresh_rate      = "rate(1 day)"
  notification_topic                = ""
  disable_api_termination           = false
  t2_unlimited_mode                 = "standard"
  creation_policy_timeout           = "20m"
  cw_cpu_high_operator              = "GreaterThanThreshold"
  cw_cpu_high_threshold             = "90"
  cw_cpu_high_evaluations           = "15"
  cw_cpu_high_period                = "60"

  tags = {
    MyTag1 = "MyValue1"
    MyTag2 = "MyValue2"
    MyTag3 = "MyValue3"
  }
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
  primary_ebs_volume_size      = "60"
  primary_ebs_volume_iops      = "0"
  primary_ebs_volume_type      = "gp2"
  secondary_ebs_volume_size    = "60"
  secondary_ebs_volume_iops    = "0"
  secondary_ebs_volume_type    = "gp2"
  encrypt_secondary_ebs_volume = false
  environment                  = "Development"

  instance_role_managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetRole",
    "arn:aws:iam::aws:policy/CloudWatchActionsEC2Access",
  ]

  perform_ssm_inventory_tag    = true
  cloudwatch_log_retention     = "30"
  ssm_association_refresh_rate = "rate(1 day)"
  notification_topic           = ""
  disable_api_termination      = false
  t2_unlimited_mode            = "standard"
  creation_policy_timeout      = "20m"
  cw_cpu_high_operator         = "GreaterThanThreshold"
  cw_cpu_high_threshold        = "90"
  cw_cpu_high_evaluations      = "15"
  cw_cpu_high_period           = "60"

  tags = {
    MyTag1 = "MyValue1"
    MyTag2 = "MyValue2"
    MyTag3 = "MyValue3"
  }
}

module "ec2_ar_windows_no_scaleft" {
  source = "../../module"

  ec2_os         = "windows2016"
  instance_count = "3"
  subnets        = module.vpc.public_subnets

  security_groups = [module.vpc.default_sg]

  key_pair                     = "CircleCI"
  instance_type                = "t2.micro"
  name                         = "${random_string.res_name.result}-ar_windows_nonscaleft"
  install_codedeploy_agent     = false
  install_scaleft_agent        = false
  enable_ebs_optimization      = false
  tenancy                      = "default"
  backup_tag_value             = "False"
  detailed_monitoring          = true
  ssm_patching_group           = "Group1Patching"
  primary_ebs_volume_size      = "60"
  primary_ebs_volume_iops      = "0"
  primary_ebs_volume_type      = "gp2"
  secondary_ebs_volume_size    = "60"
  secondary_ebs_volume_iops    = "0"
  secondary_ebs_volume_type    = "gp2"
  encrypt_secondary_ebs_volume = false
  environment                  = "Development"

  instance_role_managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetRole",
    "arn:aws:iam::aws:policy/CloudWatchActionsEC2Access",
  ]

  perform_ssm_inventory_tag    = true
  cloudwatch_log_retention     = "30"
  ssm_association_refresh_rate = "rate(1 day)"
  notification_topic           = ""
  disable_api_termination      = false
  t2_unlimited_mode            = "standard"
  creation_policy_timeout      = "20m"
  cw_cpu_high_operator         = "GreaterThanThreshold"
  cw_cpu_high_threshold        = "90"
  cw_cpu_high_evaluations      = "15"
  cw_cpu_high_period           = "60"

  tags = {
    MyTag1 = "MyValue1"
    MyTag2 = "MyValue2"
    MyTag3 = "MyValue3"
  }
}

module "sns" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-sns?ref=v0.12.0"

  name = "${random_string.res_name.result}-Test1-alarm-notification-topic"
}

module "unmanaged_ar" {
  source = "../../module"

  ec2_os             = "centos7"
  instance_count     = "1"
  subnets            = [element(module.vpc.private_subnets, 0)]
  security_groups    = [module.vpc.default_sg]
  instance_type      = "t2.micro"
  name               = "${random_string.res_name.result}-test1-unmanaged_instance"
  notification_topic = module.sns.topic_arn
  rackspace_managed  = false
}

module "zero_count_ar" {
  source = "../../module"

  ec2_os             = "centos7"
  instance_count     = "0"
  subnets            = []
  security_groups    = [module.vpc.default_sg]
  instance_type      = "t2.micro"
  name               = "${random_string.res_name.result}-nonexistent_instance"
  notification_topic = module.sns.topic_arn
  rackspace_managed  = false
}

module "ec2_nfs" {
  source                    = "../../module"
  ec2_os                    = "amazon2"
  instance_count            = "1"
  subnets                   = module.vpc.private_subnets
  security_groups           = [module.vpc.default_sg]
  key_pair                  = "CircleCI"
  instance_type             = "t2.micro"
  name                      = "${random_string.res_name.result}-ar-nfs"
  install_nfs               = true
  primary_ebs_volume_size   = "60"
  primary_ebs_volume_iops   = "0"
  primary_ebs_volume_type   = "gp2"
  secondary_ebs_volume_size = "60"
  secondary_ebs_volume_iops = "0"
  secondary_ebs_volume_type = "gp2"
}
