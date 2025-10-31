#!/bin/bash
set -e
echo "Agent setup: updating and installing Java 21 + git"
dnf -y update
dnf -y install java-21-amazon-corretto git
echo "Agent setup: done."
