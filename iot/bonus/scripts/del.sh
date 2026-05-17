#!/bin/bash

echo "🧨 WARNING: This will completely destroy your K3d cluster and delete GitLab."
read -p "Are you absolutely sure you want to proceed? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "🛑 Cleanup aborted."
    exit 1
fi

echo "🧹 Starting full teardown on DigitalOcean..."

# 1. Delete the K3d cluster (this wipes out GitLab, Argo CD, and all namespaces)
echo "🔥 Destroying the K3d cluster 'iot-cluster'..."
k3d cluster delete iot-cluster

# 2. Clean up orphaned Docker volumes left behind by K3d
echo "🧽 Cleaning up leftover Docker volumes..."
docker volume prune -f

echo "✅ Server is completely clean and reset!"