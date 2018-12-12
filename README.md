# aws-terraform-ec2_autorecovery

This module creates one or more autorecovery instances.

## Basic Usage

```
module "ar" {
 source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-ec2_autorecovery//?ref=v0.0.2"

 ec2_os              = "amazon"
 subnets             = ["${module.vpc.private_subnets}"]
 image_id            = "${var.image_id}"
 resource_name       = "my_ar_instance"
 security_group_list = ["${module.sg.private_web_security_group_id}"]
}
```

Full working references are available at [examples](examples)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| additional_ssm_bootstrap_list | A list of maps consisting of main step actions, to be appended to SSM associations. Please see usage.tf.example in this repo for examples. | list | `<list>` | no |
| additional_ssm_bootstrap_step_count | Count of steps added for input 'additional_ssm_bootstrap_list'. This is required since 'additional_ssm_bootstrap_list' is a list of maps | string | `0` | no |
| additional_tags | Additional tags to be added to the EC2 instance Please see usage.tf.example in this repo for examples. | map | `<map>` | no |
| alarm_notification_topic | SNS Topic ARN to notify if there are any alarms | string | `` | no |
| backup_tag_value | Value of the 'Backup' tag, used to assign te EBSSnapper configuration | string | `False` | no |
| cloudwatch_log_retention | The number of days to retain Cloudwatch Logs for this instance. | string | `30` | no |
| creation_policy_timeout | Time to wait for the number of signals for the creation policy. H/M/S Hours/Minutes/Seconds | string | `20m` | no |
| cw_cpu_high_evaluations | The number of periods over which data is compared to the specified threshold. | string | `15` | no |
| cw_cpu_high_operator | Math operator used by CloudWatch for alarms and triggers. | string | `GreaterThanThreshold` | no |
| cw_cpu_high_period | Time the specified statistic is applied. Must be in seconds that is also a multiple of 60. | string | `60` | no |
| cw_cpu_high_threshold | The value against which the specified statistic is compared. | string | `90` | no |
| detailed_monitoring | Enable Detailed Monitoring? true or false | string | `true` | no |
| disable_api_termination | Specifies that an instance should not be able to be deleted via the API. true or false. This option must be toggled to false to allow Terraform to destroy the resource. | string | `false` | no |
| ebs_volume_tags | (Optional) A mapping of tags to assign to the devices created by the instance at launch time. | map | `<map>` | no |
| ec2_os | Intended Operating System/Distribution of Instance. Valid inputs are ('amazon', 'rhel6', 'rhel7', 'centos6', 'centos7', 'ubuntu14', 'ubuntu16', 'windows') | string | - | yes |
| eip_allocation_id_count | A count of supplied eip allocation IDs in variable eip_allocation_id_list | string | `0` | no |
| eip_allocation_id_list | A list of Allocation IDs of the EIPs you want to associate with the instance(s). This is one per instance. e.g. if you specify 2 for instance_count then you must supply two allocation ids  here. | list | `<list>` | no |
| enable_ebs_optimization | Use EBS Optimized? true or false | string | `false` | no |
| encrypt_secondary_ebs_volume | Encrypt EBS Volume? true or false | string | `false` | no |
| environment | Application environment for which this network is being created. Preferred value are Development, Integration, PreProduction, Production, QA, Staging, or Test | string | `Development` | no |
| final_userdata_commands | Commands to be given at the end of userdata for an instance. This should generally not include bootstrapping or ssm install. | string | `` | no |
| image_id | The AMI ID to be used to build the EC2 Instance. | string | - | yes |
| initial_userdata_commands | Commands to be given at the start of userdata for an instance. This should generally not include bootstrapping or ssm install. | string | `` | no |
| install_codedeploy_agent | Install codedeploy agent on instance(s)? true or false | string | `false` | no |
| instance_count | Number of identical instances to deploy | string | `1` | no |
| instance_role_managed_policy_arn_count | The number of policy ARNs provided/set in variable 'instance_role_managed_policy_arns' | string | `0` | no |
| instance_role_managed_policy_arns | List of IAM policy ARNs for the InstanceRole IAM role. IAM ARNs can be found within the Policies section of the AWS IAM console. e.g. ['arn:aws:iam::aws:policy/AmazonEC2FullAccess', 'arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM', 'arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetRole'] | list | `<list>` | no |
| instance_type | EC2 Instance Type e.g. 't2.micro' | string | `t2.micro` | no |
| key_pair | Name of an existing EC2 KeyPair to enable SSH access to the instances. | string | `` | no |
| perform_ssm_inventory_tag | Determines whether Instance is tracked via System Manager Inventory. | string | `True` | no |
| primary_ebs_volume_iops | Iops value required for use with io1 EBS volumes. This value should be 3 times the EBS volume size | string | `0` | no |
| primary_ebs_volume_size | EBS Volume Size in GB | string | `60` | no |
| primary_ebs_volume_type | EBS Volume Type. e.g. gp2, io1, st1, sc1 | string | `gp2` | no |
| private_ip_address | A list of static private IP addresses to be configured on the instance.  This IP should be in the assigned subnet and if the instance is replaced, a new IP would need to be assigned. If used, one private IP needs to be provided per instance. | list | `<list>` | no |
| rackspace_managed | Boolean parameter controlling if instance will be fully managed by Rackspace support teams, created CloudWatch alarms that generate tickets, and utilize Rackspace managed SSM documents. | string | `true` | no |
| resource_name | Name to be used for the provisioned EC2 instance(s) and other resources provisioned in this module | string | - | yes |
| secondary_ebs_volume_iops | Iops value required for use with io1 EBS volumes. This value should be 3 times the EBS volume size | string | `0` | no |
| secondary_ebs_volume_size | EBS Volume Size in GB | string | `` | no |
| secondary_ebs_volume_type | EBS Volume Type. e.g. gp2, io1, st1, sc1 | string | `gp2` | no |
| security_group_list | A list of security group IDs to assign to this resource. e.g. ['sg-00e88e6a', 'sg-0943cd61', 'sg-2f46c847'] | list | - | yes |
| ssm_association_refresh_rate | A cron or rate pattern to define the SSM Association refresh schedule, defaulting to once per day. See https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-cron.html for more details. Schedule can be disabled by providing an empty string. | string | `rate(1 day)` | no |
| ssm_patching_group | Group ID to be used by System Manager for Patching. This is the value to be used for tag 'Patch Group' | string | `` | no |
| subnets | Subnet ID(s) for EC2 Instance(s). If multiple are provided, instances will be distributed amongst them. | list | `<list>` | no |
| t2_unlimited_mode | Determines whether to enable the T2 Unlimited feature.  Only applicable on instance classes that support burstable CPU. | string | `standard` | no |
| tenancy | The placement tenancy for EC2 devices. e.g. host, default, dedicated | string | `default` | no |

## Outputs

| Name | Description |
|------|-------------|
| ar_instance_id_list | List of resulting Instance IDs |
| ar_instance_ip_list | List of resulting Instance IP addresses |
