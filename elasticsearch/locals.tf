locals {
  lb_name = "${var.environment}-people-es-lb"
  lb_subnet_ids = [var.subnet_id]
  lb_cross_zone_enabled = false
  service = "elasticsearch"
  cluster_name = "people-elasticsearch"
  self_certificate_domain = format("*.%s", var.zone_name)
}