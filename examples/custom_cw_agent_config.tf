provider "aws" {
  version = "~> 2.7"
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
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork?ref=v0.12.1"

  name = "EC2-AR-BaseNetwork-Test1"
}

module "ec2_ar_with_codedeploy" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-ec2_autorecovery?ref=v0.12.8"

  ec2_os         = "rhel6"
  instance_count = 1
  subnets        = module.vpc.private_subnets

  security_groups = [module.vpc.default_sg]

  backup_tag_value                 = "False"
  cloudwatch_log_retention         = 30
  creation_policy_timeout          = "20m"
  custom_cw_agent_config_ssm_param = aws_ssm_parameter.custom_cwagentparam.name
  cw_cpu_high_evaluations          = 15
  cw_cpu_high_operator             = "GreaterThanThreshold"
  cw_cpu_high_period               = 60
  cw_cpu_high_threshold            = 90
  detailed_monitoring              = true
  disable_api_termination          = false
  enable_ebs_optimization          = false
  encrypt_secondary_ebs_volume     = false
  environment                      = "Development"
  install_codedeploy_agent         = true
  instance_type                    = "t2.micro"
  key_pair                         = "CircleCI"
  name                             = "ar_ec2_codedeploy-${random_string.res_name.result}"
  notification_topic               = ""
  perform_ssm_inventory_tag        = true
  primary_ebs_volume_iops          = 0
  primary_ebs_volume_size          = 60
  primary_ebs_volume_type          = "gp2"
  provide_custom_cw_agent_config   = true
  ssm_association_refresh_rate     = "rate(1 day)"
  ssm_patching_group               = "Group1Patching"
  t2_unlimited_mode                = "standard"
  tenancy                          = "default"
}

resource "aws_ssm_parameter" "custom_cwagentparam" {
  name        = "custom_cw_param-${random_string.res_name.result}"
  description = "Custom Cloudwatch Agent configuration"
  type        = "String"
  value       = data.template_file.custom_cwagentparam.rendered
}

data "template_file" "custom_cwagentparam" {
  template = file("./text/linux_cw_agent_param.json")

  vars = {
    application_log_group_name = "custom_app_log_group_name"
    system_log_group_name      = "custom_system_log_group_name"
  }
}
