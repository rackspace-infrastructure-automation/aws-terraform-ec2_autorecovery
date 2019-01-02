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
| additional\_ssm\_bootstrap\_list | A list of maps consisting of main step actions, to be appended to SSM associations. Please see usage.tf.example in this repo for examples. | list | `<list>` | no |
| additional\_ssm\_bootstrap\_step\_count | Count of steps added for input 'additional_ssm_bootstrap_list'. This is required since 'additional_ssm_bootstrap_list' is a list of maps | string | `"0"` | no |
| additional\_tags | Additional tags to be added to the EC2 instance Please see usage.tf.example in this repo for examples. | map | `<map>` | no |
| alarm\_notification\_topic | SNS Topic ARN to notify if there are any alarms | string | `""` | no |
| backup\_tag\_value | Value of the 'Backup' tag, used to assign te EBSSnapper configuration | string | `"False"` | no |
| cloudwatch\_log\_retention | The number of days to retain Cloudwatch Logs for this instance. | string | `"30"` | no |
| creation\_policy\_timeout | Time to wait for the number of signals for the creation policy. H/M/S Hours/Minutes/Seconds | string | `"20m"` | no |
| cw\_cpu\_high\_evaluations | The number of periods over which data is compared to the specified threshold. | string | `"15"` | no |
| cw\_cpu\_high\_operator | Math operator used by CloudWatch for alarms and triggers. | string | `"GreaterThanThreshold"` | no |
| cw\_cpu\_high\_period | Time the specified statistic is applied. Must be in seconds that is also a multiple of 60. | string | `"60"` | no |
| cw\_cpu\_high\_threshold | The value against which the specified statistic is compared. | string | `"90"` | no |
| detailed\_monitoring | Enable Detailed Monitoring? true or false | string | `"true"` | no |
| disable\_api\_termination | Specifies that an instance should not be able to be deleted via the API. true or false. This option must be toggled to false to allow Terraform to destroy the resource. | string | `"false"` | no |
| ebs\_volume\_tags | (Optional) A mapping of tags to assign to the devices created by the instance at launch time. | map | `<map>` | no |
| ec2\_os | Intended Operating System/Distribution of Instance. Valid inputs are ('amazon', 'rhel6', 'rhel7', 'centos6', 'centos7', 'ubuntu14', 'ubuntu16', 'windows2008', 'windows2012R2', 'windows2016') | string | n/a | yes |
| eip\_allocation\_id\_count | A count of supplied eip allocation IDs in variable eip_allocation_id_list | string | `"0"` | no |
| eip\_allocation\_id\_list | A list of Allocation IDs of the EIPs you want to associate with the instance(s). This is one per instance. e.g. if you specify 2 for instance_count then you must supply two allocation ids  here. | list | `<list>` | no |
| enable\_ebs\_optimization | Use EBS Optimized? true or false | string | `"false"` | no |
| encrypt\_secondary\_ebs\_volume | Encrypt EBS Volume? true or false | string | `"false"` | no |
| environment | Application environment for which this network is being created. Preferred value are Development, Integration, PreProduction, Production, QA, Staging, or Test | string | `"Development"` | no |
| final\_userdata\_commands | Commands to be given at the end of userdata for an instance. This should generally not include bootstrapping or ssm install. | string | `""` | no |
| image\_id | The AMI ID to be used to build the EC2 Instance. If not provided, an AMI ID will be queried with an OS specified in variable ec2_os. | string | `""` | no |
| initial\_userdata\_commands | Commands to be given at the start of userdata for an instance. This should generally not include bootstrapping or ssm install. | string | `""` | no |
| install\_codedeploy\_agent | Install codedeploy agent on instance(s)? true or false | string | `"false"` | no |
| install\_nfs | Install NFS service on instance(s)? true or false | string | `"false"` | no |
| instance\_count | Number of identical instances to deploy | string | `"1"` | no |
| instance\_role\_managed\_policy\_arn\_count | The number of policy ARNs provided/set in variable 'instance_role_managed_policy_arns' | string | `"0"` | no |
| instance\_role\_managed\_policy\_arns | List of IAM policy ARNs for the InstanceRole IAM role. IAM ARNs can be found within the Policies section of the AWS IAM console. e.g. ['arn:aws:iam::aws:policy/AmazonEC2FullAccess', 'arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM', 'arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetRole'] | list | `<list>` | no |
| instance\_type | EC2 Instance Type e.g. 't2.micro' | string | `"t2.micro"` | no |
| key\_pair | Name of an existing EC2 KeyPair to enable SSH access to the instances. | string | `""` | no |
| perform\_ssm\_inventory\_tag | Determines whether Instance is tracked via System Manager Inventory. | string | `"True"` | no |
| primary\_ebs\_volume\_iops | Iops value required for use with io1 EBS volumes. This value should be 3 times the EBS volume size | string | `"0"` | no |
| primary\_ebs\_volume\_size | EBS Volume Size in GB | string | `"60"` | no |
| primary\_ebs\_volume\_type | EBS Volume Type. e.g. gp2, io1, st1, sc1 | string | `"gp2"` | no |
| private\_ip\_address | A list of static private IP addresses to be configured on the instance.  This IP should be in the assigned subnet and if the instance is replaced, a new IP would need to be assigned. If used, one private IP needs to be provided per instance. | list | `<list>` | no |
| rackspace\_managed | Boolean parameter controlling if instance will be fully managed by Rackspace support teams, created CloudWatch alarms that generate tickets, and utilize Rackspace managed SSM documents. | string | `"true"` | no |
| resource\_name | Name to be used for the provisioned EC2 instance(s) and other resources provisioned in this module | string | n/a | yes |
| secondary\_ebs\_volume\_iops | Iops value required for use with io1 EBS volumes. This value should be 3 times the EBS volume size | string | `"0"` | no |
| secondary\_ebs\_volume\_size | EBS Volume Size in GB | string | `""` | no |
| secondary\_ebs\_volume\_type | EBS Volume Type. e.g. gp2, io1, st1, sc1 | string | `"gp2"` | no |
| security\_group\_list | A list of security group IDs to assign to this resource. e.g. ['sg-00e88e6a', 'sg-0943cd61', 'sg-2f46c847'] | list | n/a | yes |
| ssm\_association\_refresh\_rate | A cron or rate pattern to define the SSM Association refresh schedule, defaulting to once per day. See https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-cron.html for more details. Schedule can be disabled by providing an empty string. | string | `"rate(1 day)"` | no |
| ssm\_patching\_group | Group ID to be used by System Manager for Patching. This is the value to be used for tag 'Patch Group' | string | `""` | no |
| subnets | Subnet ID(s) for EC2 Instance(s). If multiple are provided, instances will be distributed amongst them. | list | `<list>` | no |
| t2\_unlimited\_mode | Determines whether to enable the T2 Unlimited feature.  Only applicable on instance classes that support burstable CPU. | string | `"standard"` | no |
| tenancy | The placement tenancy for EC2 devices. e.g. host, default, dedicated | string | `"default"` | no |

## Outputs

| Name | Description |
|------|-------------|
| ar\_image\_id | Image ID used for EC2 provisioning |
| ar\_instance\_id\_list | List of resulting Instance IDs |
| ar\_instance\_ip\_list | List of resulting Instance IP addresses |

