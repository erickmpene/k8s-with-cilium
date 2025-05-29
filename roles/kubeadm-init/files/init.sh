#!/bin/bash

set -euo pipefail

# Check if cluster already initialized
if [ -f /etc/kubernetes/admin.conf ]; then
  echo "Cluster already initialized. Skipping kubeadm init."
  exit 0
fi

echo "Initializing the Kubernete Cluster..."
kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-cert-extra-sans=istio.notylus.com,82.65.209.216

echo "Initialization completed !"
echo "To add more nodes, copy the command displayed by kubeadm init."

