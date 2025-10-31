#!/bin/bash
set -e

echo "=== [1/5] Updating system ==="
dnf -y update

echo "=== [2/5] Installing base tools ==="
dnf -y install java-21-amazon-corretto git nodejs npm curl wget

echo "=== [3/5] Adding Jenkins repo ==="
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

dnf -y install jenkins

systemctl enable jenkins
systemctl start jenkins

mkdir -p /var/lib/jenkins/init.groovy.d
cat > /var/lib/jenkins/init.groovy.d/01-admin.groovy << "EOF"
#!groovy
import jenkins.model.*
import hudson.security.*

def instance = Jenkins.getInstance()
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount("admin", "Admin123!")
instance.setSecurityRealm(hudsonRealm)

def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
instance.setAuthorizationStrategy(strategy)

instance.save()
println("--> Admin user created: admin / Admin123!")
EOF

PUBIP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 || echo "<public-ip>")
echo "Jenkins ready at: http://$PUBIP:8080"
echo "user: admin"
echo "pass: Admin123!"
