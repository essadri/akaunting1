#!/bin/bash

set -e

# Apply Kubernetes manifests
kubectl apply -f ~/deploy/k8s/akaunting-all.yaml

# Wait for deployments to be ready
sleep 70

# Start Minikube tunnel if not already running
if ! pgrep -f "minikube tunnel" >/dev/null; then
  sudo -E minikube tunnel --profile=minikube &
fi

# Wait a bit for services
sleep 5

# Start port-forward only if not already running
if ! pgrep -f "kubectl port-forward -n akaunting svc/akaunting 8080:80" >/dev/null; then
  kubectl port-forward -n akaunting svc/akaunting 8080:80 --address 0.0.0.0 &
fi
