#!/bin/bash
set -e

echo "[1/8] Updating system..."
dnf -y update --allowerasing

echo "[2/8] Base tools (Java, Git, Node, npm, SSH, unzip)..."
# NO instalamos curl porque ya viene y causa conflicto
dnf -y install --allowerasing java-21-amazon-corretto git nodejs npm openssh-clients unzip

echo "[3/8] Install Google Chrome (stable)..."
dnf -y install --allowerasing https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm

echo "[4/8] Extra libs for headless..."
dnf -y install --allowerasing atk cups-libs gtk3 libXcomposite libXcursor libXdamage libXrandr libXScrnSaver libXtst pango alsa-lib xorg-x11-server-Xvfb || true

echo "[5/8] Get Chrome version..."
CHROME_VER_FULL=$(google-chrome --version | awk '{print $3}')
CHROME_MAJOR=$(echo "$CHROME_VER_FULL" | cut -d. -f1)

echo "[6/8] Download matching ChromeDriver..."
cd /tmp
curl -LO "https://storage.googleapis.com/chrome-for-testing-public/${CHROME_VER_FULL}/linux64/chromedriver-linux64.zip"
unzip -o chromedriver-linux64.zip
mv chromedriver-linux64/chromedriver /usr/local/bin/chromedriver
chmod +x /usr/local/bin/chromedriver

echo "[7/8] Show versions..."
google-chrome --version || true
chromedriver --version || true

echo "[8/8] Agent setup DONE."
