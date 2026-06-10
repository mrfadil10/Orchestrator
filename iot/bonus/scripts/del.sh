#!/bin/bash

read -p "Are you absolutely sure you want to proceed? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "🛑 Cleanup aborted."
    exit 1
fi

echo "Starting full teardown on DigitalOcean..."

echo "Destroying the K3d cluster 'iot-cluster'..."
k3d cluster delete iot-cluster

echo "Cleaning up leftover Docker volumes..."
docker volume prune -f

rm argocd-install-ready.yaml

echo "✅ Server is completely clean and reset!"