module "nlb" {
  source = "git::git@github.com:vy-labs/vastu-elements.git//aws/nlb"

  internal                          = true
  deletion_protection_enabled       = false
  load_balancer_name                = local.lb_name
  subnet_ids                        = local.lb_subnet_ids
  cross_zone_load_balancing_enabled = local.lb_cross_zone_enabled
  ip_address_type                   = "ipv4"

  load_balancer_tags = {
    "Service"     = local.service
    "ClusterName" = local.cluster_name
  }
}