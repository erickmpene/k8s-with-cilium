# Kubernetes Cluster Provisioning with Ansible and Bash Scripts

## 📌 Requirements

To ensure a smooth and stable deployment of the Kubernetes cluster, please ensure the following prerequisites are met:

1. **Minimum hardware requirements per node**:
   - **Memory**: At least **4 GB of RAM**
   - **CPU**: At least **2 vCPUs**

2. **Inventory file**:
   - All nodes (masters and workers) intended to join the Kubernetes cluster must be defined in the Ansible inventory:
     ```
     inventory/hosts.ini
     ```

3. **Container Runtime**:
   - The cluster uses **containerd** as the container runtime.
   - It is installed and configured with `SystemdCgroup = true`.

4. **CNI Plugin**:
   - The cluster uses **Cilium** as the CNI for networking, using the official Cilium CLI (`cilium install`) without Helm.

5. **Deployment Strategy**:
   - Although Ansible is used to orchestrate tasks across the nodes (file transfer, condition checks, etc.), the critical components of the Kubernetes setup (such as installing kubeadm/kubelet/kubectl or initializing the cluster) are executed using **Bash scripts**.
   - This decision was made to **maximize stability and reproducibility**, especially for sensitive actions like `kubeadm init`, which may behave differently under Ansible context or require interactive feedback.
   - These scripts are located in the `files/` directory and are executed remotely via Ansible only when needed (e.g., when a component is missing or the cluster is not yet initialized).

---

## 🛠️ Scripts Overview

- `install.sh`: Installs `kubeadm`, `kubelet`, and `kubectl` if not already present.
- `init.sh`: Initializes the Kubernetes master node if the cluster is not already initialized.

---

## 🚀 Usage

Make sure your `hosts.ini` is correctly populated, then run the main playbook:

```bash
ansible-playbook -i inventory/hosts.ini playbook.yml
```

