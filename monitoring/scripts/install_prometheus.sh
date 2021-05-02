#!/bin/sh

# Prometheus is a powerful, open-source monitoring system that collects metrics from your services and stores them in a time-series database. 
# It offers a multi-dimensional data model, a flexible query language, and diverse visualization possibilities through tools like Grafana.
# 
# SET THESE VARIABLES FOR YOUR OWN SETTING
#
VERSION=2.26.0
WebExternalURL="http://localhost"
WebListenAddr=":9090"

# Update the system and install dependancies
echo "> Updating the system and install dependencies..."
sudo apt update
sudo apt install build-essential jq -y

# Create Prometheus system user and group for security purposes 
# isolate the ownership to prevent the user to log into the server
echo "> Creating system user and group..."
sudo useradd -M -s /bin/false prometheus

# Create the necessary directories for storing Prometheus' files and data
echo "> Creating necessary directories..."
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus

# Set the user and group ownership of the binaries and folders to prometheus
echo "> Setting the user and group ownership of the binaries and folders..."
sudo chown -R prometheus:prometheus /etc/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus

# Install the latest Prometheus and unzip it
echo "> Installing the latest Prometheus..."
cd $HOME
wget https://github.com/prometheus/prometheus/releases/download/v$VERSION/prometheus-$VERSION.linux-amd64.tar.gz 
tar -zxvf prometheus-$VERSION.linux-amd64.tar.gz

# Remove tar file as they are no long needed
rm -rf prometheus-$VERSION.linux-amd64.tar.gz &> /dev/null

# Copy prometheus and promtool binaries 
echo "> Copying prometheus and promtool binaries..."
sudo cp prometheus-$VERSION.linux-amd64/{prometheus,promtool} /usr/local/bin
sudo chown prometheus:prometheus /usr/local/bin/{prometheus,promtool}

# Copy consoles and console_libraries directories
echo "> Copying console, console_libraries..."
sudo cp -r prometheus-$VERSION.linux-amd64/{consoles,console_libraries} /etc/prometheus
sudo chown -R prometheus:prometheus /etc/prometheus/{consoles,console_libraries}

# Copy default configuration file
sudo cp prometheus-$VERSION.linux-amd64/prometheus.yml /etc/prometheus/prometheus.yml

# Create prometheus systemd service file 
echo '[Unit]
Description=Prometheus
After=network.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries \
    --web.external-url='$WebExternalURL' \
    --web.listen-address='$WebListenAddr' \
    --storage.tsdb.path=/var/lib/prometheus/ \
    --storage.tsdb.retention="7d"

[Install]
WantedBy=multi-user.target
' >> prometheus.service

# Copy prometheus.service to Linux convention systmed folder
sudo cp -f prometheus.service /etc/systemd/system/prometheus.service 
rm -rf prometheus.service &> /dev/null

# Start the service up and running
echo "> Running prometheus service..."
sudo systemctl daemon-reload
sudo systemctl start prometheus

# Check the service's status 
echo "> Verifying Prometheus is running by checking the service's status..."
sudo systemctl status prometheus

echo '[Unit]
Description=Prometheus
After=network.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries \
    --web.external-url='http://localhost' \
    --web.listen-address=':9090' \
    --storage.tsdb.path=/var/lib/prometheus/ \
    --storage.tsdb.retention="7d"

[Install]
WantedBy=multi-user.target
' >> prometheus.service
