#!/bin/bash

apt-get update -y

apt-get install curl

# wait for token to be available
while [ ! -f /vagrant/shared/token ]; do
    echo "Waiting for server token..."
    sleep 5
done

# read the token
TOKEN=$(cat /vagrant/shared/token)

# install K3s in agent mode and join the cluster
curl -sfL https://get.k3s.io | K3S_URL="https://192.168.56.110:6443" K3S_TOKEN="$TOKEN" INSTALL_K3S_EXEC="--node-ip=192.168.56.111 --flannel-iface=eth1" sh -

echo "Worker ready!"