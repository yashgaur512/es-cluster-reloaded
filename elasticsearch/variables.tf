variable "es_node_0_name" {}
variable "es_node_1_name" {}
variable "es_node_2_name" {}
variable "route53_zone_id" {}
variable "es_node0_domain" {}
variable "es_node1_domain" {}
variable "es_node2_domain" {}
variable "region" {}

variable "main_vpc_id" {}
variable "target_group_protocol" {}
variable "target_group_target_type" {}

variable "target_group_deregistration_delay" {}
variable "target_group_health_check_timeout" {}
variable "target_group_health_check_healthy_threshold" {}
variable "target_group_health_check_unhealthy_threshold" {}
variable "target_group_health_check_interval" {}
variable "target_group_health_check_matcher" {}

variable "people_es_target_group_port" {}
variable "people_es_target_group_name" {}
variable "people_es_target_group_health_check_path" {}
variable "people_kibana_target_group_port" {}
variable "people_kibana_target_group_name" {}
variable "people_kibana_target_group_health_check_path" {}

variable "team" {}
variable "sprinto_tag" {}
variable "experimentation_tag" {}
variable "environment" {}
variable "availability_zone" {}
variable "vpc_cidr_blocks" {}
variable "instance_type" {}
variable "labs_core_web_sg" {}
variable "labs_core_worker_sg" {}
variable "labs_core_elb_sg" {}
variable "monitoring_node_sg" {}
variable "data_manager_ephemeral_sg" {}
variable "ssh_key_pair_name" {}
variable "subnet_id" {}
variable "root_volume_size" {}
variable "delete_root_volume_on_termination" {}
variable "ebs_volume_size" {}
variable "zone_name" {}

variable "es_node_0_user_data" {
  default = "./scripts/user-data-node-0.sh"
  type    = string
}

variable "es_node_1_user_data" {
  default = "./scripts/user-data-node-1.sh"
  type    = string
}

variable "es_node_2_user_data" {
  default = "./scripts/user-data-node-2.sh"
  type    = string
}

variable "people_es_cluster_profile_name" {}
