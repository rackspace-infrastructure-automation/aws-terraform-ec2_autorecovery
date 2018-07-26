output "ar_instance_id_list" {
  description = "List of resulting Instance IDs"
  value       = ["${split(",",var.secondary_ebs_volume_size != "" ? join(",",coalescelist(aws_instance.mod_ec2_instance_with_secondary_ebs.*.id, list("novalue"))) : join(",",coalescelist(aws_instance.mod_ec2_instance_no_secondary_ebs.*.id, list("novalue"))))}"]
}
