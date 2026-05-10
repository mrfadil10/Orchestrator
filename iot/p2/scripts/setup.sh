#!/bin/bash

apt update

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --write-kubeconfig-mode 644 --node-ip=192.168.56.110 " sh -


sleep 10

kubectl apply -f /vagrant/confs

echo "Server ready a jemi!!!"