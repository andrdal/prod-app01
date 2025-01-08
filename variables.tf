variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "environment_name" {
  type    = string
  default = "Workload-Prod"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC Cidr Block"
  default     = "172.16.0.0/16"
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones"
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public Subnet CIDR values"
  default     = ["172.16.10.0/24", "172.16.20.0/24", "172.16.30.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private Subnet CIDR values"
  default     = ["172.16.40.0/24", "172.16.50.0/24", "172.16.60.0/24"]
}
