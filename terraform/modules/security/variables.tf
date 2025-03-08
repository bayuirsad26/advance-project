variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., development, staging, production)"
  type        = string
}

variable "admin_cidrs" {
  description = "CIDR blocks that are allowed SSH access"
  type        = list(string)
}

variable "public_ssh_key" {
  description = "Public SSH key for EC2 instances"
  type        = string
}