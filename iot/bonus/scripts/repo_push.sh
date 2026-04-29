#!/bin/bash

if [ -z "$1" ]; then
  echo "❌ Error: Please provide your GitLab root password."
  echo "Usage: ./03-push-repo.sh <ROOT_PASSWORD>"
  exit 1
fi

if [ ! -f "../confs/gitlab-ci.yml" ]; then # mybe is a hidden file
  echo "❌ Error: gitlab-ci.yml not found!"
  echo "Please make sure your pipeline file is in this same folder before running the script."
  exit 1
fi

ROOT_PASSWORD=$1
GITLAB_URL="http://gitlab.k3d.local"
PROJECT_NAME="iot-bonus"

echo "🚀 Starting 100% Automated GitOps Push..."

echo "🔑 Authenticating with GitLab API..."
TOKEN=$(curl -s --request POST "$GITLAB_URL/oauth/token" \
     --data "grant_type=password&username=root&password=$ROOT_PASSWORD" | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
  echo "❌ Failed to get API token. Check your password or wait for GitLab to fully boot."
  exit 1
fi

echo "🦊 Creating blank project '$PROJECT_NAME' via API..."
curl -s --request POST "$GITLAB_URL/api/v4/projects" \
     --header "Authorization: Bearer $TOKEN" \
     --data "name=$PROJECT_NAME" \
     --data "visibility=public" > /dev/null

echo "✅ Project '$PROJECT_NAME' is ready on the server!"


echo "📦 Initializing Git and pushing to private GitLab..."
rm -rf .git # Clean up just in case you ran this before
git init
git add .
git commit -m "Initial commit with Kubernetes manifests and CI/CD pipeline"

git branch -M main

GIT_PUSH_URL="http://root:${ROOT_PASSWORD}@gitlab.k3d.local/root/${PROJECT_NAME}.git"
git remote add origin "$GIT_PUSH_URL"

git push -u origin main --force

echo "🎉 Success! Your code is now live at: http://gitlab.k3d.local/root/$PROJECT_NAME"