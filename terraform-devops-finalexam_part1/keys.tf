resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  key_name   = var.key_name
  public_key = tls_private_key.this.public_key_openssh
}

output "private_key_pem" {
  description = "Private key to SSH into instances"
  value       = tls_private_key.this.private_key_pem
  sensitive   = true
}