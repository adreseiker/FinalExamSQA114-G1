#!/bin/bash
set -e

echo "[1/7] Updating system..."
dnf -y update

echo "[2/7] Installing Java 21 and Git..."
dnf -y install java-21-amazon-corretto git

echo "[3/7] Installing Node.js and npm..."
dnf -y install nodejs npm

echo "[4/7] Installing SSH client..."
dnf -y install openssh-clients

echo "[5/7] Installing curl and unzip..."
dnf -y install curl unzip

echo "[6/7] Installing Chromium..."
dnf -y install chromium

echo "[7/7] Installing ChromeDriver..."
dnf -y install chromedriver || {
  echo "chromedriver package not found, downloading matching version..."
  cd /tmp
  CHROME_VER=$(chromium --version | awk '{print $2}' | cut -d. -f1)
  curl -LO https://chromedriver.storage.googleapis.com/LATEST_RELEASE_${CHROME_VER}
  DRIVER_VER=$(cat LATEST_RELEASE_${CHROME_VER})
  curl -LO https://chromedriver.storage.googleapis.com/${DRIVER_VER}/chromedriver-linux64.zip
  unzip -o chromedriver-linux64.zip
  mv chromedriver /usr/local/bin/
  chmod +x /usr/local/bin/chromedriver
}

echo "Agent setup: DONE."
