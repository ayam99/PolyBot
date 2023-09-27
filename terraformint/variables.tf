variable "env" {
description = "Deployment environment"
type        = string
default     = "dev"
}

variable "resource_alias" {
  description = "Your name"
  type        = string
  default     = "ayamal"
}

variable "vpc_cidr" {
  description = "The IPv4 CIDR block for the Virtual Private Cloud (VPC)."
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_private_subnets" {
  description = "A list of private subnet CIDR blocks."
  type        = list(string)
  default     = ["10.0.7.0/24", "10.0.2.0/24", "10.0.3.0/24"]  # Update with your desired CIDR blocks
}

variable "vpc_public_subnets" {
  description = "A list of public subnet CIDR blocks."
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]  # Update with your desired CIDR blocks
}

variable "azs" {
  description = "A list of Availability Zones to distribute resources across."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}
