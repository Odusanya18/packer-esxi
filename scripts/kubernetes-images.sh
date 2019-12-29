#!/bin/sh

kubernetes_release_tag="v1.17.0"
flannel_release_tag="v0.11.0-arm64"

## Pre-fetch Kubernetes release image, so that `kubeadm init` is a bit quicker
images=(
  "gcr.io/google_containers/kube-proxy-amd64:${kubernetes_release_tag}"
  "gcr.io/google_containers/kube-apiserver-amd64:${kubernetes_release_tag}"
  "gcr.io/google_containers/kube-scheduler-amd64:${kubernetes_release_tag}"
  "gcr.io/google_containers/kube-controller-manager-amd64:${kubernetes_release_tag}"
  "gcr.io/google-containers/etcd-amd64:3.4.3"
  "gcr.io/google-containers/pause-amd64:3.1"
  "gcr.io/google-containers/coredns:1.6.6"
  "quay.io/coreos/flannel:${flannel_release_tag}"
)

for i in "${images[@]}" ; do docker pull "${i}" ; done