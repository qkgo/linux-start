#!/bin/sh


sudo apt-get  install wget -y || true

sudo yum install wget -y || true

 sudo systemctl stop node_exporter || true

 sudo systemctl disable node_exporter || true

# Set the Node Exporter version to download
NODE_EXPORTER_VERSION="1.5.0"

# Download the Node Exporter binary
wget https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz

# check file 

# check file
if test -e ${PWD}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz ; then
    echo "file downloaded"
else
    echo "file not found"
    exit -5;
fi


# Extract the binary
tar -zxvf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz

chmod +x node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter

# Move the binary to a standard location
sudo cp node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter /usr/local/bin

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

sleep 1
sudo nohup systemctl status node_exporter . & 
sleep 1

cat nohup.out

# Verify if the Node Exporter is working
sleep 5
wget --spider --quiet http://localhost:9100/metrics

if [ $? -eq 0 ]; then
    echo "Node Exporter is working correctly"
else
    echo "Node Exporter is not working, removing the installed files and service"
    journalctl -u node_exporter
    sleep 1
    sudo systemctl stop node_exporter
    sudo systemctl disable node_exporter
    sudo rm /etc/systemd/system/node_exporter.service
    sudo rm /usr/local/bin/node_exporter
    sudo systemctl daemon-reload
fi

### OPTIONs
rm -rf node_exporter-${NODE_EXPORTER_VERSION}


### TODO workat https/tls
# https://github.com/prometheus/exporter-toolkit/blob/v0.1.0/https/README.md
