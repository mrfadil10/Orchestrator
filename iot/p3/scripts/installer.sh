curl -fsSL https://get.docker.com -o get-docker.sh
sh ./get-docker.sh

KUBERNETES_RELEASE=$(curl -sL https://dl.k8s.io/release/stable.txt)
curl -LO "https://dl.k8s.io/release/${KUBERNETES_RELEASE}/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/${KUBERNETES_RELEASE}/bin/linux/amd64/kubectl.sha256"

# If the check fails do not continue and exit
echo "$(cat kubectl.sha256) kubectl" | sha256sum --check || exit 1
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
