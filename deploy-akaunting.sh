#!/bin/bash

kubectl apply -f ~/deploy/k8s/akaunting-all.yaml

sudo -E minikube tunnel --profile=minikube &

kubectl port-forward -n akaunting svc/akaunting 8080:80 --address 0.0.0.0 &
