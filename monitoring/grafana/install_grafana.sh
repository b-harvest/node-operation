#!/bin/sh

# Package Details: https://grafana.com/docs/grafana/latest/installation/debian/#package-details
# Installs binaries after running the script: /usr/sbin/grafana-server, /usr/sbin/grafana-cli
# Default file (environment vars) localtion: /etc/grafana/grafana.ini
# Log file localtion: /var/log/grafana/grafana.log

# Update the system and install dependancies
echo "-> Updating the system and install dependencies..."
sudo apt-get install -y apt-transport-https
sudo apt-get install -y software-properties-common wget
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
sudo add-apt-repository "deb https://packages.grafana.com/enterprise/deb stable main"
sudo apt-get update

# Install the latest grafana from APT repository since it is easy to upgrade
# https://grafana.com/docs/grafana/latest/installation/debian/
echo "-> Installing the latest grafana..."
sudo apt-get install grafana

# Start Grafana server using systemd
sudo systemctl daemon-reload
sudo systemctl start grafana-server

# Configure the Grafana server to start at boot
sudo systemctl enable grafana-server.service

# Check the service's status 
echo "-> Verifying Grafana is running by checking the service's status..."
sudo systemctl status grafana-server


