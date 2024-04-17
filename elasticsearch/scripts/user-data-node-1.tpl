#!/bin/bash

# Function to check if the device is available
check_device1_available() {
    lsblk | grep -q "nvme1n1"
    return $?
}

check_device2_available() {
    lsblk | grep -q "nvme2n1"
    return $?
}
# Check if /dev/nvme1n1 is available in lsblk, waiting for it to appear
while true
do
    if check_device1_available && check_device2_available; then
        break  
    fi
    sleep 5
done

# Mount the volumes
mkfs -t ext4 /dev/nvme1n1
mkdir -p /datadir1
mount /dev/nvme1n1 /datadir1

mkfs -t ext4 /dev/nvme2n1
mkdir -p /datadir2
mount /dev/nvme2n1 /datadir2

# Extract UUID for /datadir1 and /datadir2
UUID1=$(sudo lsblk -no UUID /dev/nvme1n1)
UUID2=$(sudo lsblk -no UUID /dev/nvme2n1)

# Check if UUIDs were retrieved successfully
if [ -z "$UUID1" ] || [ -z "$UUID2" ]; then
  echo "Failed to retrieve UUIDs for /datadir1 or /datadir2."
  exit 1
fi

# Add UUID entries to /etc/fstab
echo "UUID=$UUID1 /datadir1 ext4 defaults 0 0" | sudo tee -a /etc/fstab
echo "UUID=$UUID2 /datadir2 ext4 defaults 0 0" | sudo tee -a /etc/fstab

echo "UUIDs for /datadir1 and /datadir2 added to /etc/fstab."

sudo mount -a

# Install Java
sudo apt update -y
sudo apt install default-jre -y
sudo apt install default-jdk -y
sleep 2

# Install elasticsearch
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
sudo apt-get install apt-transport-https
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list
sudo apt-get update && sudo apt-get install elasticsearch
sleep 2

# Susytem Configurations
ulimit -n 65535
ulimit -l unlimited 
sudo swapoff -a
sudo locale-gen "en_US.UTF-8"
echo "vm.max_map_count=262144" >> /etc/sysctl.conf
echo "vm.swappiness=1" >> /etc/sysctl.conf
echo "elasticsearch soft memlock unlimited" >> /etc/security/limits.conf
echo "elasticsearch hard memlock unlimited" >> /etc/security/limits.conf
echo "elasticsearch  -  nofile  65535" >> /etc/security/limits.conf
sysctl -p

#Elasticsearch data directories
mkdir /datadir1/elasticsearch
mkdir /datadir2/elasticsearch
sudo chown -R elasticsearch:elasticsearch /datadir1/elasticsearch
sudo chown -R elasticsearch:elasticsearch /datadir2/elasticsearch

#Overrride systemd config
mkdir -p /etc/systemd/system/elasticsearch.service.d
cat <<EOF > /etc/systemd/system/elasticsearch.service.d/override.conf 
[Service]
LimitMEMLOCK=infinity
EOF

# Configure the elasticsearch.yml file to create cluster
local_ip=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
echo "bootstrap.memory_lock: true" >> /etc/elasticsearch/elasticsearch.yml
echo "cluster.name: ${environment}-common-es-cluster" >> /etc/elasticsearch/elasticsearch.yml
echo "node.name: ${environment}-common-es-node-1" >> /etc/elasticsearch/elasticsearch.yml
echo "discovery.seed_hosts: [\"127.0.0.1\",\"${es_node_0_ip}\"]" >> /etc/elasticsearch/elasticsearch.yml
echo "network.host: 0.0.0.0" >> /etc/elasticsearch/elasticsearch.yml
echo "transport.host: 0.0.0.0" >> /etc/elasticsearch/elasticsearch.yml
echo "gateway.expected_data_nodes: 3" >> /etc/elasticsearch/elasticsearch.yml
echo "gateway.recover_after_data_nodes: 3" >> /etc/elasticsearch/elasticsearch.yml
echo "indices.memory.index_buffer_size: 20%" >> /etc/elasticsearch/elasticsearch.yml
echo "indices.recovery.max_bytes_per_sec: 256mb" >> /etc/elasticsearch/elasticsearch.yml
echo "cluster.routing.allocation.node_concurrent_recoveries: 3" >> /etc/elasticsearch/elasticsearch.yml

sed -i "s/^cluster\.initial_master_nodes:.*/cluster.initial_master_nodes: [\"${es_node_0_ip}\"]/" /etc/elasticsearch/elasticsearch.yml
sed -i 's/^path.data:.*/path.data: \/var\/lib\/elasticsearch\/,\/datadir1\/elasticsearch\/,\/datadir2\/elasticsearch\//' /etc/elasticsearch/elasticsearch.yml
sed -i 's/^xpack.security.enabled:.*/xpack.security.enabled: false/' /etc/elasticsearch/elasticsearch.yml
sed -i 's/^xpack.security.enrollment.enabled:.*/xpack.security.enrollment.enabled: false/' /etc/elasticsearch/elasticsearch.yml
sed -i 's/^\s*enabled:\s*true/  enabled: false/' /etc/elasticsearch/elasticsearch.yml

# Start elasticsearch service
sudo systemctl stop elasticsearch.service
sudo systemctl start elasticsearch.service
sleep 2
sudo systemctl status elasticsearch.service

# Install and Configure Kibana

sudo apt-get update && sudo apt-get install kibana
sudo /bin/systemctl enable kibana.service
sudo sed -i 's/#server.host: "localhost"/server.host: 0.0.0.0/' /etc/kibana/kibana.yml
sudo sed -i 's/#server.port: 5601/server.port: 5601/' /etc/kibana/kibana.yml
sudo sed -i 's/#elasticsearch.hosts: \["http:\/\/localhost:9200"\]/elasticsearch.hosts: \["http:\/\/localhost:9200"\]/' /etc/kibana/kibana.yml
sudo systemctl stop kibana.service
sudo systemctl start kibana.service
sudo systemctl status kibana.service

# Install and configure Node-Exporter
cat <<EOF > /tmp/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target
[Service]
User=ubuntu
Group=ubuntu
Type=simple
ExecStart=/usr/local/bin/node_exporter
[Install]
WantedBy=multi-user.target
EOF

mkdir -p ~/node_exporter
cd ~/node_exporter
curl -LO https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-arm64.tar.gz
tar -xzvf node_exporter-0.18.1.linux-arm64.tar.gz
cd node_exporter-0.18.1.linux-arm64
sudo /bin/cp -f node_exporter /usr/local/bin/
cd ~
sudo rm -rf ~/node_exporter
sudo cp /tmp/node_exporter.service /etc/systemd/system/node_exporter.service
sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter
sudo systemctl status node_exporter

## Creating a symlink for smooth execution of Ansible Playbook
sudo ln -s /usr/bin/python3 /usr/bin/python
