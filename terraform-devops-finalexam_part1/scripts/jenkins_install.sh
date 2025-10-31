#!/bin/bash
set -e
echo "Step: Updating and preparing system ==="
sudo yum -y update
sudo yum -y install nodejs npm git java-21-amazon-corretto wget

echo "=== Installing Jenkins ==="
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum -y install jenkins

echo "Step: Enabling and starting Jenkins service ==="
sudo systemctl enable jenkins
sudo systemctl start jenkins

# opcional: swap / tmp
sudo fallocate -l 1G /swapfile_extend_1GB || true
sudo mount -o remount,size=5G /tmp/ || true

# Wait for Jenkins to create its directory structure
sleep 25

echo "Step: Setting up initial Jenkins configuration ==="
sudo mkdir -p /var/lib/jenkins/init.groovy.d

# --- Create admin user automatically ---
sudo bash -c 'cat <<EOF > /var/lib/jenkins/init.groovy.d/01-basic-security.groovy
#!groovy

import jenkins.model.*
import hudson.security.*

def instance = Jenkins.getInstance()

println("--> Creating default admin user")

def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount("adreseiker", "1Cadillac2")
instance.setSecurityRealm(hudsonRealm)

def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
instance.setAuthorizationStrategy(strategy)
instance.save()

println("--> Admin user created: adreseiker / 1Cadillac2")
EOF'

# --- Install default plugins automatically ---
sudo bash -c 'cat <<EOF > /var/lib/jenkins/init.groovy.d/02-install-plugins.groovy
import jenkins.model.*
import hudson.model.*

def instance = Jenkins.getInstance()
def pm = instance.getPluginManager()
def uc = instance.getUpdateCenter()
uc.updateAllSites()

def plugins = [
  "git",
  "workflow-aggregator",   // Jenkins Pipeline
  "credentials",
  "ssh-slaves",
  "blueocean",
  "docker-workflow",
  "matrix-auth",
  "job-dsl",
  "pipeline-github-lib",
  "ws-cleanup"
]

println("--> Installing default plugins: " + plugins)

plugins.each { pluginName ->
  if (!pm.getPlugin(pluginName)) {
    def plugin = uc.getPlugin(pluginName)
    if (plugin) {
      println("Installing plugin: ${pluginName}")
      plugin.deploy()
    } else {
      println("Plugin not found: ${pluginName}")
    }
  } else {
    println("Plugin already installed: ${pluginName}")
  }
}

instance.save()
println("--> Plugin installation complete")
EOF'

echo "Step:  Restarting Jenkins to apply all settings ==="
sudo systemctl restart jenkins

echo "Step: Jenkins setup complete ==="
echo "Login with: http://<public-ip>:8080"
echo "Username: adreseiker"
echo "Password: 1Cadillac2"
