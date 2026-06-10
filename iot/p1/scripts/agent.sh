#!/bin/bash

while [ ! -f /vagrant/token ]; do
    echo "Waiting for server token..."
    sleep 5
done

TOKEN=$(cat /vagrant/token)

curl -sfL https://get.k3s.io | K3S_URL="https://192.168.56.110:6443" K3S_TOKEN="$TOKEN" INSTALL_K3S_EXEC="--node-ip=192.168.56.111" sh -
echo "Worker ready!"