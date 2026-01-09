#!/bin/bash

set -e

# Apply Kubernetes manifests
kubectl apply -f ~/deploy/k8s/akaunting-all.yaml

# Wait for deployments to be ready
sleep 100

# Start Minikube tunnel only if not running
if ! pgrep -f "minikube tunnel" >/dev/null; then
  sudo -E minikube tunnel --profile=minikube > /dev/null 2>&1 &
fi

# Wait a bit for services
sleep 5

# Start port-forward only if not running
if ! pgrep -f "kubectl port-forward -n akaunting svc/akaunting 8080:80" >/dev/null; then
  kubectl port-forward -n akaunting svc/akaunting 8080:80 --address 0.0.0.0 > /dev/null 2>&1 &
fi

exit 0










# #!/bin/bash

# set -e

# # Apply Kubernetes manifests
# kubectl apply -f ~/deploy/k8s/akaunting-all.yaml

# # Wait for deployments to be ready
# sleep 100

# # Start Minikube tunnel if not already running

# sudo -E minikube tunnel --profile=minikube > /dev/null 2>&1 &


# # Wait a bit for services
# sleep 5

# # Start port-forward only if not already running

# kubectl port-forward -n akaunting svc/akaunting 8080:80 --address 0.0.0.0 > /dev/null 2>&1 &


# exit 0