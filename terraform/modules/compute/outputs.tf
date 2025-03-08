output "instance_ids" {
  value       = aws_instance.main[*].id
  description = "IDs of the EC2 instances"
}

output "public_ips" {
  value       = aws_eip.main[*].public_ip
  description = "Public IP addresses of the EC2 instances"
}

output "public_dns" {
  value       = aws_instance.main[*].public_dns
  description = "Public DNS names of the EC2 instances"
}

output "private_ips" {
  value       = aws_instance.main[*].private_ip
  description = "Private IP addresses of the EC2 instances"
}