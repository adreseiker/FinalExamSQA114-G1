locals {
  common_tags = {
    Project = "finalexam-sqa114"
  }
}

data "aws_ami" "amazon_linux_x86" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# 1. Jenkins Controller
resource "aws_instance" "jenkins_controller" {
  ami                         = data.aws_ami.amazon_linux_x86.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.main_a.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  key_name                    = aws_key_pair.this.key_name
  associate_public_ip_address = true
  user_data                   = file("${path.module}/scripts/jenkins_install.sh")

  # copiar la misma llave que generó Terraform
  provisioner "file" {
    content     = tls_private_key.this.private_key_pem
    destination = "/home/ec2-user/.ssh/finalexam.pem"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 /home/ec2-user/.ssh/finalexam.pem",
      "chown ec2-user:ec2-user /home/ec2-user/.ssh/finalexam.pem"
    ]
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = tls_private_key.this.private_key_pem
  }

  tags = merge(local.common_tags, { Name = "JenkinsController" })
}

# 2. Jenkins Agent (permanent) -> este es el que usará el pipeline para hacer scp
resource "aws_instance" "jenkins_agent_permanent" {
  ami                         = data.aws_ami.amazon_linux_x86.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.main_a.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  key_name                    = aws_key_pair.this.key_name
  associate_public_ip_address = true
  user_data                   = file("${path.module}/scripts/agent_install.sh")

  # copiar la llave privada al agente permanente
  provisioner "file" {
    content     = tls_private_key.this.private_key_pem
    destination = "/home/ec2-user/.ssh/finalexam.pem"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 /home/ec2-user/.ssh/finalexam.pem",
      "chown ec2-user:ec2-user /home/ec2-user/.ssh/finalexam.pem"
    ]
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = tls_private_key.this.private_key_pem
  }

  tags = merge(local.common_tags, { Name = "JenkinsAgentPermanent" })
}

# 3. Jenkins Agent (dynamic)
resource "aws_instance" "jenkins_agent_dynamic" {
  ami                         = data.aws_ami.amazon_linux_x86.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.main_b.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  key_name                    = aws_key_pair.this.key_name
  associate_public_ip_address = true
  user_data                   = file("${path.module}/scripts/agent_install.sh")

  tags = merge(local.common_tags, { Name = "JenkinsAgentDynamic" })
}

# 4. Testing
resource "aws_instance" "testing" {
  ami                         = data.aws_ami.amazon_linux_x86.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.main_a.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  key_name                    = aws_key_pair.this.key_name
  associate_public_ip_address = true
  user_data                   = file("${path.module}/scripts/web_install.sh")

  tags = merge(local.common_tags, { Name = "Testing" })
}

# 5. Staging
resource "aws_instance" "staging" {
  ami                         = data.aws_ami.amazon_linux_x86.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.main_b.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  key_name                    = aws_key_pair.this.key_name
  associate_public_ip_address = true
  user_data                   = file("${path.module}/scripts/web_install.sh")

  tags = merge(local.common_tags, { Name = "Staging" })
}

# 6. Prod_Env1
resource "aws_instance" "prod_env1" {
  ami                         = data.aws_ami.amazon_linux_x86.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.main_a.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  key_name                    = aws_key_pair.this.key_name
  associate_public_ip_address = true
  user_data                   = file("${path.module}/scripts/web_install.sh")

  tags = merge(local.common_tags, { Name = "Production_Env1" })
}

# 7. Prod_Env2
resource "aws_instance" "prod_env2" {
  ami                         = data.aws_ami.amazon_linux_x86.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.main_b.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  key_name                    = aws_key_pair.this.key_name
  associate_public_ip_address = true
  user_data                   = file("${path.module}/scripts/web_install.sh")

  tags = merge(local.common_tags, { Name = "Production_Env2" })
}