#!/bin/sh

# Add sbin to path and disable frontend
export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/root/bin
export DEBIAN_FRONTEND=noninteractive

# Turn off swap and comment swap in fstab
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Enable cgroup memory
echo "GRUB_CMDLINE_LINUX=\"cgroup_enable=memory\"" >> /etc/default/grub
update-grub2

# Set iptables and persist
apt-get install iptables-persistent -qy
iptables -F
iptables-save

# Common apt software
apt-get install apt-transport-https ca-certificates curl gnupg2 software-properties-common -qy

# Docker iptables and cgroup configuration
mkdir -p /etc/docker
cat > /etc/docker/daemon.json <<EOF
{
  "mtu": 1450,
  "ip-masq": true,
  "exec-opts": ["native.cgroupdriver=systemd"],
  "insecure-registries": [ "10.0.0.0/8" ],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  }
}
EOF
sysctl net.bridge.bridge-nf-call-iptables=1
echo 'net.bridge.bridge-nf-call-iptables=1' >> /etc/sysctl.conf

# Add repos for docker and kubernetes
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF | tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update

# Install docker,kubernetes and lock at version
apt install docker-ce=18.06.3~ce~3-0~debian kubelet=1.17.0-00 kubeadm=1.17.0-00 kubectl=1.17.0-00 -qy
apt-mark hold kubelet kubeadm kubectl docker-ce
systemctl enable kubelet && systemctl enable docker