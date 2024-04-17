variable "es_node0_domain" {
  default = "people-es-indexing-node0.dev.synaptic.services"
  type    = string
}

variable "es_node1_domain" {
  default = "people-es-indexing-node1.dev.synaptic.services"
  type    = string
}

variable "es_node2_domain" {
  default = "people-es-indexing-node2.dev.synaptic.services"
  type    = string
}

variable "es_node_0_private_ip" {
  type    = string
}

variable "es_node_1_private_ip" {
  type    = string
}

variable "es_node_2_private_ip" {
  type    = string
}

variable "nlb_dns_name" {
  type    = string
}

variable "common_es_route53_domain" {
  default = "common-elasticsearch.dev.synaptic.services"
  type    = string
}

variable "common_kibana_route53_domain" {
  default = "common-kibana.dev.synaptic.services"
  type    = string
}

variable "account_id" {
  default = "887603066220"
  type    = string
}

variable "team" {
  default = "infra"
  type    = string
}

variable "sprinto_tag" {
  default = "notprod"
  type    = string
}

variable "experimentation_tag" {
  default = "false"
  type    = string
}

variable "environment" {
  default = "tech-dev"
  type    = string
}

variable "route53_zone_id" {
  default = "Z0599858291533W9UYM7N"
  type = string
}

variable "common_alb_zone_id" {
  default = "Z26RNL4JYFTOTI"
  type = string
}
