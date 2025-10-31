variable "aws_region" {
  description = "AWS region to deploy to"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type for all instances"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name for the AWS key pair to be created/used"
  type        = string
  default     = "deployer-key"
}

variable "ssh_allowed_cidr" {
  description = "Your public IP in CIDR form to allow SSH (e.g. 1.2.3.4/32)"
  type        = string
  
 
  default     = "0.0.0.0/0"
}