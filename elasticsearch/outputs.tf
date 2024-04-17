output "es_node_0_private_ip" {
  value = module.es_node_0.instance.private_ip
}

output "es_node_1_private_ip" {
  value = module.es_node_1.instance.private_ip
}

output "es_node_2_private_ip" {
  value = module.es_node_2.instance.private_ip
}

output "nlb_dns_name" {
  value = module.nlb.lb.dns_name
}
