#!/bin/bash

# Install K3s on the master node
apt update

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --write-kubeconfig-mode 644 --node-ip=192.168.56.110" sh -

# Wait for K3s to be ready
sleep 10



# Get the token and save it to shared folder
TOKEN=$(cat /var/lib/rancher/k3s/server/node-token)
echo $TOKEN > /vagrant/shared/token

echo "Server ready!"