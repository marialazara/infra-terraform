#outputs
output "instance_public_ip" {
  description = "O IP público da instância EC2"
  value       = aws_instance.app_orbbi.public_ip
}