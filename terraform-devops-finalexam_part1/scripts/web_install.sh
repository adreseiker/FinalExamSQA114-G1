#!/bin/bash
set -e

dnf -y update
dnf -y install httpd
systemctl enable httpd
systemctl start httpd

echo "<h1>Web server deployed by Terraform</h1>" > /var/www/html/index.html
