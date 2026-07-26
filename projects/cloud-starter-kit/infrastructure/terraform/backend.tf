terraform {
  backend "s3" {
    bucket       = "fbp-terraform-state-213424233863-ap-southeast-1"
    key          = "cloud-starter-kit/dev/terraform.tfstate"
    region       = "ap-southeast-1"
    encrypt      = true
    use_lockfile = true
  }
}
