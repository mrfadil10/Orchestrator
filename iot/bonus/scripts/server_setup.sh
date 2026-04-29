#!/bin/bash
echo "🚀 Starting Part 1: Cluster & GitLab Setup on DigitalOcean..."

echo "📦 Creating K3d cluster..."
k3d cluster create iot-cluster -p "80:80@loadbalancer" -p "443:443@loadbalancer"


echo "🦊 Installing GitLab via Helm (this may take a few minutes)..."
helm repo add gitlab https://charts.gitlab.io/
helm repo update
helm upgrade --install my-gitlab gitlab/gitlab -f ../confs/gitlab-values.yaml --namespace gitlab --create-namespace # to check later


echo "🔑 Waiting for GitLab to generate the root password..."
sleep 10
echo "Your GitLab root password is:"
kubectl get secret my-gitlab-gitlab-initial-root-password -n gitlab -o jsonpath="{.data.password}" | base64 --decode ; echo ""
echo "✅ Droplet setup complete!"