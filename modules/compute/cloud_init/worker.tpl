#cloud-config
package_update: true
package_upgrade: true

packages:
  - apt-transport-https
  - ca-certificates
  - curl
  - gnupg
  - lsb-release

runcmd:
  - |
    set -eux

    apt-get update
    apt-get install -y containerd
    mkdir -p /etc/containerd
    containerd config default > /etc/containerd/config.toml
    systemctl restart containerd
    systemctl enable containerd

    sed -i '/ swap / s/^/#/' /etc/fstab
    swapoff -a

    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key \
      | gpg --dearmor -o /etc/apt/trusted.gpg.d/kubernetes.gpg
    echo "deb https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" \
      | tee /etc/apt/sources.list.d/kubernetes.list

    apt-get update
    apt-get install -y kubelet kubeadm kubectl
    apt-mark hold kubelet kubeadm kubectl

    
