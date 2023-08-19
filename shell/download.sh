#!/bin/bash

# 查看版本地址：
# 
# https://github.com/containernetworking/plugins/releases/
# https://github.com/containerd/containerd/releases/
# https://github.com/kubernetes-sigs/cri-tools/releases/
# https://github.com/Mirantis/cri-dockerd/releases/
# https://github.com/etcd-io/etcd/releases/
# https://github.com/cloudflare/cfssl/releases/
# https://github.com/kubernetes/kubernetes/tree/master/CHANGELOG
# https://download.docker.com/linux/static/stable/x86_64/
# https://github.com/opencontainers/runc/releases/
# https://mirrors.tuna.tsinghua.edu.cn/elrepo/kernel/el7/x86_64/RPMS/
# https://github.com/helm/helm/tags
# http://nginx.org/download/

# Version numbers
cni_plugins_version='v1.3.0'
cri_containerd_cni_version='1.7.3'
crictl_version='v1.28.0'
cri_dockerd_version='0.3.4'
etcd_version='v3.5.9'
cfssl_version='1.6.4'
kubernetes_server_version='1.28.0'
docker_version='24.0.5'
runc_version='1.1.9'
kernel_version='5.4.254'
helm_version='3.12.3'
nginx_version='1.25.2'

# URLs 
base_url='https://ghproxy.com/https://github.com'
kernel_url="http://mirrors.tuna.tsinghua.edu.cn/elrepo/kernel/el7/x86_64/RPMS/kernel-lt-${kernel_version}-1.el7.elrepo.x86_64.rpm"
runc_url="${base_url}/opencontainers/runc/releases/download/v${runc_version}/runc.amd64"
docker_url="https://download.docker.com/linux/static/stable/x86_64/docker-${docker_version}.tgz"
cni_plugins_url="${base_url}/containernetworking/plugins/releases/download/${cni_plugins_version}/cni-plugins-linux-amd64-${cni_plugins_version}.tgz"
cri_containerd_cni_url="${base_url}/containerd/containerd/releases/download/v${cri_containerd_cni_version}/cri-containerd-cni-${cri_containerd_cni_version}-linux-amd64.tar.gz"
crictl_url="${base_url}/kubernetes-sigs/cri-tools/releases/download/${crictl_version}/crictl-${crictl_version}-linux-amd64.tar.gz"
cri_dockerd_url="${base_url}/Mirantis/cri-dockerd/releases/download/v${cri_dockerd_version}/cri-dockerd-${cri_dockerd_version}.amd64.tgz"
etcd_url="${base_url}/etcd-io/etcd/releases/download/${etcd_version}/etcd-${etcd_version}-linux-amd64.tar.gz"
cfssl_url="${base_url}/cloudflare/cfssl/releases/download/v${cfssl_version}/cfssl_${cfssl_version}_linux_amd64"
cfssljson_url="${base_url}/cloudflare/cfssl/releases/download/v${cfssl_version}/cfssljson_${cfssl_version}_linux_amd64"
helm_url="https://mirrors.huaweicloud.com/helm/v${helm_version}/helm-v${helm_version}-linux-amd64.tar.gz"
kubernetes_server_url="https://storage.googleapis.com/kubernetes-release/release/v${kubernetes_server_version}/kubernetes-server-linux-amd64.tar.gz"
nginx_url="http://nginx.org/download/nginx-${nginx_version}.tar.gz"

# Download packages
packages=(
  $kernel_url
  $runc_url
  $docker_url
  $cni_plugins_url
  $cri_containerd_cni_url
  $crictl_url
  $cri_dockerd_url
  $etcd_url
  $cfssl_url
  $cfssljson_url
  $helm_url
  $kubernetes_server_url
  $nginx_url
)

for package_url in "${packages[@]}"; do
  filename=$(basename "$package_url")
  if curl --parallel --parallel-immediate -k -L -C - -o "$filename" "$package_url"; then
    echo "Downloaded $filename"
  else
    echo "Failed to download $filename"
    exit 1
  fi
done