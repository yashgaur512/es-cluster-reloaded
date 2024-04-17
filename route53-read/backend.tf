# please change for each application/environment accordingly
terraform {
  backend "s3" {
    bucket = "infra-dev.synaptic.services"
    key    = "terraform-deployment-states/route53-read.tfstate"
    region = "us-east-1"
  }
}
