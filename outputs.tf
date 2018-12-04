output "ar_instance_id_list" {
  description = "List of resulting Instance IDs"
  value       = ["${split(",",var.secondary_ebs_volume_size != "" ? join(",",coalescelist(aws_instance.mod_ec2_instance_with_secondary_ebs.*.id, list("novalue"))) : join(",",coalescelist(aws_instance.mod_ec2_instance_no_secondary_ebs.*.id, list("novalue"))))}"]
}

output "ar_instance_ip_list" {
  description = "List of resulting Instance IP addresses"
  value       = ["${split(",",var.secondary_ebs_volume_size != "" ? join(",",coalescelist(aws_instance.mod_ec2_instance_with_secondary_ebs.*.private_ip, list("novalue"))) : join(",",coalescelist(aws_instance.mod_ec2_instance_no_secondary_ebs.*.private_ip, list("novalue"))))}"]
}

output "ar_instance_id_ip_zipmap" {
  description = "Map of resulting Instance IDs to Instance IP addresses"
  value       = "${zipmap(output.ar_instance_id_list, output.ar_instance_ip_list)}"
}
