#!/bin/bash

set -e

# Apply Kubernetes manifests
kubectl apply -f ~/deploy/k8s/akaunting-all.yaml

# Wait for deployments to be ready
sleep 100

# Start Minikube tunnel if not already running

sudo -E minikube tunnel --profile=minikube &


# Wait a bit for services
sleep 5

# Start port-forward only if not already running

kubectl port-forward -n akaunting svc/akaunting 8080:80 --address 0.0.0.0 & 


