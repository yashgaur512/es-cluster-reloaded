# please change for each application/environment accordingly
terraform {
  backend "s3" {
    bucket = "infra-dev.synaptic.services"
    key    = "terraform-deployment-states/a08e0f4a-0581-4db1-b67f-a07a6e083046.tfstate"
    region = "us-east-1"
  }
}
