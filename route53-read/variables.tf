variable "es_node0_domain" {
  default = "people-es-live-node0.dev.synaptic.services"
  type    = string
}

variable "es_node1_domain" {
  default = "people-es-live-node1.dev.synaptic.services"
  type    = string
}

variable "es_node2_domain" {
  default = "people-es-live-node2.dev.synaptic.services"
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

variable "people_es_route53_domain" {
  default = "people-es-live.dev.synaptic.services"
  type    = string
}

variable "people_kibana_route53_domain" {
  default = "people-kibana-live.dev.synaptic.services"
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

variable "people_alb_zone_id" {
  default = "Z26RNL4JYFTOTI"
  type = string
}
