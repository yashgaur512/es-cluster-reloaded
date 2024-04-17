# please change for each application/environment accordingly
terraform {
  backend "s3" {
    bucket = "infra-dev.synaptic.services"
    key    = "terraform-deployment-states/277447f3-c4ba-4071-974e-a9d641277bc4.tfstate"
    region = "us-east-1"
  }
}
