# Production environment configuration

terraform {
  backend "s3" {
    bucket         = "summitethic-terraform-state"
    key            = "production/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "summitethic-terraform-locks"
  }
}

module "summitethic_production" {
  source = "../../"
  
  # Override default variables for production
  environment          = "production"
  aws_region           = "us-east-1"
  vpc_cidr             = "10.0.0.0/16"
  availability_zones   = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
  
  # Production-specific settings
  instance_type        = "t3.large"
  ec2_instance_count   = 2
  
  # Security settings - these should be restricted in production
  admin_cidrs          = var.admin_cidrs
  public_ssh_key       = var.public_ssh_key
}