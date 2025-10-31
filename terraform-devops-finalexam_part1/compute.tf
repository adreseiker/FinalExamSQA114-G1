locals {
  common_tags = {
    Project = "finalexam-sqa114"
  }
}

# One AMI for everything: Amazon Linux 2023 (x86_64)
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

# 1) Jenkins Controller – installs Jenkins
resource "aws_instance" "jenkins_controller" {
  ami                         = data.aws_ami.amazon_linux_x86.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.main_a.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  key_name                    = aws_key_pair.this.key_name
  associate_public_ip_address = true

  user_data = file("${path.module}/scripts/jenkins_install.sh")

  tags = merge(local.common_tags, { Name = "JenkinsController" })
}

# 2) Jenkins Agent (permanent) – installs java/node/git/chromium
resource "aws_instance" "jenkins_agent_permanent" {
  ami                         = data.aws_ami.amazon_linux_x86.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.main_a.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  key_name                    = aws_key_pair.this.key_name
  associate_public_ip_address = true

  user_data = file("${path.module}/scripts/agent_install.sh")

  tags = merge(local.common_tags, { Name = "JenkinsAgentPermanent" })
}

# 3) Jenkins Agent (dynamic) – same agent script
resource "aws_instance" "jenkins_agent_dynamic" {
  ami                         = data.aws_ami.amazon_linux_x86.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.main_b.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  key_name                    = aws_key_pair.this.key_name
  associate_public_ip_address = true

  user_data = file("${path.module}/scripts/agent_install.sh")

  tags = merge(local.common_tags, { Name = "JenkinsAgentDynamic" })
}

# 4) Testing – installs Apache (so pipeline can deploy here)
resource "aws_instance" "testing" {
  ami                         = data.aws_ami.amazon_linux_x86.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.main_a.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  key_name                    = aws_key_pair.this.key_name
  associate_public_ip_address = true

  user_data = file("${path.module}/scripts/web_install.sh")

  tags = merge(local.common_tags, { Name = "Testing" })
}

# 5) Staging – installs Apache
resource "aws_instance" "staging" {
  ami                         = data.aws_ami.amazon_linux_x86.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.main_b.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  key_name                    = aws_key_pair.this.key_name
  associate_public_ip_address = true

  user_data = file("${path.module}/scripts/web_install.sh")

  tags = merge(local.common_tags, { Name = "Staging" })
}

# 6) Prod Env 1 – installs Apache
resource "aws_instance" "prod_env1" {
  ami                         = data.aws_ami.amazon_linux_x86.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.main_a.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  key_name                    = aws_key_pair.this.key_name
  associate_public_ip_address = true

  user_data = file("${path.module}/scripts/web_install.sh")

  tags = merge(local.common_tags, { Name = "Prod_Env1" })
}

# 7) Prod Env 2 – installs Apache
resource "aws_instance" "prod_env2" {
  ami                         = data.aws_ami.amazon_linux_x86.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.main_b.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  key_name                    = aws_key_pair.this.key_name
  associate_public_ip_address = true

  user_data = file("${path.module}/scripts/web_install.sh")

  tags = merge(local.common_tags, { Name = "Prod_Env2" })
}