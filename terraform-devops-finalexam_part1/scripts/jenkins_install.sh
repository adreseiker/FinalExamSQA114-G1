#!/bin/bash
set -e

echo "=== [1/5] Updating system ==="
sudo dnf -y update

echo "=== [2/5] Installing base tools ==="
sudo dnf -y install java-21-amazon-corretto git nodejs npm curl wget

echo "=== [3/5] Adding Jenkins repo ==="
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# dnf entiende los repos de yum
sudo dnf -y install jenkins

echo "=== [4/5] Enabling Jenkins ==="
sudo systemctl enable jenkins
sudo systemctl start jenkins

echo "=== [5/5] Creating admin user via Groovy ==="
sudo mkdir -p /var/lib/jenkins/init.groovy.d
sudo bash -c 'cat > /var/lib/jenkins/init.groovy.d/01-admin.groovy << "EOF"
#!groovy
import jenkins.model.*
import hudson.security.*

def instance = Jenkins.getInstance()
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudanRealm = hudsonRealm
hudsonRealm.createAccount("admin", "Admin123!")
instance.setSecurityRealm(hudsonRealm)

def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
instance.setAuthorizationStrategy(strategy)

instance.save()
println("--> Admin user created: admin / Admin123!")
EOF'

sudo systemctl restart jenkins

# mostrar la IP pública real
PUBIP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 || echo "<public-ip>")
echo "Jenkins ready: http://$PUBIP:8080"
echo "user: admin"
echo "pass: Admin123!"
