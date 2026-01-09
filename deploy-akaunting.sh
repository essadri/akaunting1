#!/bin/bash

set -e

# Apply Kubernetes manifests
kubectl apply -f ~/deploy/k8s/akaunting-all.yaml

# Wait for deployments to exist
sleep 60

# Start Minikube tunnel if not already running
if ! pgrep -f "minikube tunnel" >/dev/null; then
  nohup sudo -E minikube tunnel --profile=minikube >/dev/null 2>&1 &
fi

# Start port-forward only if not already running
if ! pgrep -f "kubectl port-forward -n akaunting svc/akaunting 8080:80" >/dev/null; then
  nohup kubectl port-forward -n akaunting svc/akaunting 8080:80 --address 0.0.0.0 \
    >/dev/null 2>&1 &
fi

exit 0
