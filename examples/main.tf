provider "aws" {
  version = "~> 1.2"
  region  = "us-west-2"
}

module "vpc" {
  source   = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork?ref=v0.0.1"
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

module "ec2_ar" {
  source                            = "git@github.com:rackspace-infrastructure-automation/aws-terraform-ec2_autorecovery?ref=v0.0.2"
  ec2_os                            = "centos7"
  instance_count                    = "3"
  subnets                           = "${module.vpc.public_subnets}"
  security_group_list               = ["${module.vpc.default_sg}"]
  image_id                          = "${data.aws_ami.amazon_centos_7.image_id}"
  key_pair                          = "mcardenas_testing"
  instance_type                     = "t2.micro"
  resource_name                     = "my_test_instance"
  install_codedeploy_agent          = "False"
  enable_ebs_optimization           = "False"
  tenancy                           = "default"
  backup_tag_value                  = "False"
  detailed_monitoring               = "True"
  ssm_patching_group                = "Group1Patching"
  primary_ebs_volume_size           = "60"
  primary_ebs_volume_iops           = "0"
  primary_ebs_volume_type           = "gp2"
  secondary_ebs_volume_size         = "60"
  secondary_ebs_volume_iops         = "0"
  secondary_ebs_volume_type         = "gp2"
  encrypt_secondary_ebs_volume      = "False"
  environment                       = "Development"
  instance_role_managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEC2FullAccess", "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetRole", "arn:aws:iam::aws:policy/CloudWatchActionsEC2Access"]
  perform_ssm_inventory_tag         = "True"
  cloudwatch_log_retention          = "30"
  ssm_association_refresh_rate      = "rate(1 day)"

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

  additional_ssm_bootstrap_step_count = "1"
  private_ip_address                  = ["10.0.1.131", "10.0.1.132", "10.0.1.133"]
  eip_allocation_id_list              = ["${aws_eip.my_eips.*.id}"]
  eip_allocation_id_count             = "3"
  alarm_notification_topic            = ""
  disable_api_termination             = "False"
  t2_unlimited_mode                   = "standard"
  creation_policy_timeout             = "20m"
  cw_cpu_high_operator                = "GreaterThanThreshold"
  cw_cpu_high_threshold               = "90"
  cw_cpu_high_evaluations             = "15"
  cw_cpu_high_period                  = "60"

  additional_tags = {
    MyTag1 = "MyValue1"
    MyTag2 = "MyValue2"
    MyTag3 = "MyValue3"
  }
}
