variable "instance_type" {
  description = "EC2 instance type used by the application host."
  type        = string
  default     = "t3.micro"
}

variable "root_volume_size" {
  description = "Size of the EC2 root volume in GiB."
  type        = number
  default     = 10

  validation {
    condition     = var.root_volume_size >= 8 && var.root_volume_size <= 100
    error_message = "Root volume size must be between 8 and 100 GiB."
  }
}

variable "ubuntu_ami_parameter" {
  description = "SSM public parameter containing the latest Ubuntu 24.04 LTS AMI ID."
  type        = string
  default     = "/aws/service/canonical/ubuntu/server/noble/stable/current/amd64/hvm/ebs-gp3/ami-id"
}
