#!/bin/bash
# Copyright (c) 2026 mingju.xu (xumj1125@live.com). All rights reserved.
# Licensed under the GNU General Public License v3.0.
# scripts/setup-kind.sh
set -e

CLUSTER_NAME="devops-demo"

echo "Checking if Docker is running..."
if ! docker info &> /dev/null; then
  echo "Error: Docker daemon is not running. Please start Docker and try again."
  exit 1
fi


echo "Checking if kind is installed..."
if ! command -v kind &> /dev/null; then
  echo "kind not found. Installing kind..."
  # Detect OS and architecture
  OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
  ARCH="$(uname -m)"
  if [ "$ARCH" = "x86_64" ]; then
    ARCH="amd64"
  elif [ "$ARCH" = "aarch64" ]; then
    ARCH="arm64"
  fi
  
  curl -Lo ./kind "https://kind.sigs.k8s.io/dl/v0.20.0/kind-${OS}-${ARCH}"
  chmod +x ./kind
  sudo mv ./kind /usr/local/bin/kind
  echo "kind installed successfully!"
else
  echo "kind is already installed."
fi

echo "Creating kind cluster '${CLUSTER_NAME}' with ingress ports exposed..."
# Create cluster with extraPortMappings to allow ingress traffic on host ports 80 and 443
cat <<EOF | kind create cluster --name "${CLUSTER_NAME}" --config=-
apiVersion: kind.x-k8s.io/v1alpha4
kind: Cluster
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    apiVersion: kubeadm.k8s.io/v1beta3
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
EOF

echo "Installing NGINX Ingress Controller..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

echo "Waiting for Ingress Controller to be ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=180s

echo "Kind cluster setup complete! Use: kubectl get nodes"
