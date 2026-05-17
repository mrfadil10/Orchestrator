#!/bin/bash

if [ -z "$1" ]; then
  echo "❌ Error: Please provide your GitLab root password."
  echo "Usage: ./repo_push.sh <ROOT_PASSWORD>"
  exit 1
fi

# Clean the password of any accidental invisible spaces or newlines
ROOT_PASSWORD=$(echo "$1" | tr -d '[:space:]')
GITLAB_URL="http://gitlab.k3d.local"
PROJECT_NAME="iot-bonus"

echo "🚀 Starting Automated GitOps Push..."

echo "🔑 Authenticating with GitLab API..."
# Using data-urlencode to prevent special characters from breaking the curl request
RAW_RESPONSE=$(curl -s --request POST "$GITLAB_URL/oauth/token" \
     --data-urlencode "grant_type=password" \
     --data-urlencode "username=root" \
     --data-urlencode "password=$ROOT_PASSWORD")

TOKEN=$(echo "$RAW_RESPONSE" | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
  echo "❌ Failed to get API token."
  echo "Here is the exact error from the server: $RAW_RESPONSE"
  exit 1
fi

echo "🦊 Creating blank project '$PROJECT_NAME' via API..."
curl -s --request POST "$GITLAB_URL/api/v4/projects" \
     --header "Authorization: Bearer $TOKEN" \
     --data "name=$PROJECT_NAME" \
     --data "visibility=public" > /dev/null

echo -e "\033[32mProject '$PROJECT_NAME' is ready on the server!\033[0m"

echo "Initializing Git and pushing to private GitLab..."
rm -rf .git
git init
git config --global user.name "IoT_Admin"
git config --global user.email "admin@k3d.local"
git add .
git commit -m "Initial commit with Kubernetes manifests and CI/CD pipeline"

git branch -M main

GIT_PUSH_URL="http://root:${ROOT_PASSWORD}@gitlab.k3d.local/root/${PROJECT_NAME}.git"
git remote add origin "$GIT_PUSH_URL"

git push -u origin main --force

echo -e "\033[32mSuccess! Your code is now live at: http://gitlab.k3d.local/root/$PROJECT_NAME\033[0m"

echo "Telling Argo CD to track this new repository..."
kubectl apply -f app.yaml -n argocd
echo "getting argocd password..."
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo