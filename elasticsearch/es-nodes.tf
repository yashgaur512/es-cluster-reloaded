module "es_node_0" {
  source                               = "git::git@github.com:vy-labs/vastu-elements.git//aws/instance"
  vpc_id                               = var.main_vpc_id
  region                               = var.region
  vpc_cidr_blocks                      = var.vpc_cidr_blocks
  instance_image_id                    = data.aws_ami.this.image_id
  instance_name                        = "${var.environment}-${var.es_node_0_name}"
  instance_type                        = var.instance_type
  ebs_optimized                        = true
  disable_api_termination              = false
  instance_profile                     = var.people_es_cluster_profile_name
  instance_initiated_shutdown_behavior = "stop"
  associate_public_ip_address          = true
  assign_eip_address                   = false
  ssh_key_pair                         = var.ssh_key_pair_name
  subnet_id                            = var.subnet_id
  monitoring                           = false
  source_dest_check                    = true
  root_volume_type                     = "gp3"
  root_iops                            = 3000 //Default value for gp3
  root_volume_size                     = var.root_volume_size
  delete_on_termination                = var.delete_root_volume_on_termination
  metadata_http_tokens_required        = false
  metadata_http_endpoint_enabled       = true
  availability_zone                    = var.availability_zone
  user_data = templatefile(
    "${path.module}/scripts/user-data-node-0.tpl",
    { environment = var.environment }
  )
  volume_details = [
  {
    "name"          = "${var.environment}-people-es-node-1-vol0",
    ebs_volume_size = var.ebs_volume_size,
    ebs_iops        = 3000,
    ebs_volume_type = "gp3",
    ebs_device_name = "/dev/xvdf",
    tags = {
      "Component"       = "people-es-ebs"
      "Service"         = "people-es"
      "ServiceType"     = "EBS"
      "created_by"      = "terraform"
      "ServiceOwner"    = var.team
      "sprinto"         = var.sprinto_tag
      "Environment"     = var.environment
      "Experimentation" = var.experimentation_tag
    }
  },
  {
    "name"          = "${var.environment}-people-es-node-1-vol1",
    ebs_volume_size = var.ebs_volume_size,
    ebs_iops        = 3000,
    ebs_volume_type = "gp3",
    ebs_device_name = "/dev/xvde",
    tags = {
      "Component"       = "people-es-ebs"
      "Service"         = "people-es"
      "ServiceType"     = "EBS"
      "created_by"      = "terraform"
      "ServiceOwner"    = var.team
      "sprinto"         = var.sprinto_tag
      "Environment"     = var.environment
      "Experimentation" = var.experimentation_tag
    }
  }
  ]
  instance_tags = {
    "Component"       = "people-es-node-0"
    "Service"         = "people-es"
    "ServiceType"     = "EC2"
    "created_by"      = "terraform"
    "ServiceOwner"    = var.team
    "sprinto"         = var.sprinto_tag
    "Environment"     = var.environment
    "Experimentation" = var.experimentation_tag
    "monitoring"      = "true"

  }
  volume_tags = {
    "Component"       = "people-es-ebs"
    "Service"         = "people-es"
    "ServiceType"     = "EBS"
    "created_by"      = "terraform"
    "ServiceOwner"    = var.team
    "sprinto"         = var.sprinto_tag
    "Environment"     = var.environment
    "Experimentation" = var.experimentation_tag
  }
  security_group_tags = {
    "Component"       = "people-es-sg"
    "Service"         = "people-es"
    "created_by"      = "terraform"
    "ServiceOwner"    = var.team
    "sprinto"         = var.sprinto_tag
    "Environment"     = var.environment
    "Experimentation" = var.experimentation_tag
  }

  security_group_rules = [
    # {
    #   type                     = "ingress"
    #   from_port                = 9200
    #   to_port                  = 9200
    #   protocol                 = "tcp"
    #   cidr_blocks              = []
    #   self                     = false
    #   source_security_group_id = var.labs_core_web_sg
    # },

    # {
    #   type                     = "ingress"
    #   from_port                = 9200
    #   to_port                  = 9200
    #   protocol                 = "tcp"
    #   cidr_blocks              = []
    #   self                     = false
    #   source_security_group_id = var.labs_core_worker_sg
    # },

    # {
    #   type                     = "ingress"
    #   from_port                = 9200
    #   to_port                  = 9200
    #   protocol                 = "tcp"
    #   cidr_blocks              = []
    #   self                     = false
    #   source_security_group_id = var.data_manager_ephemeral_sg
    # },

    # {
    #   type                     = "ingress"
    #   from_port                = 9200
    #   to_port                  = 9200
    #   protocol                 = "tcp"
    #   cidr_blocks              = []
    #   self                     = false
    #   source_security_group_id = var.labs_core_elb_sg
    # },

    # {
    #   type                     = "ingress"
    #   from_port                = 5601
    #   to_port                  = 5601
    #   protocol                 = "tcp"
    #   cidr_blocks              = []
    #   self                     = false
    #   source_security_group_id = var.labs_core_elb_sg
    # },

    # {
    #   type                     = "ingress"
    #   from_port                = 9100
    #   to_port                  = 9100
    #   protocol                 = "tcp"
    #   cidr_blocks              = []
    #   self                     = false
    #   source_security_group_id = var.monitoring_node_sg
    # },

    # {
    #   type                     = "ingress"
    #   from_port                = 0
    #   to_port                  = 0
    #   protocol                 = -1
    #   cidr_blocks              = []
    #   self                     = true
    #   source_security_group_id = null
    # },
    {
      type                     = "egress"
      from_port                = 0
      to_port                  = 0
      protocol                 = -1
      cidr_blocks              = ["0.0.0.0/0"]
      self                     = false
      source_security_group_id = null
  }]
}

module "es_node_1" {
  source                               = "git::git@github.com:vy-labs/vastu-elements.git//aws/instance"
  vpc_id                               = var.main_vpc_id
  region                               = var.region
  vpc_cidr_blocks                      = var.vpc_cidr_blocks
  instance_image_id                    = data.aws_ami.this.image_id
  instance_name                        = "${var.environment}-${var.es_node_1_name}"
  instance_type                        = var.instance_type
  ebs_optimized                        = true
  disable_api_termination              = false
  instance_profile                     = var.people_es_cluster_profile_name
  instance_initiated_shutdown_behavior = "stop"
  associate_public_ip_address          = true
  assign_eip_address                   = false
  ssh_key_pair                         = var.ssh_key_pair_name
  subnet_id                            = var.subnet_id
  monitoring                           = false
  source_dest_check                    = true
  root_volume_type                     = "gp3"
  root_iops                            = 3000 //Default value for gp3
  root_volume_size                     = var.root_volume_size
  delete_on_termination                = var.delete_root_volume_on_termination
  metadata_http_tokens_required        = false
  metadata_http_endpoint_enabled       = true
  security_group_ids                   = [module.es_node_0.security_group.id]
  availability_zone                    = var.availability_zone
  user_data = templatefile(
    "${path.module}/scripts/user-data-node-1.tpl",
    {
      environment = var.environment
      es_node_0_ip = module.es_node_0.instance.private_ip
    }
  )
  volume_details = [
    {
    "name"          = "${var.environment}-people-es-node-1-vol0",
    ebs_volume_size = var.ebs_volume_size,
    ebs_iops        = 3000,
    ebs_volume_type = "gp3",
    ebs_device_name = "/dev/xvdg",
    tags = {
      "Component"       = "people-es-ebs"
      "Service"         = "people-es"
      "ServiceType"     = "EBS"
      "created_by"      = "terraform"
      "ServiceOwner"    = var.team
      "sprinto"         = var.sprinto_tag
      "Environment"     = var.environment
      "Experimentation" = var.experimentation_tag
    }
  },
  {
    "name"          = "${var.environment}-people-es-node-1-vol1",
    ebs_volume_size = var.ebs_volume_size,
    ebs_iops        = 3000,
    ebs_volume_type = "gp3",
    ebs_device_name = "/dev/xvdh",
    tags = {
      "Component"       = "people-es-ebs"
      "Service"         = "people-es"
      "ServiceType"     = "EBS"
      "created_by"      = "terraform"
      "ServiceOwner"    = var.team
      "sprinto"         = var.sprinto_tag
      "Environment"     = var.environment
      "Experimentation" = var.experimentation_tag
    }
  }
  ]
  instance_tags = {
    "Component"       = "people-es-node-1"
    "Service"         = "people-es"
    "ServiceType"     = "EC2"
    "created_by"      = "terraform"
    "ServiceOwner"    = var.team
    "sprinto"         = var.sprinto_tag
    "Environment"     = var.environment
    "Experimentation" = var.experimentation_tag
    "monitoring"      = "true"
  }
  volume_tags = {
    "Component"       = "people-es-ebs"
    "Service"         = "people-es"
    "ServiceType"     = "EBS"
    "created_by"      = "terraform"
    "ServiceOwner"    = var.team
    "sprinto"         = var.sprinto_tag
    "Environment"     = var.environment
    "Experimentation" = var.experimentation_tag
  }
  security_group_tags = {
    "Component"       = "people-es-sg"
    "Service"         = "people-es"
    "created_by"      = "terraform"
    "ServiceOwner"    = var.team
    "sprinto"         = var.sprinto_tag
    "Environment"     = var.environment
    "Experimentation" = var.experimentation_tag
  }
}

module "es_node_2" {
  source                               = "git::git@github.com:vy-labs/vastu-elements.git//aws/instance"
  vpc_id                               = var.main_vpc_id
  region                               = var.region
  vpc_cidr_blocks                      = var.vpc_cidr_blocks
  instance_image_id                    = data.aws_ami.this.image_id
  instance_name                        = "${var.environment}-${var.es_node_2_name}"
  instance_type                        = var.instance_type
  ebs_optimized                        = true
  disable_api_termination              = false
  instance_profile                     = var.people_es_cluster_profile_name
  instance_initiated_shutdown_behavior = "stop"
  associate_public_ip_address          = true
  assign_eip_address                   = false
  ssh_key_pair                         = var.ssh_key_pair_name
  subnet_id                            = var.subnet_id
  monitoring                           = false
  source_dest_check                    = true
  root_volume_type                     = "gp3"
  root_iops                            = 3000 //Default value for gp3
  root_volume_size                     = var.root_volume_size
  delete_on_termination                = var.delete_root_volume_on_termination
  metadata_http_tokens_required        = false
  metadata_http_endpoint_enabled       = true
  security_group_ids                   = [module.es_node_0.security_group.id]
  availability_zone                    = var.availability_zone
  user_data = templatefile(
    "${path.module}/scripts/user-data-node-2.tpl",
    {
      environment = var.environment
      es_node_0_ip = module.es_node_0.instance.private_ip
      es_node_1_ip = module.es_node_1.instance.private_ip
    }
  )
  volume_details = [
  {
    "name"          = "${var.environment}-people-es-node-2-vol0",
    ebs_volume_size = var.ebs_volume_size,
    ebs_iops        = 3000,
    ebs_volume_type = "gp3",
    ebs_device_name = "/dev/xvdi",
    tags = {
      "Component"       = "people-es-ebs"
      "Service"         = "people-es"
      "ServiceType"     = "EBS"
      "created_by"      = "terraform"
      "ServiceOwner"    = var.team
      "sprinto"         = var.sprinto_tag
      "Environment"     = var.environment
      "Experimentation" = var.experimentation_tag
    }
  },
  {
    "name"          = "${var.environment}-people-es-node-2-vol1",
    ebs_volume_size = var.ebs_volume_size,
    ebs_iops        = 3000,
    ebs_volume_type = "gp3",
    ebs_device_name = "/dev/xvdj",
    tags = {
      "Component"       = "people-es-ebs"
      "Service"         = "people-es"
      "ServiceType"     = "EBS"
      "created_by"      = "terraform"
      "ServiceOwner"    = var.team
      "sprinto"         = var.sprinto_tag
      "Environment"     = var.environment
      "Experimentation" = var.experimentation_tag
    }
  }
  ]
  instance_tags = {
    "Component"       = "people-es-node-2"
    "Service"         = "people-es"
    "ServiceType"     = "EC2"
    "created_by"      = "terraform"
    "ServiceOwner"    = var.team
    "sprinto"         = var.sprinto_tag
    "Environment"     = var.environment
    "Experimentation" = var.experimentation_tag
    "monitoring"      = "true"
  }
  volume_tags = {
    "Component"       = "people-es-ebs"
    "Service"         = "people-es"
    "ServiceType"     = "EBS"
    "created_by"      = "terraform"
    "ServiceOwner"    = var.team
    "sprinto"         = var.sprinto_tag
    "Environment"     = var.environment
    "Experimentation" = var.experimentation_tag
  }
  security_group_tags = {
    "Component"       = "people-es-sg"
    "Service"         = "people-es"
    "created_by"      = "terraform"
    "ServiceOwner"    = var.team
    "sprinto"         = var.sprinto_tag
    "Environment"     = var.environment
    "Experimentation" = var.experimentation_tag
  }
}
