#!/bin/bash
echo "Droplet Setup..."

echo "Installing Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    echo "Docker installed."
else
    echo "Docker is already installed, skipping..."
fi

echo "Installing kubectl..."
if ! command -v kubectl &> /dev/null; then
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
    echo "kubectl installed."
else
    echo "kubectl is already installed, skipping..."
fi

echo "Installing K3d..."
if ! command -v k3d &> /dev/null; then
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
    echo "K3d installed."
else
    echo "K3d is already installed, skipping..."
fi

echo "Installing Helm..."
if ! command -v helm &> /dev/null; then
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh
    rm get_helm.sh
    echo "Helm installed."
else
    echo "Helm is already installed, skipping..."
fi

# ==========================================
# CLUSTER & GITLAB DEPLOYMENT
# ==========================================

echo "Creating K3d cluster..."
k3d cluster create iot-cluster -p "80:80@loadbalancer" -p "443:443@loadbalancer"

kubectl create namespace argocd
kubectl create namespace dev

echo "Adding GitLab Helm Repository..."
helm repo add gitlab https://charts.gitlab.io/
helm repo update

if [ ! -f "../confs/gitlab-values.yaml" ]; then
  echo "❌ Error: gitlab-values.yaml not found!"
  echo "Please make sure your values file is in this folder."
  exit 1
fi

echo "Installing GitLab via Helm (this will take a few minutes)..."
helm upgrade --install my-gitlab gitlab/gitlab -f ../confs/gitlab-values.yaml --namespace gitlab --create-namespace

echo "🔑 Waiting for GitLab to generate the root password..."
sleep 15
echo "========================================"
echo "🎉 Droplet setup complete!"
echo "Your GitLab root password is:"
kubectl get secret my-gitlab-gitlab-initial-root-password -n gitlab -o jsonpath="{.data.password}" | base64 --decode ; echo ""
echo "========================================"

echo "Installing Argo CD..."
kubectl create -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "Patching Argo CD DNS to recognize gitlab.k3d.local..."

sleep 10
TRAEFIK_IP=$(kubectl get svc traefik -n kube-system -o jsonpath='{.spec.clusterIP}')

# Inject the hostAliases into the three main Argo CD deployments
kubectl patch deploy argocd-repo-server -n argocd --patch "{\"spec\": {\"template\": {\"spec\": {\"hostAliases\": [{\"ip\": \"$TRAEFIK_IP\", \"hostnames\": [\"gitlab.k3d.local\"]}]}}}}"
kubectl patch deploy argocd-server -n argocd --patch "{\"spec\": {\"template\": {\"spec\": {\"hostAliases\": [{\"ip\": \"$TRAEFIK_IP\", \"hostnames\": [\"gitlab.k3d.local\"]}]}}}}"
kubectl patch statefulset argocd-application-controller -n argocd --patch "{\"spec\": {\"template\": {\"spec\": {\"hostAliases\": [{\"ip\": \"$TRAEFIK_IP\", \"hostnames\": [\"gitlab.k3d.local\"]}]}}}}"

echo "Adding GitLab to Droplet hosts file..."
echo "127.0.0.1 gitlab.k3d.local" | sudo tee -a /etc/hosts

echo "\033[32mDroplet setup complete!\033[0m"