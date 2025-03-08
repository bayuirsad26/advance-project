output "key_name" {
  value       = aws_key_pair.main.key_name
  description = "Name of the SSH key pair"
}

output "ssh_security_group_id" {
  value       = aws_security_group.ssh.id
  description = "ID of the SSH security group"
}

output "web_security_group_id" {
  value       = aws_security_group.web.id
  description = "ID of the web security group"
}

output "mail_security_group_id" {
  value       = aws_security_group.mail.id
  description = "ID of the mail security group"
}