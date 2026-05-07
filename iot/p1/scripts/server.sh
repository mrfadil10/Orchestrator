#!/bin/bash

# Install K3s on the master node
apt update
# apt install curl -y
#--bind-address=192.168.56.110 --advertise-address=192.168.56.110 --flannel-iface=eth1
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --write-kubeconfig-mode 644 --node-ip=192.168.56.110" sh -

# Wait for K3s to be ready
sleep 10

# Make sure kubectl is set up for the vagrant user
# mkdir -p /home/vagrant/.kube
# sudo cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
# chown -R vagrant:vagrant /home/vagrant/.kube/config

# Get the token and save it to shared folder
TOKEN=$(cat /var/lib/rancher/k3s/server/node-token)
echo $TOKEN > /vagrant/shared/token

echo "Server ready!"