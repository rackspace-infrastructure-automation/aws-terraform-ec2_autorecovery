#
# Instance Attributes
#

variable "creation_policy_timeout" {
  description = "Time to wait for the number of signals for the creation policy. H/M/S Hours/Minutes/Seconds"
  type        = "string"
  default     = "20m"
}

variable "detailed_monitoring" {
  description = "Enable Detailed Monitoring? true or false"
  type        = "string"
  default     = true
}

variable "disable_api_termination" {
  description = "Specifies that an instance should not be able to be deleted via the API. true or false. This option must be toggled to false to allow Terraform to destroy the resource."
  type        = "string"
  default     = false
}

variable "ec2_os" {
  description = "Intended Operating System/Distribution of Instance. Valid inputs are `amazon`, `amazon2`, `centos6`, `centos7`, `rhel6`, `rhel7`, `rhel8`, `ubuntu14`, `ubuntu16`, `ubuntu18`, `windows2008`, `windows2012r2`, `windows2016`, `windows2019`"
  type        = "string"
}

variable "image_id" {
  description = "The AMI ID to be used to build the EC2 Instance. If not provided, an AMI ID will be queried with an OS specified in variable ec2_os."
  type        = "string"
  default     = ""
}

variable "install_codedeploy_agent" {
  description = "Install codedeploy agent on instance(s)? true or false"
  type        = "string"
  default     = false
}

variable "install_scaleft_agent" {
  description = "Install scaleft agent on instance(s)? true or false"
  type        = "string"
  default     = true
}

variable "install_nfs" {
  description = "Install NFS service on instance(s)? true or false"
  type        = "string"
  default     = false
}

variable "instance_count" {
  description = "Number of identical instances to deploy"
  type        = "string"
  default     = "1"
}

variable "instance_type" {
  description = "EC2 Instance Type e.g. 't2.micro'"
  type        = "string"
  default     = "t2.micro"
}

variable "key_pair" {
  description = "Name of an existing EC2 KeyPair to enable SSH access to the instances."
  type        = "string"
  default     = ""
}

variable "resource_name" {
  description = "Name to be used for the provisioned EC2 instance(s) and other resources provisioned in this module"
  type        = "string"
}

variable "security_group_list" {
  description = "A list of security group IDs to assign to this resource. e.g. ['sg-00e88e6a', 'sg-0943cd61', 'sg-2f46c847']"
  type        = "list"
}

variable "t2_unlimited_mode" {
  description = "Determines whether to enable the T2 Unlimited feature.  Only applicable on instance classes that support burstable CPU."
  type        = "string"
  default     = "standard"
}

variable "tenancy" {
  description = "The placement tenancy for EC2 devices. e.g. host, default, dedicated"
  type        = "string"
  default     = "default"
}

#
# EC2 Network
#

variable "subnets" {
  description = "Subnet ID(s) for EC2 Instance(s). If multiple are provided, instances will be distributed amongst them."
  type        = "list"
  default     = []
}

variable "eip_allocation_id_count" {
  description = "A count of supplied eip allocation IDs in variable eip_allocation_id_list"
  type        = "string"
  default     = "0"
}

variable "eip_allocation_id_list" {
  description = "A list of Allocation IDs of the EIPs you want to associate with the instance(s). This is one per instance. e.g. if you specify 2 for instance_count then you must supply two allocation ids  here."
  type        = "list"
  default     = []
}

variable "private_ip_address" {
  description = "A list of static private IP addresses to be configured on the instance.  This IP should be in the assigned subnet and if the instance is replaced, a new IP would need to be assigned. If used, one private IP needs to be provided per instance."
  type        = "list"
  default     = []
}

#
# EBS Attributes
#

variable "backup_tag_value" {
  description = "Value of the 'Backup' tag, used to assign te EBSSnapper configuration"
  type        = "string"
  default     = "False"
}

variable "ebs_volume_tags" {
  description = "(Optional) A mapping of tags to assign to the devices created by the instance at launch time."
  type        = "map"
  default     = {}
}

variable "enable_ebs_optimization" {
  description = "Use EBS Optimized? true or false"
  type        = "string"
  default     = false
}

variable "encrypt_primary_ebs_volume" {
  description = "Encrypt root EBS Volume? true or false"
  type        = "string"
  default     = false
}

variable "encrypt_primary_ebs_volume_kms_id" {
  description = "If `encrypt_primary_ebs_volume` is `true` you can optionally provide a KMS CMK ARN."
  type        = "string"
  default     = ""
}

variable "encrypt_secondary_ebs_volume" {
  description = "Encrypt secondary EBS Volume? true or false"
  type        = "string"
  default     = false
}

variable "encrypt_secondary_ebs_volume_kms_id" {
  description = "If `encrypt_secondary_ebs_volume` is `true` you can optionally provide a KMS CMK ARN."
  type        = "string"
  default     = ""
}

variable "primary_ebs_volume_iops" {
  description = "Iops value required for use with io1 EBS volumes. This value should be 3 times the EBS volume size"
  type        = "string"
  default     = "0"
}

variable "primary_ebs_volume_size" {
  description = "EBS Volume Size in GB"
  type        = "string"
  default     = "60"
}

variable "primary_ebs_volume_type" {
  description = "EBS Volume Type. e.g. gp2, io1, st1, sc1"
  type        = "string"
  default     = "gp2"
}

variable "secondary_ebs_volume_existing_id" {
  description = "The Snapshot ID of an existing EBS volume you want to use for the secondary volume. i.e. snap-0ad8580e3ac34a9f1"
  type        = "string"
  default     = ""
}

variable "secondary_ebs_volume_iops" {
  description = "Iops value required for use with io1 EBS volumes. This value should be 3 times the EBS volume size"
  type        = "string"
  default     = "0"
}

variable "secondary_ebs_volume_size" {
  description = "EBS Volume Size in GB"
  type        = "string"
  default     = ""
}

variable "secondary_ebs_volume_type" {
  description = "EBS Volume Type. e.g. gp2, io1, st1, sc1"
  type        = "string"
  default     = "gp2"
}

#
# EC2 Tagging
#

variable "additional_tags" {
  description = "Additional tags to be added to the EC2 instance Please see usage.tf.example in this repo for examples."
  type        = "map"
  default     = {}
}

variable "environment" {
  description = "Application environment for which this network is being created. Preferred value are Development, Integration, PreProduction, Production, QA, Staging, or Test"
  type        = "string"
  default     = "Development"
}

#
# SSM and Associations
#

variable "additional_ssm_bootstrap_list" {
  description = "A list of maps consisting of main step actions, to be appended to SSM associations. Please see usage.tf.example in this repo for examples."
  type        = "list"
  default     = []
}

variable "additional_ssm_bootstrap_step_count" {
  description = "Count of steps added for input 'additional_ssm_bootstrap_list'. This is required since 'additional_ssm_bootstrap_list' is a list of maps"
  type        = "string"
  default     = "0"
}

variable "perform_ssm_inventory_tag" {
  description = "Determines whether Instance is tracked via System Manager Inventory."
  type        = "string"
  default     = "True"
}

variable "rackspace_managed" {
  description = "Boolean parameter controlling if instance will be fully managed by Rackspace support teams, created CloudWatch alarms that generate tickets, and utilize Rackspace managed SSM documents."
  type        = "string"
  default     = true
}

variable "ssm_association_refresh_rate" {
  description = "A cron or rate pattern to define the SSM Association refresh schedule, defaulting to once per day. See https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-cron.html for more details. Schedule can be disabled by providing an empty string."
  type        = "string"
  default     = "rate(1 day)"
}

variable "ssm_patching_group" {
  description = "Group ID to be used by System Manager for Patching. This is the value to be used for tag 'Patch Group'"
  type        = "string"
  default     = ""
}

#
# CloudWatch and Logs
#

variable "notification_topic" {
  description = "SNS Topic ARN to notify if there are any alarms"
  type        = "string"
  default     = ""
}

variable "cloudwatch_log_retention" {
  description = "The number of days to retain Cloudwatch Logs for this instance."
  type        = "string"
  default     = "30"
}

variable "cw_cpu_high_evaluations" {
  description = "The number of periods over which data is compared to the specified threshold."
  type        = "string"
  default     = "15"
}

variable "cw_cpu_high_operator" {
  description = "Math operator used by CloudWatch for alarms and triggers."
  type        = "string"
  default     = "GreaterThanThreshold"
}

variable "cw_cpu_high_period" {
  description = "Time the specified statistic is applied. Must be in seconds that is also a multiple of 60."
  type        = "string"
  default     = "60"
}

variable "cw_cpu_high_threshold" {
  description = "The value against which the specified statistic is compared."
  type        = "string"
  default     = "90"
}

variable "enable_recovery_alarms" {
  description = "Boolean parameter controlling if auto-recovery alarms should be created.  Recovery actions are not supported on all instance types and AMIs, especially those with ephemeral storage.  This parameter should be set to false for those cases."
  type        = "string"
  default     = true
}

variable "provide_custom_cw_agent_config" {
  description = "Set to true if a custom cloudwatch agent configuration has been provided in variable custom_cw_agent_config_ssm_param."
  type        = "string"
  default     = false
}

variable "custom_cw_agent_config_ssm_param" {
  description = "SSM Parameter Store name that contains a custom CloudWatch agent configuration that you would like to use as an alternative to the default provided."
  type        = "string"
  default     = ""
}

#
# Roles and Policies
#

variable "instance_profile_override" {
  description = "Optionally provide an instance profile. Any override profile should contain the permissions required for Rackspace support tooling to continue to function if required."
  type        = "string"
  default     = false
}

variable "instance_profile_override_name" {
  description = "Provide an instance profile name. Any override profile should contain the permissions required for Rackspace support tooling to continue to function if required. To use this set `instance_profile_override` to `true`."
  type        = "string"
  default     = ""
}

variable "instance_role_managed_policy_arns" {
  description = "List of IAM policy ARNs for the InstanceRole IAM role. IAM ARNs can be found within the Policies section of the AWS IAM console. e.g. ['arn:aws:iam::aws:policy/AmazonEC2FullAccess', 'arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM', 'arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetRole']"
  type        = "list"
  default     = []
}

variable "instance_role_managed_policy_arn_count" {
  description = "The number of policy ARNs provided/set in variable 'instance_role_managed_policy_arns'"
  type        = "string"
  default     = "0"
}

variable "initial_userdata_commands" {
  description = "Commands to be given at the start of userdata for an instance. This should generally not include bootstrapping or ssm install."
  type        = "string"
  default     = ""
}

variable "final_userdata_commands" {
  description = "Commands to be given at the end of userdata for an instance. This should generally not include bootstrapping or ssm install."
  type        = "string"
  default     = ""
}
