#!/bin/sh
# https://prometheus.io/docs/guides/node-exporter/
# https://prometheus.io/download/#node_exporter




# Set the Node Exporter version to download
NODE_EXPORTER_VERSION="1.5.0"

# Download the Node Exporter binary
wget https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz

# Extract the binary
tar xvfz node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz

# Move the binary to a standard location
sudo mv node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter /usr/local/bin

# Create a systemd service file for Node Exporter
echo "[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=root
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=default.target" | sudo tee /etc/systemd/system/node_exporter.service

# Reload the systemd daemon to recognize the new service
sudo systemctl daemon-reload

# Enable and start the Node Exporter service
sudo systemctl enable node_exporter
sudo systemctl start node_exporter

# Verify if the Node Exporter is working
sleep 5
wget --spider --quiet http://localhost:9100/metrics

if [ $? -eq 0 ]; then
    echo "Node Exporter is working correctly"
else
    echo "Node Exporter is not working, removing the installed files and service"
    sudo systemctl stop node_exporter
    sudo systemctl disable node_exporter
    sudo rm /etc/systemd/system/node_exporter.service
    sudo rm /usr/local/bin/node_exporter
    sudo systemctl daemon-reload
fi
