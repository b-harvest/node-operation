#!/bin/sh

# 
# SET THESE VARIABLES FOR YOUR OWN SETTING
#
VERSION=0.21.0
WebExternalURL="http://localhost"
WebListenAddr=":9093"

# Create alertmanager system user and group for security purposes 
# isolate the ownership to prevent the user to log into the server
echo "-> Creating system user and group..."
sudo useradd -M -s /bin/false alertmanager

# Create the necessarty directories for storing alertmanager' files and data
echo "-> Creating necessary directories..."
sudo mkdir /etc/alertmanager
sudo mkdir /var/lib/alertmanager

# Set the user and group ownership of the binaries and folders to alertmanager
echo "-> Setting the user and group ownership of the binaries and folders..."
sudo chown -R alertmanager:alertmanager /etc/alertmanager
sudo chown -R alertmanager:alertmanager /var/lib/alertmanager

# Install the latest AlertManager and unzip it
echo "-> Installing the latest AlertManager..."
cd $HOME
wget https://github.com/prometheus/alertmanager/releases/download/v$VERSION/alertmanager-$VERSION.linux-amd64.tar.gz
tar -zxvf alertmanager-$VERSION.linux-amd64.tar.gz

# Remove tar file as they are no long needed
rm -rf alertmanager-$VERSION.linux-amd64.tar.gz &> /dev/null

# Copy prometheus and promtool binaries 
echo "-> Copying prometheus and promtool binaries..."
sudo cp alertmanager-$VERSION.linux-amd64/alertmanager /usr/local/bin
sudo cp alertmanager-$VERSION.linux-amd64/amtool /usr/local/bin
sudo chown alertmanager:alertmanager /usr/local/bin/alertmanager
sudo chown alertmanager:alertmanager /usr/local/bin/amtool

# Copy default configuration file
sudo cp alertmanager-$VERSION.linux-amd64/alertmanager.yml /etc/alertmanager/alertmanager.yml

# Create AlertManager systemd service file 
echo '[Unit]
Description= Alertmanager for Prometheus Server
After=network.target

[Service]
User=alertmanager
Group=alertmanager
ExecStart=/usr/local/bin/alertmanager \
    --config.file=/etc/alertmanager/alertmanager.yml \
    --web.external-url='$WebExternalURL' \
    --web.listen-address='$WebListenAddr' \
    --storage.path="/var/lib/alertmanager/" \
    --data.retention="120h" \
    --cluster.listen-address="" 

[Install]
WantedBy=multi-user.target
' >> alertmanager.service

# Copy alertmanager.service to Linux convention systmed folder
sudo cp -f alertmanager.service /etc/systemd/system/alertmanager.service 
rm -rf alertmanager.service &> /dev/null

# Start the service up and running
echo "-> Running alertmanager service..."
sudo systemctl daemon-reload
sudo systemctl start alertmanager

# Check the service's status 
echo "-> Verifying AlertManager is running by checking the service's status..."
sudo systemctl status alertmanager