locals {
  common_tags = {
    Project = "finalexam-sqa114"
  }
}

# 1. Jenkins Controller
resource "aws_instance" "jenkins_controller" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.main_a.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  key_name                    = aws_key_pair.this.key_name
  associate_public_ip_address = true

  tags = merge(local.common_tags, { Name = "JenkinsController" })
}

# 2. Jenkins Agent Permanent
resource "aws_instance" "jenkins_agent_permanent" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.main_a.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  key_name                    = aws_key_pair.this.key_name
  associate_public_ip_address = true

  tags = merge(local.common_tags, { Name = "JenkinsAgentPermanent" })
}

# 3. Jenkins Agent Dynamic (EC2 template target)
resource "aws_instance" "jenkins_agent_dynamic" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.main_a.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  key_name                    = aws_key_pair.this.key_name
  associate_public_ip_address = true

  tags = merge(local.common_tags, { Name = "JenkinsAgentDynamic" })
}

# 4. Testing
resource "aws_instance" "testing" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.main_b.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  key_name                    = aws_key_pair.this.key_name
  associate_public_ip_address = true

  tags = merge(local.common_tags, { Name = "Testing" })
}

# 5. Staging
resource "aws_instance" "staging" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.main_b.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  key_name                    = aws_key_pair.this.key_name
  associate_public_ip_address = true

  tags = merge(local.common_tags, { Name = "Staging" })
}

# 6. Production_Env1
resource "aws_instance" "prod_env1" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.main_a.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  key_name                    = aws_key_pair.this.key_name
  associate_public_ip_address = true

  tags = merge(local.common_tags, { Name = "Production_Env1" })
}

# 7. Production_Env2
resource "aws_instance" "prod_env2" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.main_b.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  key_name                    = aws_key_pair.this.key_name
  associate_public_ip_address = true

  tags = merge(local.common_tags, { Name = "Production_Env2" })
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-6.1-*"]
  }
}
