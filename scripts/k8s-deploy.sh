#!/bin/bash

# Script to deploy to Kubernetes

set -e

echo "Deploying MuchToDo to Kubernetes..."

# Apply namespace
echo "Creating namespace..."
kubectl apply -f kubernetes/namespace.yaml

# Deploy MongoDB
echo "Deploying MongoDB..."
kubectl apply -f kubernetes/mongodb/mongodb-secret.yaml
kubectl apply -f kubernetes/mongodb/mongodb-configmap.yaml
kubectl apply -f kubernetes/mongodb/mongodb-pvc.yaml
kubectl apply -f kubernetes/mongodb/mongodb-deployment.yaml
kubectl apply -f kubernetes/mongodb/mongodb-service.yaml

# Wait for MongoDB to be ready
echo "Waiting for MongoDB to be ready..."
kubectl wait --for=condition=ready pod -l app=mongodb -n muchtodo --timeout=120s

# Deploy Backend
echo "Deploying Backend..."
kubectl apply -f kubernetes/backend/backend-secret.yaml
kubectl apply -f kubernetes/backend/backend-configmap.yaml
kubectl apply -f kubernetes/backend/backend-deployment.yaml
kubectl apply -f kubernetes/backend/backend-service.yaml

# Wait for Backend to be ready
echo "Waiting for Backend to be ready..."
kubectl wait --for=condition=ready pod -l app=backend -n muchtodo --timeout=120s

# Check if Ingress Controller is installed
if kubectl get namespace ingress-nginx &> /dev/null; then
    echo "Ingress controller already installed"
else
    echo "Installing NGINX Ingress Controller..."
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
    echo "Waiting for Ingress Controller to be ready..."
    sleep 30
    kubectl wait --namespace ingress-nginx \
      --for=condition=ready pod \
      --selector=app.kubernetes.io/component=controller \
      --timeout=120s
fi

# Deploy Ingress
echo "Deploying Ingress..."
kubectl apply -f kubernetes/ingress.yaml

# Display deployment status
echo ""
echo "Deployment complete!"
echo ""
echo "=== Pod Status ==="
kubectl get pods -n muchtodo

echo ""
echo "=== Service Status ==="
kubectl get svc -n muchtodo

echo ""
echo "=== Ingress Status ==="
kubectl get ingress -n muchtodo

echo ""
echo "Access the API:"
echo ""
echo "Option 1: Via Ingress (if KIND cluster has port mappings)"
echo "  1. Add to /etc/hosts: echo '127.0.0.1 muchtodo.local' | sudo tee -a /etc/hosts"
echo "  2. Access API: curl http://muchtodo.local"
echo "     Health check: curl http://muchtodo.local/health"
echo ""
echo "Option 2: Via Port-forward to Ingress"
echo "  kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80"
echo "  curl http://localhost:8080 -H 'Host: muchtodo.local'"
echo ""
echo "Option 3: Direct to Backend (bypass Ingress)"
echo "  kubectl port-forward -n muchtodo svc/backend-service 8080:8080"
echo "  curl http://localhost:8080"