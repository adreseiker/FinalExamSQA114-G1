#!/bin/bash
set -e
dnf -y update
dnf -y install httpd
systemctl enable httpd
systemctl start httpd

# simple index to see the env
echo "<h1>Server ready from Terraform</h1>" > /var/www/html/index.html