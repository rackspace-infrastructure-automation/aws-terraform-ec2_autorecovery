output "ar_image_id" {
  description = "Image ID used for EC2 provisioning"
  value       = var.image_id != "" ? var.image_id : data.aws_ami.ar_ami.image_id
}

output "ar_instance_az_list" {
  description = "List of resulting Instance availability zones"

  value = concat(
    aws_instance.mod_ec2_instance_with_secondary_ebs.*.availability_zone,
    aws_instance.mod_ec2_instance_no_secondary_ebs.*.availability_zone,
  )
}

output "ar_instance_id_list" {
  description = "List of resulting Instance IDs"

  value = concat(
    aws_instance.mod_ec2_instance_with_secondary_ebs.*.id,
    aws_instance.mod_ec2_instance_no_secondary_ebs.*.id,
  )
}

output "ar_instance_ip_list" {
  description = "List of resulting Instance IP addresses"

  value = concat(
    aws_instance.mod_ec2_instance_with_secondary_ebs.*.private_ip,
    aws_instance.mod_ec2_instance_no_secondary_ebs.*.private_ip,
  )
}

output "ar_instance_r53_name_list" {
  description = "List of resulting Route 53 internal records"
  value       = var.create_internal_route53 ? aws_route53_record.instance.*.fqdn : []
}
