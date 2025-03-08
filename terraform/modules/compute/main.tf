# Compute module for SummitEthic infrastructure

# Get the latest Ubuntu 22.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  
  owners = ["099720109477"] # Canonical
}

# EC2 Instances
resource "aws_instance" "main" {
  count                       = var.ec2_instance_count
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = var.public_subnet_ids[count.index % length(var.public_subnet_ids)]
  vpc_security_group_ids      = [var.ssh_security_group]
  associate_public_ip_address = true
  
  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }
  
  tags = {
    Name = "${var.environment}-server-${count.index + 1}"
  }
  
  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get upgrade -y
              apt-get install -y python3 python3-pip
              EOF
  
  lifecycle {
    create_before_destroy = true
  }
}

# Elastic IP for each instance
resource "aws_eip" "main" {
  count    = var.ec2_instance_count
  instance = aws_instance.main[count.index].id
  domain   = "vpc"
  
  tags = {
    Name = "${var.environment}-eip-${count.index + 1}"
  }
}