#!/bin/bash

if [ -z "$1" ]; then
  echo "❌ Error: Please provide your private GitLab repository URL."
  echo "Usage: ./03-push-repo.sh http://gitlab.k3d.local/root/iot-bonus.git"
  exit 1
fi

REPO_URL=$1

echo "🚀 Preparing repository for GitOps deployment..."

echo "📦 Initializing Git and pushing to private GitLab..."
git init
git add .
git commit -m "Initial commit with Kubernetes manifests and CI/CD pipeline"
git remote add origin $REPO_URL
git push -u origin master

echo "✅ Code pushed successfully! Check your GitLab UI to see the pipeline running."