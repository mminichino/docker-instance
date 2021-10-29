output lab-id {
    value = "lab-${random_id.labid.hex}"
}

output "node-public" {
    value = aws_instance.docker_node.public_ip
}

output "inventory_db" {
    value = aws_instance.docker_node.private_ip
}

output "node-name" {
  value = "${lookup(aws_instance.docker_node.tags, "Name")}"
}
