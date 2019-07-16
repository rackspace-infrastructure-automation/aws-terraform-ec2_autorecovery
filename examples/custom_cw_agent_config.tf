provider "aws" {
  region = "us-west-2"
}

resource "random_string" "res_name" {
  length  = 8
  upper   = false
  lower   = true
  special = false
  number  = false
}

module "vpc" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork?ref=v0.0.9"

  vpc_name = "EC2-AR-BaseNetwork-Test1"
}

data "aws_region" "current_region" {}

module "ec2_ar_with_codedeploy" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-ec2_autorecovery?ref=v0.0.20"

  ec2_os         = "rhel6"
  instance_count = "1"
  subnets        = "${module.vpc.private_subnets}"

  security_group_list = [
    "${module.vpc.default_sg}",
  ]

  key_pair                         = "CircleCI"
  instance_type                    = "t2.micro"
  resource_name                    = "ar_ec2_codedeploy-${random_string.res_name.result}"
  install_codedeploy_agent         = true
  enable_ebs_optimization          = false
  tenancy                          = "default"
  backup_tag_value                 = "False"
  detailed_monitoring              = true
  ssm_patching_group               = "Group1Patching"
  primary_ebs_volume_size          = "60"
  primary_ebs_volume_iops          = "0"
  primary_ebs_volume_type          = "gp2"
  encrypt_secondary_ebs_volume     = "False"
  environment                      = "Development"
  perform_ssm_inventory_tag        = true
  cloudwatch_log_retention         = "30"
  ssm_association_refresh_rate     = "rate(1 day)"
  notification_topic               = ""
  disable_api_termination          = false
  t2_unlimited_mode                = "standard"
  creation_policy_timeout          = "20m"
  cw_cpu_high_operator             = "GreaterThanThreshold"
  cw_cpu_high_threshold            = "90"
  cw_cpu_high_evaluations          = "15"
  cw_cpu_high_period               = "60"
  provide_custom_cw_agent_config   = true
  custom_cw_agent_config_ssm_param = "${aws_ssm_parameter.custom_cwagentparam.name}"
}

resource "aws_ssm_parameter" "custom_cwagentparam" {
  name        = "custom_cw_param-${random_string.res_name.result}"
  description = "Custom Cloudwatch Agent configuration"
  type        = "String"
  value       = "${data.template_file.custom_cwagentparam.rendered}"
}

data "template_file" "custom_cwagentparam" {
  template = "${file("./text/linux_cw_agent_param.json")}"

  vars {
    application_log_group_name = "custom_app_log_group_name"
    system_log_group_name      = "custom_system_log_group_name"
  }
}
