#!/bin/sh

export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/root/bin
export DEBIAN_FRONTEND=noninteractive
apt-get install iptables-persistent -y
iptables -F
iptables-save
apt-get install apt-transport-https ca-certificates curl gnupg2 software-properties-common -y
mkdir -p /etc/docker
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"]
  "insecure-registries" : [ "10.0.0.0/8:5000" ]
}
EOF
sysctl net.bridge.bridge-nf-call-iptables=1
echo 'net.bridge.bridge-nf-call-iptables=1' >> /etc/sysctl.conf
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
apt install docker-ce=18.06.3~ce~3-0~debian kubelet=1.17.0-00 kubeadm=1.17.0-00 kubectl=1.17.0-00 -y
apt-mark hold kubelet kubeadm kubectl docker-ce
systemctl enable docker && systemctl start docker
systemctl enable kubelet && systemctl start kubelet