k3d cluster create -p 8080:80@loadbalancer -p 8888:30888@loadbalancer
echo "created cluster, waiting..."
sleep 5

kubectl create namespace argocd
kubectl create namespace dev
echo "created namespaces, waiting..."
sleep 3

echo "installing argocd"
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
sleep 3

kubectl wait -n argocd --for=condition=Ready pods --all
echo "pods ready, waiting..."
sleep 3

kubectl apply -f ../confs/ingress.yaml -n argocd
echo "installed ingress, waiting..."
sleep 3

echo "changing default password to password"
kubectl -n argocd patch secret argocd-secret \
    -p '{"stringData": {
      "admin.password": "$2a$12$Noh7ZsmNoj0z2b4pYFrwGe/13QsAzti5.kFPXOV/s9isz6KK8U3pK",
	  "admin.passwordMtime": "'$(date +%FT%T%Z)'"
	}}'
echo "changed default password to password, waiting..."
sleep 3

echo "installing project to argocd"
kubectl apply -f ../confs/project.yaml -n argocd
echo "installed project to argocd"
sleep 3

echo "installing application to argocd"
kubectl apply -f ../confs/app.yaml -n argocd
echo "installed app to argocd"
sleep 3
