module "route53_record_people_es_cluster" {
  source = "git::git@github.com:vy-labs/vastu-elements.git//aws/route53/record"

  route53_zone_id = var.route53_zone_id
  route53_domain  = var.people_es_route53_domain
  record_type     = "A"

  is_alias_record                     = true
  alias_record_dns_name               = var.nlb_dns_name
  alias_record_zone_id                = var.people_alb_zone_id
  alias_record_evaluate_target_health = false

}
module "route53_record_node0" {
  source = "git::git@github.com:vy-labs/vastu-elements.git//aws/route53/record"

  route53_zone_id = var.route53_zone_id
  route53_domain  = var.es_node0_domain
  record_type     = "A"

  record_ttl = 300
  is_alias_record                     = false
  records = [var.es_node_0_private_ip]
}
module "route53_record_node1" {
  source = "git::git@github.com:vy-labs/vastu-elements.git//aws/route53/record"

  route53_zone_id = var.route53_zone_id
  route53_domain  = var.es_node1_domain
  record_type     = "A"

  record_ttl = 300
  is_alias_record                     = false
  records = [var.es_node_1_private_ip]

}
module "route53_record_node2" {
  source = "git::git@github.com:vy-labs/vastu-elements.git//aws/route53/record"

  route53_zone_id = var.route53_zone_id
  route53_domain  = var.es_node2_domain
  record_type     = "A"

  record_ttl = 300
  is_alias_record                     = false
  records = [var.es_node_2_private_ip]

}

module "route53_record_people_kibana" {
  source = "git::git@github.com:vy-labs/vastu-elements.git//aws/route53/record"

  route53_zone_id = var.route53_zone_id
  route53_domain  = var.people_kibana_route53_domain
  record_type     = "A"

  is_alias_record                     = true
  alias_record_dns_name               = var.nlb_dns_name
  alias_record_zone_id                = var.people_alb_zone_id
  alias_record_evaluate_target_health = false
}
