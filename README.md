## CNI CILIUM
## Kubernetes Cluster Provisioning with Ansible and Bash Scripts

## Requirements

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
   - Hubble Observability Layer Enabled. As part of the Cilium installation, this setup also enables **Hubble**, Cilium's built-in observability and visibility layer.
   ##### Cilium Features Enabled:
   - **Hubble Relay**: A gRPC service that aggregates observability data from all Cilium agents across the cluster.
   - **Hubble UI**: A web-based interface to visualize real-time network traffic, L3/L4/L7 flows, policy decisions, and service dependencies.
   ##### Activation:
   The playbook automatically runs:

   ```bash
   cilium hubble enable --ui
   ```


5. **Deployment Strategy**:
   - Although Ansible is used to orchestrate tasks across the nodes (file transfer, condition checks, etc.), the critical components of the Kubernetes setup (such as installing kubeadm/kubelet/kubectl or initializing the cluster) are executed using **Bash scripts**.
   - This decision was made to **maximize stability and reproducibility**, especially for sensitive actions like `kubeadm init`, which may behave differently under Ansible context or require interactive feedback.
   - These scripts are located in the `files/` directory and are executed remotely via Ansible only when needed (e.g., when a component is missing or the cluster is not yet initialized).

---

## Scripts Overview

- `install.sh`: Installs `kubeadm`, `kubelet`, and `kubectl` if not already present.
- `init.sh`: Initializes the Kubernetes master node if the cluster is not already initialized.

---

## Usage

Make sure your `hosts.ini` is correctly populated, then run the main playbook:

```bash
ansible-playbook -i inventory/hosts.ini playbook.yml
```

## Inspecting a wide variety of Cilium network traffic 
```bash
while true; do cilium connectivity test; done
```
**To see the traffic in Hubble, open http://localhost:12000/cilium-test in your browser.**

# Cilium vs Calico – Comparison for Production Kubernetes Environments

| Feature                            |  **Cilium**                                                 |  **Calico**                                               |
|------------------------------------|----------------------------------------------------------------|--------------------------------------------------------------|
| **Dataplane**                      | Native eBPF                                                    | iptables (default) / eBPF (optional)                        |
| **Network Performance**            | Excellent (kernel bypass via eBPF)                             | Good (iptables-based)                                       |
| **L7 Support (HTTP, gRPC, Kafka)** | ✅ Yes (natively via Hubble)                                   | ❌ No                                                       |
| **Pod-to-Pod mTLS**                | ✅ Yes (built-in, without service mesh)                        | ❌ No (requires Istio/Linkerd)                             |
| **Built-in Observability**         | ✅ Yes (Hubble CLI + UI)                                       | ❌ No (external integration required, e.g., Prometheus)     |
| **DNS-aware Policies**            | ✅ Yes                                                         | 🔶 Limited                                                  |
| **UI Availability**                | ✅ Hubble UI                                                   | ❌ None                                                     |
| **WireGuard Encryption**           | ✅ Built-in during installation                                | ✅ Available (manual setup more complex)                   |
| **Multi-cluster Support**          | ✅ Yes (ClusterMesh with identity-aware routing)               | 🔶 Experimental                                             |
| **IPv6 Support**                   | ✅ Yes                                                         | ✅ Yes                                                      |
| **Installation Complexity**        | 🔶 Medium (via CLI or Helm, with CRDs & Hubble)                | ✅ Low (DaemonSet only)                                     |
| **Community & Support**            | ✅ Very active (Isovalent, CNCF, supported by AWS, GKE, etc.)  | ✅ Very active (Tigera, CNCF)                               |
| **Production Maturity**           | 🔶 Newer but widely adopted (Meta, Adobe, Google, etc.)         | ✅ Highly mature and battle-tested                         |
| **Best Use Cases**                 | Cloud-native apps, DevSecOps, visibility, advanced security    | Simplicity, compatibility, minimal maintenance              |

---

## Recommendation

- **Choose Cilium** if:
  - You want deep observability (L7 visibility, auditing)
  - You need encryption (WireGuard), service mesh-lite, or gRPC/Kafka-aware policies
  - You're running a modern cloud-native stack (AWS, GKE, EKS Anywhere)

- **Choose Calico** if:
  - You prefer simplicity and fast installation
  - You’re operating in constrained or legacy environments
  - You rely on traditional iptables-based networking

> **Cilium is becoming the default CNI for modern Kubernetes distributions**, especially in security-focused or large-scale cloud deployments.
