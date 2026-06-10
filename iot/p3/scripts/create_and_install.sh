#!/bin/bash

k3d cluster create iot-cluster -p "80:80@loadbalancer" -p "443:443@loadbalancer"
echo "created cluster, waiting..."
sleep 5

kubectl create namespace argocd
kubectl create namespace dev
echo "created namespaces, waiting..."
sleep 3

echo "installing argocd"
kubectl apply -n argocd -f ../confs/install.yaml
sleep 3

kubectl wait -n argocd --for=condition=Ready pods --all
echo "pods ready, waiting..."
sleep 3

kubectl apply -f ../confs/ingress.yaml -n argocd
echo "installed ingress, waiting..."
sleep 3

echo "installing project to argocd"
kubectl apply -f ../confs/project.yaml -n argocd
echo "installed project to argocd"
sleep 3

echo "installing application to argocd"
kubectl apply -f ../confs/app.yaml -n argocd
echo "installed app to argocd"
sleep 3

echo "your argocd's password is :"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo