variable "aws_region" {
  description = "AWS Region used by the Cloud Starter Kit."
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "Name used when tagging and identifying resources."
  type        = string
  default     = "cloud-starter-kit"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}

variable "vpc_cidr" {
  description = "IPv4 CIDR range allocated to the VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnet_cidr" {
  description = "IPv4 CIDR range allocated to the public subnet."
  type        = string
  default     = "10.20.1.0/24"
}
