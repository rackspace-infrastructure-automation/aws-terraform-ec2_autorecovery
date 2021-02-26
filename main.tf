/**
 * # aws-terraform-ec2_autorecovery
 *
 * This module creates one or more autorecovery instances.
 *
 * ## Basic Usage
 *
 * ```HCL
 * module "ar" {
 *   source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-ec2_autorecovery//?ref=v0.12.15"
 *
 *   ec2_os              = "amazon"
 *   subnets             = module.vpc.private_subnets
 *   name                = "my_ar_instance"
 *   security_groups = [module.sg.private_web_security_group_id]
 * }
 * ```
 * Full working references are available at [examples](examples)
 * **Note** When using an existing EBS snapshot you can not use the encryption variable. The encryption must be set at the snapshot level._
 *
 * ## Other TF Modules Used
 * Using [aws-terraform-cloudwatch_alarm](https://github.com/rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm) to create the following CloudWatch Alarms:
 * - status_check_failed_system_alarm_ticket
 * - status_check_failed_instance_alarm_reboot
 * - status_check_failed_system_alarm_recover
 * - status_check_failed_instance_alarm_ticket
 * - cpu_alarm_high
 *
 * ## Terraform 0.12 upgrade
 *
 * Several changes were required while adding terraform 0.12 compatibility.  The following changes should
 * made when upgrading from a previous release to version 0.12.0 or higher.
 *
 * ### Module variables
 *
 * The following module variables were updated to better meet current Rackspace style guides:
 *
 * - `security_group_list` -> `security_groups`
 * - `resource_name` -> `name`
 * - `additional_tags` -> `tags`
 *
 * The following variables are no longer neccessary and were removed
 *
 * - `additional_ssm_bootstrap_step_count`
 * - `install_scaleft_agent`
 *
 * New variable `ssm_bootstrap_list` was added to allow setting the SSM association steps using objects instead of strings, allowing easier linting and formatting of these lines.  The `additional_ssm_bootstrap_list` variable will continue to work, but will be deprecated in a future release.
 */

terraform {
  required_version = ">= 0.12"

  required_providers {
    aws = ">= 2.7.0"
  }
}

locals {
  ec2_os = lower(var.ec2_os)

  ec2_os_windows_length_test = length(local.ec2_os) >= 7 ? 7 : length(local.ec2_os)
  ec2_os_windows             = substr(local.ec2_os, 0, local.ec2_os_windows_length_test) == "windows" ? true : false

  cw_config_parameter_name = "CWAgent-${var.name}"

  cwagent_config = local.ec2_os_windows ? "windows_cw_agent_param.json" : "linux_cw_agent_param.json"

  ssm_doc_content = {
    schemaVersion = "2.2"
    description   = "SSM Document for instance configuration."
    parameters    = {}
    mainSteps     = local.ssm_command_list
  }

  ssm_command_list = concat(
    local.default_ssm_cmd_list,
    local.ssm_codedeploy_include[var.install_codedeploy_agent],
    [for s in var.additional_ssm_bootstrap_list : jsondecode(s.ssm_add_step)],
    var.ssm_bootstrap_list,
    local.ssm_update_agent
  )

  # This is a list of ssm main steps
  default_ssm_cmd_list = [
    {
      action = "aws:runDocument",
      inputs = {
        documentPath = "arn:aws:ssm:${data.aws_region.current_region.name}:507897595701:document/Rack-BusyWait",
        documentType = "SSMDocument"
      },
      name           = "BusyWait",
      timeoutSeconds = 300
    },
    {
      action = "aws:runDocument",
      inputs = {
        documentPath = "AWS-ConfigureAWSPackage",
        documentParameters = {
          action = "Install",
          name   = "AmazonCloudWatchAgent"
        },
        documentType = "SSMDocument"
      },
      name           = "InstallCWAgent",
      timeoutSeconds = 300
    },
    {
      action = "aws:runDocument",
      inputs = {
        documentPath = "AmazonCloudWatch-ManageAgent",
        documentParameters = {
          action                        = "configure",
          optionalConfigurationSource   = "ssm",
          optionalConfigurationLocation = "${var.provide_custom_cw_agent_config ? var.custom_cw_agent_config_ssm_param : local.cw_config_parameter_name}",
          optionalRestart               = "yes",
          name                          = "AmazonCloudWatchAgent"
        },
        documentType = "SSMDocument"
      },
      name           = "ConfigureCWAgent",
      timeoutSeconds = 300
    },
    {
      action = "aws:runDocument",
      inputs = {
        documentPath = "arn:aws:ssm:${data.aws_region.current_region.name}:507897595701:document/Rack-ConfigureAWSTimeSync",
        documentType = "SSMDocument"
      },
      name           = "SetupTimeSync",
      timeoutSeconds = 300
    },
    {
      action = "aws:runDocument",
      inputs = {
        documentPath = "arn:aws:ssm:${data.aws_region.current_region.name}:507897595701:document/Rack-Install_Package",
        documentParameters = {
          Packages = "sysstat ltrace strace iptraf tcpdump"
        },
        documentType = "SSMDocument"
      },
      name           = "DiagnosticTools",
      timeoutSeconds = 300
    },
  ]

  codedeploy_install = var.install_codedeploy_agent && var.rackspace_managed ? "enabled" : "disabled"
  ssm_codedeploy_include = {
    true = [
      {
        action = "aws:runDocument",
        inputs = {
          documentPath = "arn:aws:ssm:${data.aws_region.current_region.name}:507897595701:document/Rack-Install_CodeDeploy",
          documentType = "SSMDocument"
        },
        name = "InstallCodeDeployAgent"
      }
    ]

    false = []
  }

  ssm_update_agent = [
    {
      action = "aws:runDocument",
      inputs = {
        documentPath = "AWS-UpdateSSMAgent",
        documentType = "SSMDocument"
      },
      name           = "UpdateSSMAgent",
      timeoutSeconds = 300
    },
  ]

  user_data_map = {
    amazon        = "amazon_linux_userdata.sh"
    amazon2       = "amazon_linux_userdata.sh"
    centos6       = "rhel_centos_6_userdata.sh"
    centos7       = "rhel_centos_7_userdata.sh"
    centos8       = "rhel_centos_8_userdata.sh"
    rhel6         = "rhel_centos_6_userdata.sh"
    rhel7         = "rhel_centos_7_userdata.sh"
    rhel8         = "rhel_centos_8_userdata.sh"
    ubuntu14      = "ubuntu_userdata.sh"
    ubuntu16      = "ubuntu_userdata.sh"
    ubuntu18      = "ubuntu_userdata.sh"
    ubuntu20      = "ubuntu_userdata.sh"
    windows2012r2 = "windows_userdata.ps1"
    windows2016   = "windows_userdata.ps1"
    windows2019   = "windows_userdata.ps1"
  }

  ebs_device_map = {
    amazon        = "/dev/sdf"
    amazon2       = "/dev/sdf"
    centos6       = "/dev/sdf"
    centos7       = "/dev/sdf"
    centos8       = "/dev/sdf"
    rhel6         = "/dev/sdf"
    rhel7         = "/dev/sdf"
    rhel8         = "/dev/sdf"
    ubuntu14      = "/dev/sdf"
    ubuntu16      = "/dev/sdf"
    ubuntu18      = "/dev/sdf"
    ubuntu20      = "/dev/sdf"
    windows2012r2 = "xvdf"
    windows2016   = "xvdf"
    windows2019   = "xvdf"
  }

  # local.tags can and should be applied to all taggable resources

  tags = {
    Environment     = var.environment
    ServiceProvider = "Rackspace"
  }

  # local.tags_ec2 is applied to the autorecovery instance

  tags_ec2 = {
    Backup           = var.backup_tag_value
    "Patch Group"    = var.ssm_patching_group
    ServiceProvider  = "Rackspace"
    SSMInventory     = var.perform_ssm_inventory_tag
    "SSM Target Tag" = "Target-${var.name}"
  }

  nfs_install = var.install_nfs && var.rackspace_managed && lookup(local.nfs_packages, local.ec2_os, "") != "" ? "enabled" : "disabled"

  nfs_packages = {
    amazon   = "nfs-utils"
    amazon2  = "nfs-utils"
    centos7  = "nfs-utils"
    ubuntu14 = "nfs-kernel-server rpcbind nfs-common nfs4-acl-tools"
    ubuntu16 = "nfs-kernel-server rpcbind nfs-common nfs4-acl-tools"
    ubuntu18 = "nfs-kernel-server rpcbind nfs-common nfs4-acl-tools"
    ubuntu20 = "nfs-kernel-server rpcbind nfs-common nfs4-acl-tools"
  }

  ssm_nfs_include = {
    enabled = <<EOF
    {
      "action": "aws:runDocument",
      "inputs": {
        "documentType": "SSMDocument",
        "documentPath": "arn:aws:ssm:${data.aws_region.current_region.name}:507897595701:document/Rack-Install_Package",
        "documentParameters": {
          "Packages": "${lookup(local.nfs_packages, local.ec2_os, "")}"
        }
      },
      "name": "InstallNFS"
    },
EOF

    disabled = ""
  }

  ami_owner_mapping = {
    amazon        = "137112412989"
    amazon2       = "137112412989"
    centos6       = "679593333241"
    centos7       = "125523088429"
    centos8       = "125523088429"
    rhel6         = "309956199498"
    rhel7         = "309956199498"
    rhel8         = "309956199498"
    ubuntu14      = "099720109477"
    ubuntu16      = "099720109477"
    ubuntu18      = "099720109477"
    ubuntu20      = "099720109477"
    windows2012r2 = "801119661308"
    windows2016   = "801119661308"
    windows2019   = "801119661308"
  }

  ami_name_mapping = {
    amazon        = "amzn-ami-hvm-2018.03.0.*gp2"
    amazon2       = "amzn2-ami-hvm-2.0.*-ebs"
    centos6       = "CentOS Linux 6 x86_64 HVM EBS*"
    centos7       = "CentOS 7.* x86_64*"
    centos8       = "CentOS 8.* x86_64*"
    rhel6         = "RHEL-6.*_HVM_GA-*x86_64*"
    rhel7         = "RHEL-7.*_HVM_GA-*x86_64*"
    rhel8         = "RHEL-8.*_HVM-*x86_64*"
    ubuntu14      = "*ubuntu-trusty-14.04-amd64-server*"
    ubuntu16      = "*ubuntu-xenial-16.04-amd64-server*"
    ubuntu18      = "ubuntu/images/hvm-ssd/*ubuntu-bionic-18.04-amd64-server*"
    ubuntu20      = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
    windows2012r2 = "Windows_Server-2012-R2_RTM-English-64Bit-Base*"
    windows2016   = "Windows_Server-2016-English-Full-Base*"
    windows2019   = "Windows_Server-2019-English-Full-Base*"
  }

  # Any custom AMI filters for a given OS can be added in this mapping
  image_filter = {
    amazon        = []
    amazon2       = []
    rhel6         = []
    rhel7         = []
    rhel8         = []
    centos7       = []
    centos8       = []
    ubuntu14      = []
    ubuntu16      = []
    ubuntu18      = []
    ubuntu20      = []
    windows2012r2 = []
    windows2016   = []
    windows2019   = []
    # Added to ensure only AMIS under the official CentOS 6 product code are retrieved
    centos6 = [
      {
        name   = "product-code"
        values = ["6x5jmcajty9edm3f211pqjfn2"]
      },
    ]
  }

  standard_filters = [
    {
      name   = "virtualization-type"
      values = ["hvm"]
    },
    {
      name   = "root-device-type"
      values = ["ebs"]
    },
    {
      name   = "name"
      values = [local.ami_name_mapping[local.ec2_os]]
    },
  ]

}

# Lookup the correct AMI based on the region specified
data "aws_ami" "ar_ami" {
  most_recent = true
  owners      = [local.ami_owner_mapping[local.ec2_os]]

  dynamic "filter" {
    for_each = concat(local.standard_filters, local.image_filter[local.ec2_os])
    content {
      name   = filter.value.name
      values = filter.value.values
    }
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/text/${local.user_data_map[local.ec2_os]}")

  vars = {
    initial_commands = var.initial_userdata_commands
    final_commands   = var.final_userdata_commands
  }
}

data "aws_region" "current_region" {}

data "aws_caller_identity" "current_account" {}

#
# IAM Policies
#

data "aws_iam_policy_document" "mod_ec2_assume_role_policy_doc" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "mod_ec2_instance_role_policies" {

  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "ssm:CreateAssociation",
      "ssm:DescribeInstanceInformation",
      "ssm:GetParameter",
    ]
  }

  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListMetrics",
      "cloudwatch:PutMetricData",
      "ec2:DescribeTags",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
    ]
  }

  statement {
    effect    = "Allow"
    resources = ["arn:aws:s3:::rackspace-*/*"]

    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetEncryptionConfiguration",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
    ]
  }
}


data "null_data_source" "instance_ips" {
  count = var.instance_count

  inputs = {
    private_ip = element(
      coalescelist(
        aws_instance.mod_ec2_instance_with_secondary_ebs.*.private_ip,
        aws_instance.mod_ec2_instance_no_secondary_ebs.*.private_ip,
      ),
      count.index,
    )
  }
}

resource "aws_route53_record" "instance" {
  count = var.create_internal_route53 ? var.instance_count : 0

  name    = "${var.name}${var.instance_count > 1 ? format("-%03d.", count.index + 1) : "."}${var.internal_zone_name}"
  records = ["${data.null_data_source.instance_ips[count.index].outputs["private_ip"]}"]
  ttl     = "300"
  type    = "A"
  zone_id = var.internal_zone_id

}
resource "aws_iam_policy" "create_instance_role_policy" {
  count = var.instance_profile_override ? 0 : 1

  description = "Rackspace Instance Role Policies for EC2"
  name        = "InstanceRolePolicy-${var.name}"
  policy      = data.aws_iam_policy_document.mod_ec2_instance_role_policies.json
}

resource "aws_iam_role" "mod_ec2_instance_role" {
  count = var.instance_profile_override ? 0 : 1

  assume_role_policy = data.aws_iam_policy_document.mod_ec2_assume_role_policy_doc.json
  name               = "InstanceRole-${var.name}"
  path               = "/"
}

resource "aws_iam_role_policy_attachment" "attach_core_ssm_policy" {
  count = var.instance_profile_override ? 0 : 1

  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.mod_ec2_instance_role[0].name
}

resource "aws_iam_role_policy_attachment" "attach_cw_ssm_policy" {
  count = var.instance_profile_override ? 0 : 1

  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.mod_ec2_instance_role[0].name
}

resource "aws_iam_role_policy_attachment" "attach_ad_ssm_policy" {
  count = var.instance_profile_override ? 0 : 1

  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMDirectoryServiceAccess"
  role       = aws_iam_role.mod_ec2_instance_role[0].name
}

resource "aws_iam_role_policy_attachment" "attach_codedeploy_policy" {
  count = var.install_codedeploy_agent && var.instance_profile_override != true ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
  role       = aws_iam_role.mod_ec2_instance_role[0].name
}

resource "aws_iam_role_policy_attachment" "attach_instance_role_policy" {
  count = var.instance_profile_override ? 0 : 1

  policy_arn = aws_iam_policy.create_instance_role_policy[0].arn
  role       = aws_iam_role.mod_ec2_instance_role[0].name
}

resource "aws_iam_role_policy_attachment" "attach_additonal_policies" {
  count = var.instance_profile_override ? 0 : var.instance_role_managed_policy_arn_count

  policy_arn = element(var.instance_role_managed_policy_arns, count.index)
  role       = aws_iam_role.mod_ec2_instance_role[0].name
}

resource "aws_iam_instance_profile" "instance_role_instance_profile" {
  count = var.instance_profile_override ? 0 : 1

  name = "InstanceRoleInstanceProfile-${var.name}"
  path = "/"
  role = aws_iam_role.mod_ec2_instance_role[0].name
}

#
# Provisioning of SSM related resources
#

resource "aws_ssm_document" "ssm_bootstrap_doc" {
  content         = jsonencode(local.ssm_doc_content)
  document_format = "JSON"
  document_type   = "Command"
  name            = "SSMDocument-${var.name}"
}

resource "aws_ssm_association" "ssm_bootstrap_assoc" {
  name                = aws_ssm_document.ssm_bootstrap_doc.name
  schedule_expression = var.ssm_association_refresh_rate

  targets {
    key    = "tag:SSM Target Tag"
    values = ["Target-${var.name}"]
  }

  depends_on = [aws_ssm_document.ssm_bootstrap_doc]
}

#
# CloudWatch and Logging
#

locals {
  cwagentparam_vars = {
    application_log = aws_cloudwatch_log_group.application_logs.name
    system_log      = aws_cloudwatch_log_group.system_logs.name
  }

  cwagentparam_object = jsondecode(templatefile("${path.module}/text/${local.cwagent_config}", local.cwagentparam_vars))
}

resource "aws_ssm_parameter" "cwagentparam" {
  count = var.provide_custom_cw_agent_config ? 0 : 1

  description = "${var.name} Cloudwatch Agent configuration"
  name        = local.cw_config_parameter_name
  type        = "String"
  value       = jsonencode(local.cwagentparam_object)
}

resource "aws_cloudwatch_log_group" "system_logs" {
  name              = "${var.name}-SystemLogs"
  retention_in_days = var.cloudwatch_log_retention
}

resource "aws_cloudwatch_log_group" "application_logs" {
  name              = "${var.name}-ApplicationLogs"
  retention_in_days = var.cloudwatch_log_retention
}

data "null_data_source" "alarm_dimensions" {
  count = var.instance_count

  inputs = {
    InstanceId = element(
      coalescelist(
        aws_instance.mod_ec2_instance_with_secondary_ebs.*.id,
        aws_instance.mod_ec2_instance_no_secondary_ebs.*.id,
      ),
      count.index,
    )
  }
}

module "status_check_failed_system_alarm_ticket" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.5"

  alarm_count       = var.instance_count
  alarm_description = "Status checks have failed for system, generating ticket."
  alarm_name = join(
    "-",
    ["StatusCheckFailedSystemAlarmTicket", var.name],
  )
  comparison_operator      = "GreaterThanThreshold"
  dimensions               = data.null_data_source.alarm_dimensions.*.outputs
  evaluation_periods       = "2"
  notification_topic       = [var.notification_topic]
  metric_name              = "StatusCheckFailed_System"
  rackspace_alarms_enabled = true
  rackspace_managed        = var.rackspace_managed
  namespace                = "AWS/EC2"
  period                   = "60"
  severity                 = "emergency"
  statistic                = "Minimum"
  threshold                = "0"
  unit                     = "Count"
}

resource "aws_cloudwatch_metric_alarm" "status_check_failed_instance_alarm_reboot" {
  count = var.enable_recovery_alarms ? var.instance_count : 0

  alarm_description = "Status checks have failed, rebooting system."
  alarm_name = join(
    "-",
    [
      "StatusCheckFailedInstanceAlarmReboot",
      var.name,
      format("%03d", count.index + 1),
    ],
  )
  comparison_operator = "GreaterThanThreshold"
  dimensions          = data.null_data_source.alarm_dimensions[count.index].outputs
  evaluation_periods  = "5"
  metric_name         = "StatusCheckFailed_Instance"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Minimum"
  threshold           = "0"
  unit                = "Count"

  alarm_actions = ["arn:aws:swf:${data.aws_region.current_region.name}:${data.aws_caller_identity.current_account.account_id}:action/actions/AWS_EC2.InstanceId.Reboot/1.0"]
}

resource "aws_cloudwatch_metric_alarm" "status_check_failed_system_alarm_recover" {
  count = var.enable_recovery_alarms ? var.instance_count : 0

  alarm_description = "Status checks have failed for system, recovering instance"
  alarm_name = join(
    "-",
    [
      "StatusCheckFailedSystemAlarmRecover",
      var.name,
      format("%03d", count.index + 1),
    ],
  )
  comparison_operator = "GreaterThanThreshold"
  dimensions          = data.null_data_source.alarm_dimensions[count.index].outputs
  evaluation_periods  = "2"
  metric_name         = "StatusCheckFailed_System"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Minimum"
  threshold           = "0"
  unit                = "Count"

  alarm_actions = ["arn:aws:automate:${data.aws_region.current_region.name}:ec2:recover"]
}

module "status_check_failed_instance_alarm_ticket" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.5"

  alarm_count       = var.instance_count
  alarm_description = "Status checks have failed, generating ticket."
  alarm_name = join(
    "-",
    ["StatusCheckFailedInstanceAlarmTicket", var.name],
  )
  comparison_operator      = "GreaterThanThreshold"
  dimensions               = data.null_data_source.alarm_dimensions.*.outputs
  evaluation_periods       = "10"
  metric_name              = "StatusCheckFailed_Instance"
  notification_topic       = [var.notification_topic]
  namespace                = "AWS/EC2"
  period                   = "60"
  rackspace_alarms_enabled = true
  rackspace_managed        = var.rackspace_managed
  severity                 = "emergency"
  statistic                = "Minimum"
  threshold                = "0"
  unit                     = "Count"
}

module "cpu_alarm_high" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.5"

  alarm_count              = var.instance_count
  alarm_description        = "CPU Alarm ${var.cw_cpu_high_operator} ${var.cw_cpu_high_threshold}% for ${var.cw_cpu_high_period} seconds ${var.cw_cpu_high_evaluations} times."
  alarm_name               = join("-", ["CPUAlarmHigh", var.name])
  comparison_operator      = var.cw_cpu_high_operator
  customer_alarms_enabled  = true
  dimensions               = data.null_data_source.alarm_dimensions.*.outputs
  evaluation_periods       = var.cw_cpu_high_evaluations
  metric_name              = "CPUUtilization"
  notification_topic       = [var.notification_topic]
  namespace                = "AWS/EC2"
  period                   = var.cw_cpu_high_period
  rackspace_alarms_enabled = false
  rackspace_managed        = var.rackspace_managed
  statistic                = "Average"
  threshold                = var.cw_cpu_high_threshold
  unit                     = "Percent"
}

#
# Provisioning of Instance(s)
#

resource "aws_instance" "mod_ec2_instance_no_secondary_ebs" {
  count = var.secondary_ebs_volume_size != "" ? 0 : var.instance_count

  ami                     = var.image_id != "" ? var.image_id : data.aws_ami.ar_ami.image_id
  disable_api_termination = var.disable_api_termination
  ebs_optimized           = var.enable_ebs_optimization
  instance_type           = var.instance_type
  key_name                = var.key_pair
  monitoring              = var.detailed_monitoring
  private_ip              = length(var.private_ip_address) > 0 ? element(var.private_ip_address, count.index) : null
  subnet_id               = element(var.subnets, count.index)
  tags                    = merge(var.tags, local.tags, local.tags_ec2, { Name = "${var.name}${var.instance_count > 1 ? format("-%03d", count.index + 1) : ""}" })
  tenancy                 = var.tenancy
  user_data_base64        = base64encode(data.template_file.user_data.rendered)
  volume_tags             = var.ebs_volume_tags
  vpc_security_group_ids  = var.security_groups

  credit_specification {
    cpu_credits = var.t2_unlimited_mode
  }

  iam_instance_profile = element(
    coalescelist(
      aws_iam_instance_profile.instance_role_instance_profile.*.name,
      [var.instance_profile_override_name],
    ),
    0,
  )

  root_block_device {
    volume_type = var.primary_ebs_volume_type
    volume_size = var.primary_ebs_volume_size
    iops        = var.primary_ebs_volume_iops
    encrypted   = var.encrypt_primary_ebs_volume
    kms_key_id  = var.encrypt_primary_ebs_volume && var.encrypt_primary_ebs_volume_kms_id != "" ? var.encrypt_primary_ebs_volume_kms_id : null
  }

  lifecycle {
    ignore_changes = [
      user_data_base64,
    ]
  }

  timeouts {
    create = var.creation_policy_timeout
  }
}

resource "aws_instance" "mod_ec2_instance_with_secondary_ebs" {
  count = var.secondary_ebs_volume_size != "" ? var.instance_count : 0

  ami                     = var.image_id != "" ? var.image_id : data.aws_ami.ar_ami.image_id
  disable_api_termination = var.disable_api_termination
  ebs_optimized           = var.enable_ebs_optimization
  instance_type           = var.instance_type
  key_name                = var.key_pair
  monitoring              = var.detailed_monitoring
  private_ip              = length(var.private_ip_address) > 0 ? element(var.private_ip_address, count.index) : null
  subnet_id               = element(var.subnets, count.index)
  tags                    = merge(var.tags, local.tags, local.tags_ec2, { Name = "${var.name}${var.instance_count > 1 ? format("-%03d", count.index + 1) : ""}" })
  tenancy                 = var.tenancy
  user_data_base64        = base64encode(data.template_file.user_data.rendered)
  volume_tags             = var.ebs_volume_tags
  vpc_security_group_ids  = var.security_groups

  credit_specification {
    cpu_credits = var.t2_unlimited_mode
  }

  iam_instance_profile = element(
    coalescelist(
      aws_iam_instance_profile.instance_role_instance_profile.*.name,
      [var.instance_profile_override_name],
    ),
    0,
  )

  root_block_device {
    volume_type = var.primary_ebs_volume_type
    volume_size = var.primary_ebs_volume_size
    iops        = var.primary_ebs_volume_iops
    encrypted   = var.encrypt_primary_ebs_volume
    kms_key_id  = var.encrypt_primary_ebs_volume && var.encrypt_primary_ebs_volume_kms_id != "" ? var.encrypt_primary_ebs_volume_kms_id : null
  }

  ebs_block_device {
    device_name = local.ebs_device_map[local.ec2_os]
    volume_type = var.secondary_ebs_volume_type
    volume_size = var.secondary_ebs_volume_size
    iops        = var.secondary_ebs_volume_iops
    encrypted   = var.secondary_ebs_volume_existing_id == "" ? var.encrypt_secondary_ebs_volume : false
    kms_key_id  = var.encrypt_secondary_ebs_volume && var.encrypt_secondary_ebs_volume_kms_id != "" ? var.encrypt_secondary_ebs_volume_kms_id : null
    snapshot_id = var.secondary_ebs_volume_existing_id
  }

  lifecycle {
    ignore_changes = [
      user_data_base64,
    ]
  }

  timeouts {
    create = var.creation_policy_timeout
  }
}

resource "aws_eip_association" "eip_assoc" {
  count = var.eip_allocation_id_count

  # coalescelist and list("novalue") were used here due to element not being able to handle empty lists, even if conditional will not allow portion to execute
  instance_id = element(
    coalescelist(
      aws_instance.mod_ec2_instance_with_secondary_ebs.*.id,
      aws_instance.mod_ec2_instance_no_secondary_ebs.*.id,
    ),
    count.index,
  )
  allocation_id = element(var.eip_allocation_id_list, count.index)
}
