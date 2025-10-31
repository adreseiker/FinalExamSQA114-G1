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

resource "aws_instance" "jenkins_controller" {
  ami                         = data.aws_ami.amazon_linux_x86.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.main_a.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  key_name                    = aws_key_pair.this.key_name
  associate_public_ip_address = true
  user_data                   = file("${path.module}/scripts/jenkins_install.sh")

  tags = merge(local.common_tags, { Name = "JenkinsController" })
}

resource "aws_instance" "jenkins_agent_permanent" {
  ami                         = data.aws_ami.amazon_linux_x86.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.main_a.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  key_name                    = aws_key_pair.this.key_name
  associate_public_ip_address = true
  user_data                   = file("${path.module}/scripts/agent_install.sh")

  tags = merge(local.common_tags, { Name = "JenkinsAgentPermanent" })
}

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
