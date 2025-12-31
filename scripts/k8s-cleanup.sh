#!/bin/bash

# Script to clean up Kubernetes resources

set -e

echo "Cleaning up Kubernetes resources..."

# Delete Ingress
echo "Deleting Ingress..."
kubectl delete -f kubernetes/ingress.yaml --ignore-not-found=true

# Delete Backend
echo "Deleting Backend resources..."
kubectl delete -f kubernetes/backend/backend-deployment.yaml --ignore-not-found=true
kubectl delete -f kubernetes/backend/backend-service.yaml --ignore-not-found=true
kubectl delete -f kubernetes/backend/backend-secret.yaml --ignore-not-found=true
kubectl delete -f kubernetes/backend/backend-configmap.yaml --ignore-not-found=true

# Delete MongoDB
echo "Deleting MongoDB resources..."
kubectl delete -f kubernetes/mongodb/mongodb-deployment.yaml --ignore-not-found=true
kubectl delete -f kubernetes/mongodb/mongodb-service.yaml --ignore-not-found=true
kubectl delete -f kubernetes/mongodb/mongodb-pvc.yaml --ignore-not-found=true
kubectl delete -f kubernetes/mongodb/mongodb-secret.yaml --ignore-not-found=true
kubectl delete -f kubernetes/mongodb/mongodb-configmap.yaml --ignore-not-found=true

# Delete namespace
echo "Deleting namespace..."
kubectl delete -f kubernetes/namespace.yaml --ignore-not-found=true

echo ""
echo "Cleanup complete!"
echo ""
echo "Remaining resources in muchtodo namespace:"
kubectl get all -n muchtodo