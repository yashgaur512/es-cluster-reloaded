module "people_es_lb_target" {
  source = "git::git@github.com:vy-labs/vastu-elements.git//aws/nlb/targets"

  load_balancer_arn                             = module.nlb.lb.arn
  vpc_id                                        = var.main_vpc_id
  load_balancer_name                            = local.lb_name
  target_group_name                             = var.people_es_target_group_name
  target_group_port                             = var.people_es_target_group_port
  target_group_protocol                         = var.target_group_protocol
  target_group_target_type                      = var.target_group_target_type
  target_group_deregistration_delay             = var.target_group_deregistration_delay
  target_group_health_check_path                = var.people_es_target_group_health_check_path
  target_group_health_check_port                = var.people_es_target_group_port
  target_group_health_check_protocol            = "HTTPS"
  target_group_health_check_healthy_threshold   = var.target_group_health_check_healthy_threshold
  target_group_health_check_unhealthy_threshold = var.target_group_health_check_unhealthy_threshold
  target_group_health_check_interval            = var.target_group_health_check_interval
  target_group_tags = {
    "Service"     = local.service
    "ClusterName" = local.cluster_name
  }
  attachment_targets = ["${module.es_node_0.instance.id}", "${module.es_node_1.instance.id}", "${module.es_node_2.instance.id}"]

  listener_port              = 9200
  listener_protocol          = "TLS"
  listener_apln_policy       = "HTTP2Optional"
  default_certificate_domain = local.self_certificate_domain
}

module "people_kibana_lb_target" {
  source = "git::git@github.com:vy-labs/vastu-elements.git//aws/nlb/targets"

  load_balancer_arn                             = module.nlb.lb.arn
  vpc_id                                        = var.main_vpc_id
  load_balancer_name                            = local.lb_name
  target_group_name                             = var.people_kibana_target_group_name
  target_group_port                             = var.people_kibana_target_group_port
  target_group_protocol                         = var.target_group_protocol
  target_group_target_type                      = var.target_group_target_type
  target_group_deregistration_delay             = var.target_group_deregistration_delay
  target_group_health_check_path                = var.people_kibana_target_group_health_check_path
  target_group_health_check_port                = var.people_kibana_target_group_port
  target_group_health_check_protocol            = "HTTPS"
  target_group_health_check_healthy_threshold   = var.target_group_health_check_healthy_threshold
  target_group_health_check_unhealthy_threshold = var.target_group_health_check_unhealthy_threshold
  target_group_health_check_interval            = var.target_group_health_check_interval
  target_group_tags = {
    "Service"     = local.service
    "ClusterName" = local.cluster_name
  }
  attachment_targets = ["${module.es_node_0.instance.id}", "${module.es_node_1.instance.id}", "${module.es_node_2.instance.id}"]

  listener_port              = 5601
  listener_protocol          = "TLS"
  listener_apln_policy       = "HTTP2Optional"
  default_certificate_domain = local.self_certificate_domain
}
