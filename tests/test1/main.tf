provider "aws" {
  version = "~> 1.2"
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
  source   = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork?ref=master"
  vpc_name = "EC2-AR-BaseNetwork-Test1-${random_string.res_name.result}"
}

data "aws_region" "current_region" {}

resource "aws_eip" "test_eip_1" {
  vpc = true

  tags = {
    Name = "Circle-CI-Test1-1-${random_string.res_name.result}"
  }
}

module "ec2_ar_centos7_with_codedeploy" {
  source                              = "../../module"
  ec2_os                              = "centos7"
  instance_count                      = "3"
  subnets                             = "${module.vpc.public_subnets}"
  security_group_list                 = ["${module.vpc.default_sg}"]
  key_pair                            = "CircleCI"
  instance_type                       = "t2.micro"
  resource_name                       = "ar_centos7_codedeploy-${random_string.res_name.result}"
  install_codedeploy_agent            = true
  enable_ebs_optimization             = "False"
  tenancy                             = "default"
  backup_tag_value                    = "False"
  detailed_monitoring                 = "True"
  ssm_patching_group                  = "Group1Patching"
  primary_ebs_volume_size             = "60"
  primary_ebs_volume_iops             = "0"
  primary_ebs_volume_type             = "gp2"
  encrypt_secondary_ebs_volume        = "False"
  environment                         = "Development"
  instance_role_managed_policy_arns   = ["arn:aws:iam::aws:policy/AmazonEC2FullAccess", "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetRole", "arn:aws:iam::aws:policy/CloudWatchActionsEC2Access"]
  perform_ssm_inventory_tag           = "True"
  cloudwatch_log_retention            = "30"
  ssm_association_refresh_rate        = "rate(1 day)"
  additional_ssm_bootstrap_step_count = "2"
  notification_topic                  = ""
  disable_api_termination             = "False"
  t2_unlimited_mode                   = "standard"
  creation_policy_timeout             = "20m"
  cw_cpu_high_operator                = "GreaterThanThreshold"
  cw_cpu_high_threshold               = "90"
  cw_cpu_high_evaluations             = "15"
  cw_cpu_high_period                  = "60"
  eip_allocation_id_count             = "1"
  eip_allocation_id_list              = ["${aws_eip.test_eip_1.id}"]

  additional_ssm_bootstrap_list = [
    {
      ssm_add_step = <<EOF
      {
        "action": "aws:runDocument",
        "inputs": {
          "documentPath": "arn:aws:ssm:${data.aws_region.current_region.name}:507897595701:document/Rack-Install_Package",
          "documentParameters": {
            "Packages": "bind bindutils"
          },
          "documentType": "SSMDocument"
        },
        "name": "InstallBindAndTools",
        "timeoutSeconds": 300
      }
EOF
    },
    {
      ssm_add_step = <<EOF
      {
        "action": "aws:runDocument",
        "inputs": {
          "documentPath": "AWS-RunShellScript",
          "documentParameters": {
            "commands": ["touch /tmp/myfile"]
          },
          "documentType": "SSMDocument"
        },
        "name": "CreateFile",
        "timeoutSeconds": 300
      }
EOF
    },
  ]

  additional_tags = {
    MyTag1 = "MyValue1"
    MyTag2 = "MyValue2"
    MyTag3 = "MyValue3"
  }
}

resource "aws_eip" "test_eip_2" {
  vpc = true

  tags = {
    Name = "Circle-CI-Test1-2-${random_string.res_name.result}"
  }
}

module "ec2_ar_centos7_no_codedeploy" {
  source                       = "../../module"
  ec2_os                       = "centos7"
  instance_count               = "3"
  subnets                      = "${module.vpc.public_subnets}"
  security_group_list          = ["${module.vpc.default_sg}"]
  key_pair                     = "CircleCI"
  instance_type                = "t2.micro"
  resource_name                = "ar_centos7_noncodedeploy-${random_string.res_name.result}"
  install_codedeploy_agent     = false
  enable_ebs_optimization      = "False"
  tenancy                      = "default"
  backup_tag_value             = "False"
  detailed_monitoring          = "True"
  ssm_patching_group           = "Group1Patching"
  primary_ebs_volume_size      = "60"
  primary_ebs_volume_iops      = "0"
  primary_ebs_volume_type      = "gp2"
  secondary_ebs_volume_size    = "60"
  secondary_ebs_volume_iops    = "0"
  secondary_ebs_volume_type    = "gp2"
  encrypt_secondary_ebs_volume = "False"

  ebs_volume_tags = {
    MyTag1 = "MyValue1"
    MyTag2 = "MyValue2"
    MyTag3 = "MyValue3"
  }

  environment                         = "Development"
  instance_role_managed_policy_arns   = ["arn:aws:iam::aws:policy/AmazonEC2FullAccess", "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetRole", "arn:aws:iam::aws:policy/CloudWatchActionsEC2Access"]
  perform_ssm_inventory_tag           = "True"
  cloudwatch_log_retention            = "30"
  ssm_association_refresh_rate        = "rate(1 day)"
  additional_ssm_bootstrap_step_count = "2"
  notification_topic                  = ""
  disable_api_termination             = "False"
  t2_unlimited_mode                   = "standard"
  creation_policy_timeout             = "20m"
  cw_cpu_high_operator                = "GreaterThanThreshold"
  cw_cpu_high_threshold               = "90"
  cw_cpu_high_evaluations             = "15"
  cw_cpu_high_period                  = "60"
  eip_allocation_id_count             = "1"
  eip_allocation_id_list              = ["${aws_eip.test_eip_2.id}"]

  additional_ssm_bootstrap_list = [
    {
      ssm_add_step = <<EOF
      {
        "action": "aws:runDocument",
        "inputs": {
          "documentPath": "arn:aws:ssm:${data.aws_region.current_region.name}:507897595701:document/Rack-Install_Package",
          "documentParameters": {
            "Packages": "bind bindutils"
          },
          "documentType": "SSMDocument"
        },
        "name": "InstallBindAndTools",
        "timeoutSeconds": 300
      }
EOF
    },
    {
      ssm_add_step = <<EOF
      {
        "action": "aws:runDocument",
        "inputs": {
          "documentPath": "AWS-RunShellScript",
          "documentParameters": {
            "commands": ["touch /tmp/myfile"]
          },
          "documentType": "SSMDocument"
        },
        "name": "CreateFile",
        "timeoutSeconds": 300
      }
EOF
    },
  ]

  additional_tags = {
    MyTag1 = "MyValue1"
    MyTag2 = "MyValue2"
    MyTag3 = "MyValue3"
  }
}

module "ec2_ar_windows_with_codedeploy" {
  source                              = "../../module"
  ec2_os                              = "windows2016"
  instance_count                      = "3"
  subnets                             = "${module.vpc.public_subnets}"
  security_group_list                 = ["${module.vpc.default_sg}"]
  key_pair                            = "CircleCI"
  instance_type                       = "t2.micro"
  resource_name                       = "ar_windows_codedeploy-${random_string.res_name.result}"
  install_codedeploy_agent            = true
  enable_ebs_optimization             = "False"
  tenancy                             = "default"
  backup_tag_value                    = "False"
  detailed_monitoring                 = "True"
  ssm_patching_group                  = "Group1Patching"
  primary_ebs_volume_size             = "60"
  primary_ebs_volume_iops             = "0"
  primary_ebs_volume_type             = "gp2"
  secondary_ebs_volume_size           = "60"
  secondary_ebs_volume_iops           = "0"
  secondary_ebs_volume_type           = "gp2"
  encrypt_secondary_ebs_volume        = "False"
  environment                         = "Development"
  instance_role_managed_policy_arns   = ["arn:aws:iam::aws:policy/AmazonEC2FullAccess", "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetRole", "arn:aws:iam::aws:policy/CloudWatchActionsEC2Access"]
  perform_ssm_inventory_tag           = "True"
  cloudwatch_log_retention            = "30"
  ssm_association_refresh_rate        = "rate(1 day)"
  additional_ssm_bootstrap_step_count = "2"
  notification_topic                  = ""
  disable_api_termination             = "False"
  t2_unlimited_mode                   = "standard"
  creation_policy_timeout             = "20m"
  cw_cpu_high_operator                = "GreaterThanThreshold"
  cw_cpu_high_threshold               = "90"
  cw_cpu_high_evaluations             = "15"
  cw_cpu_high_period                  = "60"

  additional_ssm_bootstrap_list = [
    {
      ssm_add_step = <<EOF
      {
        "action": "aws:runDocument",
        "inputs": {
          "documentPath": "arn:aws:ssm:${data.aws_region.current_region.name}:507897595701:document/Rack-Install_Datadog",
          "documentType": "SSMDocument"
        },
        "name": "InstallDataDog",
        "timeoutSeconds": 300
      }
EOF
    },
    {
      ssm_add_step = <<EOF
      {
        "action": "aws:runDocument",
        "inputs": {
          "documentPath": "AWS-RunPowerShellScript",
          "documentParameters": {
            "commands": ["echo $null >> C:\testfile"]
          },
          "documentType": "SSMDocument"
        },
        "name": "CreateFile",
        "timeoutSeconds": 300
      }
EOF
    },
  ]

  additional_tags = {
    MyTag1 = "MyValue1"
    MyTag2 = "MyValue2"
    MyTag3 = "MyValue3"
  }
}

module "ec2_ar_windows_no_codedeploy" {
  source         = "../../module"
  ec2_os         = "windows2016"
  instance_count = "3"
  subnets        = "${module.vpc.public_subnets}"

  security_group_list = [
    "${module.vpc.default_sg}",
  ]

  key_pair                     = "CircleCI"
  instance_type                = "t2.micro"
  resource_name                = "ar_windows_noncodedeploy-${random_string.res_name.result}"
  install_codedeploy_agent     = false
  enable_ebs_optimization      = "False"
  tenancy                      = "default"
  backup_tag_value             = "False"
  detailed_monitoring          = "True"
  ssm_patching_group           = "Group1Patching"
  primary_ebs_volume_size      = "60"
  primary_ebs_volume_iops      = "0"
  primary_ebs_volume_type      = "gp2"
  secondary_ebs_volume_size    = "60"
  secondary_ebs_volume_iops    = "0"
  secondary_ebs_volume_type    = "gp2"
  encrypt_secondary_ebs_volume = "False"
  environment                  = "Development"

  instance_role_managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetRole",
    "arn:aws:iam::aws:policy/CloudWatchActionsEC2Access",
  ]

  perform_ssm_inventory_tag           = "True"
  cloudwatch_log_retention            = "30"
  ssm_association_refresh_rate        = "rate(1 day)"
  additional_ssm_bootstrap_step_count = "2"
  notification_topic                  = ""
  disable_api_termination             = "False"
  t2_unlimited_mode                   = "standard"
  creation_policy_timeout             = "20m"
  cw_cpu_high_operator                = "GreaterThanThreshold"
  cw_cpu_high_threshold               = "90"
  cw_cpu_high_evaluations             = "15"
  cw_cpu_high_period                  = "60"

  additional_ssm_bootstrap_list = [
    {
      ssm_add_step = <<EOF
      {
        "action": "aws:runDocument",
        "inputs": {
          "documentPath": "arn:aws:ssm:${data.aws_region.current_region.name}:507897595701:document/Rack-Install_Datadog",
          "documentType": "SSMDocument"
        },
        "name": "InstallDataDog",
        "timeoutSeconds": 300
      }
EOF
    },
    {
      ssm_add_step = <<EOF
      {
        "action": "aws:runDocument",
        "inputs": {
          "documentPath": "AWS-RunPowerShellScript",
          "documentParameters": {
            "commands": ["echo $null >> C:\testfile"]
          },
          "documentType": "SSMDocument"
        },
        "name": "CreateFile",
        "timeoutSeconds": 300
      }
EOF
    },
  ]

  additional_tags = {
    MyTag1 = "MyValue1"
    MyTag2 = "MyValue2"
    MyTag3 = "MyValue3"
  }
}

module "sns" {
  source     = "git@github.com:rackspace-infrastructure-automation/aws-terraform-sns?ref=master"
  topic_name = "my-alarm-notification-topic-${random_string.res_name.result}"
}

module "unmanaged_ar" {
  source = "../../module"

  ec2_os              = "centos7"
  instance_count      = "1"
  subnets             = ["${element(module.vpc.private_subnets, 0)}"]
  security_group_list = ["${module.vpc.default_sg}"]
  instance_type       = "t2.micro"
  resource_name       = "my_unmanaged_instance-${random_string.res_name.result}"
  notification_topic  = "${module.sns.topic_arn}"
  rackspace_managed   = false
}

module "zero_count_ar" {
  source = "../../module"

  ec2_os              = "centos7"
  instance_count      = "0"
  subnets             = []
  security_group_list = ["${module.vpc.default_sg}"]
  instance_type       = "t2.micro"
  resource_name       = "my_nonexistent_instance-${random_string.res_name.result}"
  notification_topic  = "${module.sns.topic_arn}"
  rackspace_managed   = false
}

module "ec2_nfs" {
  source                    = "../../module"
  ec2_os                    = "amazon2"
  instance_count            = "1"
  subnets                   = "${module.vpc.private_subnets}"
  security_group_list       = ["${module.vpc.default_sg}"]
  key_pair                  = "CircleCI"
  instance_type             = "t2.micro"
  resource_name             = "ar-nfs-${random_string.res_name.result}"
  install_nfs               = true
  primary_ebs_volume_size   = "60"
  primary_ebs_volume_iops   = "0"
  primary_ebs_volume_type   = "gp2"
  secondary_ebs_volume_size = "60"
  secondary_ebs_volume_iops = "0"
  secondary_ebs_volume_type = "gp2"
}
