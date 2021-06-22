#!/bin/sh

# Node Exporter provides detailed information about the system, including CPU, disk, and memory usage
VERSION=1.1.2
PORT=9100

# Create node_exporter system user and group for security purposes 
# isolate the ownership to prevent the user to log into the server
echo "> Creating system user and group..."
sudo useradd -M -s /bin/false node_exporter

# Create the necessary directories for storing node_exporter' files and data
echo "> Creating necessary directories..."
sudo mkdir /etc/node_exporter
sudo mkdir /var/lib/node_exporter

# Set the user and group ownership of the binaries and folders to node_exporter
echo "> Setting the user and group ownership of the binaries and folders..."
sudo chown -R node_exporter:node_exporter /etc/node_exporter
sudo chown -R node_exporter:node_exporter /var/lib/node_exporter

# Install the latest Node Exporter and unzip it
echo "> Installing the latest Node Exporter..."
cd $HOME
wget https://github.com/prometheus/node_exporter/releases/download/v$VERSION/node_exporter-$VERSION.linux-amd64.tar.gz
tar -zxvf node_exporter-$VERSION.linux-amd64.tar.gz

# Copy prometheus and promtool binaries 
echo "> Copying prometheus and promtool binaries..."
sudo cp node_exporter-$VERSION.linux-amd64/node_exporter /usr/local/bin
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter

# Remove tar file as they are no long needed
rm -rf node_exporter-$VERSION.linux-amd64.tar.gz &> /dev/null
rm -rf node_exporter-$VERSION.linux-amd64 &> /dev/null

# Create AlertManager systemd service file 
# node_exporter has default disabled flags
# --collector.systemd will provide systemd services metrics
echo '[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter \
    --collector.systemd \
    --web.listen-address=':$PORT'

[Install]
WantedBy=multi-user.target' >> node_exporter.service

# Copy node_exporter.service to Linux convention systmed folder
sudo cp -f node_exporter.service /etc/systemd/system/node_exporter.service 
rm -rf node_exporter.service &> /dev/null

# Start the service up and running
echo "> Running node_exporter service..."
sudo systemctl daemon-reload
sudo systemctl start node_exporter

# Check the service's status 
echo "> Verifying Node Exporter is running by checking the service's status..."
sudo systemctl status node_exporter
