#!/bin/bash
set -e

# retry por si dnf está ocupado
for i in {1..5}; do
  dnf -y update && break
  echo "dnf locked, retrying..."
  sleep 5
done

# NO instalamos curl (ya lo trae AL2023) y usamos --allowerasing
dnf -y install --allowerasing java-21-amazon-corretto git nodejs npm wget

wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

dnf -y install jenkins
systemctl enable jenkins
systemctl start jenkins
