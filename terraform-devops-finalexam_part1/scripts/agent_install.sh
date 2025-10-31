#!/bin/bash
set -e

echo "[1/6] Updating system..."
dnf -y update

echo "[2/6] Installing Java 21 and git..."
dnf -y install java-21-amazon-corretto git

echo "[3/6] Installing Node.js + npm..."
# en AL2023 suele haber nodejs en dnf
dnf -y install nodejs npm

echo "[4/6] Installing SSH client tools..."
dnf -y install openssh-clients

echo "[5/6] Installing Chromium (browser for Selenium)..."
dnf -y install chromium

echo "[6/6] Installing chromedriver..."
dnf -y install chromedriver || {
  echo "chromedriver package not found in repo, downloading manually..."
  cd /tmp
  CHROME_VER=$(chromium --version | awk '{print $2}' | cut -d. -f1)
  curl -LO https://chromedriver.storage.googleapis.com/LATEST_RELEASE_${CHROME_VER}
  DRIVER_VER=$(cat LATEST_RELEASE_${CHROME_VER})
  curl -LO https://chromedriver.storage.googleapis.com/${DRIVER_VER}/chromedriver-linux64.zip
  unzip chromedriver-linux64.zip
  mv chromedriver /usr/local/bin/
  chmod +x /usr/local/bin/chromedriver
}

echo "Agent setup: DONE."