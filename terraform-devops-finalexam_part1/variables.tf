variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "key_name" {
  type    = string
  default = "deployer-key"
}

variable "instance_type" {
  type    = string
  default = "t3.small"
}

variable "ssh_allowed_cidr" {
  description = "Your public IP in CIDR form, e.g. 203.0.113.10/32"
  type        = string
  default     = "YOUR_PUBLIC_IP/32"
}
