module "es_cluster_iam_role" {
  source = "git::git@github.com:vy-labs/vastu-elements.git//aws/iam-role"

  iam_role_name                     = "CommonESClusterRole"
  iam_role_path                     = "/"
  iam_role_description              = "Role attached to Common ES cluster nodes"
  assume_role_principal_type        = "Service"
  assume_role_principal_identifiers = ["ec2.amazonaws.com"]
  iam_role_tags = {
    "Service"         = "common-es-cluster"
    "ServiceType"     = "IAM"
    "created_by"      = "terraform"
    "ServiceOwner"    = var.team
    "sprinto"         = var.sprinto_tag
    "Environment"     = var.environment
    "Experimentation" = var.experimentation_tag
  }
}

module "es_cluster_iam_instance_profile" {
  source = "git::git@github.com:vy-labs/vastu-elements.git//aws/iam-profile"

  iam_role              = module.es_cluster_iam_role.iam_role.name
  instance_profile_name = "CommonESClusterInstanceProfile"
  instance_profile_path = "/"
  instance_profile_tags = {
    "Service"         = "common-es-cluster"
    "ServiceType"     = "IAM"
    "created_by"      = "terraform"
    "ServiceOwner"    = var.team
    "sprinto"         = var.sprinto_tag
    "Environment"     = var.environment
    "Experimentation" = var.experimentation_tag
  }
}

module "ssm_access_attach" {
  source = "git::git@github.com:vy-labs/vastu-elements.git//aws/iam-role-policy-attachment"

  iam_role_name  = module.es_cluster_iam_role.iam_role.name
  iam_policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
