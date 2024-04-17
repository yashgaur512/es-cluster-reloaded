output "es_node_0_private_ip" {
  value = module.staging_common_es_cluster.es_node_0_private_ip
}

output "es_node_1_private_ip" {
  value = module.staging_common_es_cluster.es_node_1_private_ip
}

output "es_node_2_private_ip" {
  value = module.staging_common_es_cluster.es_node_2_private_ip
}

output "es_nlb_dns_name" {
  value = module.staging_common_es_cluster.nlb_dns_name
}
