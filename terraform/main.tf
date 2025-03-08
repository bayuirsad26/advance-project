# Main Terraform configuration for SummitEthic infrastructure
# This file should be tailored to your specific cloud provider

terraform {
  required_version = ">= 1.0.0"
  
  backend "s3" {
    bucket         = "summitethic-terraform-state"
    key            = "global/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "summitethic-terraform-locks"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Provider configuration
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = var.environment
      Project     = "SummitEthic"
      ManagedBy   = "Terraform"
      Owner       = "DevOps"
    }
  }
}

# Import modules
module "network" {
  source = "./modules/network"
  
  vpc_cidr             = var.vpc_cidr
  environment          = var.environment
  availability_zones   = var.availability_zones
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
}

module "security" {
  source = "./modules/security"
  
  vpc_id               = module.network.vpc_id
  environment          = var.environment
  admin_cidrs          = var.admin_cidrs
  public_ssh_key       = var.public_ssh_key
}

module "compute" {
  source = "./modules/compute"
  
  environment          = var.environment
  vpc_id               = module.network.vpc_id
  public_subnet_ids    = module.network.public_subnet_ids
  private_subnet_ids   = module.network.private_subnet_ids
  ssh_security_group   = module.security.ssh_security_group_id
  instance_type        = var.instance_type
  key_name             = module.security.key_name
  ec2_instance_count   = var.ec2_instance_count
}

# Output important information
output "public_ips" {
  value       = module.compute.public_ips
  description = "Public IP addresses of the EC2 instances"
}

output "public_dns" {
  value       = module.compute.public_dns
  description = "Public DNS names of the EC2 instances"
}

output "private_ips" {
  value       = module.compute.private_ips
  description = "Private IP addresses of the EC2 instances"
}