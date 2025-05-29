#!/bin/bash

set -euo pipefail

if command -v kubeadm >/dev/null && command -v kubelet >/dev/null && command -v kubectl >/dev/null; then
  echo "kubeadm, kubelet and kubectl are already installed. Exiting."
  exit 0
fi

echo "Adding Kubernetes GPG key..."
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "Adding the Kubernetes repository..."
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

echo "Package Updates..."
apt update

echo "Installing kubelet, kubeadm and kubectl..."
apt install -y kubelet kubeadm kubectl

sudo apt-mark hold kubelet kubeadm kubectl

echo "Désactivation de swap..."
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

echo "Loading modules requireds..."
cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

echo "Configuring sysctl parameters..."
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system

echo "Installation de containerd..."
apt install -y containerd
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd

echo "Disable firewall if UFW is installed..."
if systemctl list-unit-files | grep -q '^ufw.service'; then
    systemctl stop ufw
    systemctl disable ufw
    echo "UFW disable."
else
    echo "UFW is not installed, no action required."
fi

echo "Restarting kubelet..."
systemctl enable --now kubelet

echo "Installation completed !"
echo "To add more nodes, copy the command displayed by kubeadm init."

