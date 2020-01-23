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

module "ec2_ar" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-ec2_autorecovery?ref=v0.12.0"

  backup_tag_value             = "False"
  detailed_monitoring          = "True"
  ec2_os                       = "centos7"
  enable_ebs_optimization      = "False"
  encrypt_secondary_ebs_volume = "False"
  image_id                     = data.aws_ami.amazon_centos_7.image_id
  install_codedeploy_agent     = "False"
  instance_count               = "3"
  instance_type                = "t2.micro"
  key_pair                     = "mcardenas_testing"
  name                         = "my_test_instance"
  primary_ebs_volume_iops      = "0"
  primary_ebs_volume_size      = "60"
  primary_ebs_volume_type      = "gp2"
  secondary_ebs_volume_iops    = "0"
  secondary_ebs_volume_size    = "60"
  secondary_ebs_volume_type    = "gp2"
  security_groups              = [module.vpc.default_sg]
  ssm_patching_group           = "Group1Patching"
  subnets                      = module.vpc.public_subnets
  tenancy                      = "default"

  # Use Snapshot ID
  //  use_existing_ebs_snapshot = true
  //  secondary_ebs_volume_existing_id = "snap-39203923"
  environment = "Development"

  instance_role_managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEC2FullAccess", "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetRole", "arn:aws:iam::aws:policy/CloudWatchActionsEC2Access"]
  perform_ssm_inventory_tag         = "True"
  cloudwatch_log_retention          = "30"
  ssm_association_refresh_rate      = "rate(1 day)"

  ssm_bootstrap_list = [
    {
      action = "aws:runDocument",
      inputs = {
        documentPath = "arn:aws:ssm:${data.aws_region.current_region.name}:507897595701:document/Rack-Install_Package",
        documentParameters = {
          Packages = "bind bindutils"
        },
        documentType = "SSMDocument"
      },
      name           = "InstallBindAndTools",
      timeoutSeconds = 300
    },
    {
      action = "aws:runDocument",
      inputs = {
        documentPath = "AWS-RunShellScript",
        documentParameters = {
          commands = ["touch /tmp/myfile"]
        },
        documentType = "SSMDocument"
      },
      name           = "CreateFile",
      timeoutSeconds = 300
    },
  ]

  creation_policy_timeout = "20m"
  cw_cpu_high_evaluations = "15"
  cw_cpu_high_operator    = "GreaterThanThreshold"
  cw_cpu_high_period      = "60"
  cw_cpu_high_threshold   = "90"
  disable_api_termination = "False"
  eip_allocation_id_count = "3"
  eip_allocation_id_list  = [aws_eip.my_eips.*.id]
  notification_topic      = ""
  private_ip_address      = ["10.0.1.131", "10.0.1.132", "10.0.1.133"]
  t2_unlimited_mode       = "standard"

  tags = {
    MyTag1 = "MyValue1"
    MyTag2 = "MyValue2"
    MyTag3 = "MyValue3"
  }
}
