output "ar_instance_id_list" {
  description = "List of resulting Instance IDs"

  value = "${concat(aws_instance.mod_ec2_instance_with_secondary_ebs.*.id, aws_instance.mod_ec2_instance_no_secondary_ebs.*.id)}"
}

output "ar_instance_ip_list" {
  description = "List of resulting Instance IP addresses"

  value = "${concat(aws_instance.mod_ec2_instance_with_secondary_ebs.*.private_ip, aws_instance.mod_ec2_instance_no_secondary_ebs.*.private_ip)}"
}

output "ar_instance_id_ip_zipmap" {
  description = "Map of resulting Instance IDs to Instance IP addresses"
  value       = "${zipmap(concat(aws_instance.mod_ec2_instance_with_secondary_ebs.*.id, aws_instance.mod_ec2_instance_no_secondary_ebs.*.id), concat(aws_instance.mod_ec2_instance_with_secondary_ebs.*.private_ip, aws_instance.mod_ec2_instance_no_secondary_ebs.*.private_ip))}"
}
