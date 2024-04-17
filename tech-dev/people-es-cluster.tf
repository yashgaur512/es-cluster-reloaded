module "people_es_cluster" {
  source                          = "../elasticsearch"
  es_node_0_name                  = var.es_node_0_name
  es_node_1_name                  = var.es_node_1_name
  es_node_2_name                  = var.es_node_2_name
  route53_zone_id                 = "Z0599858291533W9UYM7N"
  region                          = "us-east-1"
  availability_zone               = "us-east-1a"
  vpc_cidr_blocks                 = ["172.16.0.0/16"]
  instance_type                   = "m6g.large"
  main_vpc_id                     = "vpc-02b39b7ef9d391098"
  target_group_protocol           = "TLS"
  target_group_target_type        = "instance"
  target_group_deregistration_delay             = "300"
  target_group_health_check_timeout             = 5
  target_group_health_check_healthy_threshold   = 5
  target_group_health_check_unhealthy_threshold = 2
  target_group_health_check_interval            = 20
  target_group_health_check_matcher             = "200"

  people_es_target_group_port                  = 9200
  people_es_target_group_name                  = "people-es-cluster"
  people_es_target_group_health_check_path     = "/_cluster/health"
  people_kibana_target_group_port              = 5601
  people_kibana_target_group_name              = "people-kibana"
  people_kibana_target_group_health_check_path = "/api/status"

  es_node0_domain = "people-es-indexing-node0.dev.synaptic.services"
  es_node1_domain = "people-es-indexing-node1.dev.synaptic.services"
  es_node2_domain = "people-es-indexing-node2.dev.synaptic.services"
  zone_name       = "dev.synaptic.services"

  team                = "infra"
  sprinto_tag         = "notprod"
  experimentation_tag = "false"
  environment         = "tech-dev"

  labs_core_web_sg                  = "sg-4e2dcc30"
  labs_core_worker_sg               = "sg-6e2fce10"
  labs_core_elb_sg                  = "sg-aedab8e6"
  monitoring_node_sg                = "sg-8ded97c6"
  data_manager_ephemeral_sg         = "sg-c77197b9"
  ssh_key_pair_name                 = "terraform"
  subnet_id                         = "subnet-0390bc5226b91e625"
  root_volume_size                  = 24
  delete_root_volume_on_termination = true
  ebs_volume_size                   = 400
  people_es_cluster_profile_name    = "CommonESClusterInstanceProfile"
}
