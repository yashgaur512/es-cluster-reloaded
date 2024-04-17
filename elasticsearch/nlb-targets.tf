module "common_es_lb_target" {
  source = "git::git@github.com:vy-labs/vastu-elements.git//aws/nlb/targets"

  # vpc_id                            = var.main_vpc_id
  # load_balancer_name                = local.lb_name
  # attachment_targets                = [module.es_node_0.instance.id, module.es_node_1.instance.id, module.es_node_2.instance.id]
  # target_group_name                 = var.common_es_target_group_name
  # target_group_port                 = var.common_es_target_group_port
  # target_group_protocol             = var.target_group_protocol
  # target_group_target_type          = var.target_group_target_type
  # target_group_deregistration_delay = var.target_group_deregistration_delay

  # target_group_health_check_path                = var.common_es_target_group_health_check_path
  # target_group_health_check_port                = var.common_es_target_group_port
  # target_group_health_check_timeout             = var.target_group_health_check_timeout
  # target_group_health_check_healthy_threshold   = var.target_group_health_check_healthy_threshold
  # target_group_health_check_unhealthy_threshold = var.target_group_health_check_unhealthy_threshold
  # target_group_health_check_interval            = var.target_group_health_check_interval
  # target_group_health_check_matcher             = var.target_group_health_check_matcher


  load_balancer_arn                             = module.nlb.lb.arn
  vpc_id                                        = var.main_vpc_id
  load_balancer_name                            = local.lb_name
  target_group_name                             = var.common_es_target_group_name
  target_group_port                             = var.common_es_target_group_port
  target_group_protocol                         = var.target_group_protocol
  target_group_target_type                      = var.target_group_target_type
  target_group_deregistration_delay             = var.target_group_deregistration_delay
  target_group_health_check_path                = var.common_es_target_group_health_check_path
  target_group_health_check_port                = var.common_es_target_group_port
  target_group_health_check_protocol            = "HTTPS"
  target_group_health_check_healthy_threshold   = var.target_group_health_check_healthy_threshold
  target_group_health_check_unhealthy_threshold = var.target_group_health_check_unhealthy_threshold
  target_group_health_check_interval            = var.target_group_health_check_interval
  target_group_tags = {
    "Service"     = local.service
    "ClusterName" = local.cluster_name
  }

  listener_port              = 9200
  listener_protocol          = "TLS"
  listener_apln_policy       = "HTTP2Optional"
  default_certificate_domain = local.self_certificate_domain
}

module "common_kibana_lb_target" {
  source = "git::git@github.com:vy-labs/vastu-elements.git//aws/nlb/targets"

  # vpc_id                            = var.main_vpc_id
  # load_balancer_name                = var.common_alb_name
  # load_balancer_arn                 = var.common_alb_arn
  # default_lb_listener_arn           = var.common_alb_default_listener_arn
  # attachment_targets                = [module.es_node_0.instance.id, module.es_node_1.instance.id, module.es_node_2.instance.id]
  # target_group_name                 = var.common_kibana_target_group_name
  # target_group_port                 = var.common_kibana_target_group_port
  # target_group_protocol             = var.target_group_protocol
  # target_group_target_type          = var.target_group_target_type
  # target_group_deregistration_delay = var.target_group_deregistration_delay

  # target_group_health_check_path                = var.common_kibana_target_group_health_check_path
  # target_group_health_check_port                = var.common_kibana_target_group_port
  # target_group_health_check_timeout             = var.target_group_health_check_timeout
  # target_group_health_check_healthy_threshold   = var.target_group_health_check_healthy_threshold
  # target_group_health_check_unhealthy_threshold = var.target_group_health_check_unhealthy_threshold
  # target_group_health_check_interval            = var.target_group_health_check_interval
  # target_group_health_check_matcher             = var.target_group_health_check_matcher


  # default_listener_host_headers = [var.common_kibana_route53_domain]

  # target_group_tags = {
  #   "Service"         = "common-kibana"
  #   "ServiceType"     = "Target Group"
  #   "created_by"      = "terraform"
  #   "ServiceOwner"    = var.team
  #   "sprinto"         = var.sprinto_tag
  #   "Environment"     = var.environment
  #   "Experimentation" = var.experimentation_tag
  # }

  load_balancer_arn                             = module.nlb.lb.arn
  vpc_id                                        = var.main_vpc_id
  load_balancer_name                            = local.lb_name
  target_group_name                             = var.common_kibana_target_group_name
  target_group_port                             = var.common_kibana_target_group_port
  target_group_protocol                         = var.target_group_protocol
  target_group_target_type                      = var.target_group_target_type
  target_group_deregistration_delay             = var.target_group_deregistration_delay
  target_group_health_check_path                = var.common_kibana_target_group_health_check_path
  target_group_health_check_port                = var.common_kibana_target_group_port
  target_group_health_check_protocol            = "HTTPS"
  target_group_health_check_healthy_threshold   = var.target_group_health_check_healthy_threshold
  target_group_health_check_unhealthy_threshold = var.target_group_health_check_unhealthy_threshold
  target_group_health_check_interval            = var.target_group_health_check_interval
  target_group_tags = {
    "Service"     = local.service
    "ClusterName" = local.cluster_name
  }

  listener_port              = 5601
  listener_protocol          = "TLS"
  listener_apln_policy       = "HTTP2Optional"
  default_certificate_domain = local.self_certificate_domain
}
