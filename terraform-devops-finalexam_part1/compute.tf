locals {
  common_tags = {
    Project = "finalexam-sqa114"
  }
}

# 1. Jenkins Controller (usa tu script completo)
resource "aws_instance" "jenkins_controller" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.main_a.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  key_name                    = aws_key_pair.this.key_name
  associate_public_ip_address = true

  # usamos el script externo
  user_data = file("${path.module}/scripts/jenkins_install.sh")

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

  # 👇 ahora usamos script separado para agentes
  user_data = file("${path.module}/scripts/agent_install.sh")

  tags = merge(local.common_tags, { Name = "JenkinsAgentPermanent" })
}

# 3. Jenkins Agent Dynamic
resource "aws_instance" "jenkins_agent_dynamic" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.main_a.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  key_name                    = aws_key_pair.this.key_name
  associate_public_ip_address = true

  user_data = file("${path.module}/scripts/agent_install.sh")

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

  user_data = <<-EOF
    #!/bin/bash
    dnf -y update
    dnf -y install httpd git

    systemctl enable httpd
    systemctl start httpd

    cd /var/www/html
    rm -rf ./*

    git clone https://github.com/adreseiker/FinalExamSQA114-G1.git app || true
    if [ -d app ]; then
      cp -r app/* /var/www/html/
    fi

    echo "<h2>Testing Environment</h2>" > /var/www/html/env.html
  EOF

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

  user_data = <<-EOF
    #!/bin/bash
    dnf -y update
    dnf -y install httpd git

    systemctl enable httpd
    systemctl start httpd

    cd /var/www/html
    rm -rf ./*

    git clone https://github.com/adreseiker/FinalExamSQA114-G1.git app || true
    if [ -d app ]; then
      cp -r app/* /var/www/html/
    fi

    echo "<h2>Staging Environment</h2>" > /var/www/html/env.html
  EOF

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

  user_data = <<-EOF
    #!/bin/bash
    dnf -y update
    dnf -y install httpd git

    systemctl enable httpd
    systemctl start httpd

    cd /var/www/html
    rm -rf ./*

    git clone https://github.com/adreseiker/FinalExamSQA114-G1.git app || true
    if [ -d app ]; then
      cp -r app/* /var/www/html/
    fi

    cat > /var/www/html/prod.html <<HTML
    <h1>Production_Env1</h1>
    <p>Routed by ALB</p>
    HTML
  EOF

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

  user_data = <<-EOF
    #!/bin/bash
    dnf -y update
    dnf -y install httpd git

    systemctl enable httpd
    systemctl start httpd

    cd /var/www/html
    rm -rf ./*

    git clone https://github.com/adreseiker/FinalExamSQA114-G1.git app || true
    if [ -d app ]; then
      cp -r app/* /var/www/html/
    fi

    cat > /var/www/html/prod.html <<HTML
    <h1>Production_Env2</h1>
    <p>Routed by ALB</p>
    HTML
  EOF

  tags = merge(local.common_tags, { Name = "Production_Env2" })
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-6.1-*"]
  }
}
