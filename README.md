# 二进制安装Kubernetes（k8s） v1.24.0 IPv4/IPv6双栈

# 介绍

kubernetes二进制安装

1.23.3 和 1.23.4 和 1.23.5 和 1.23.6 和 1.24.0 文档以及安装包已生成。

后续尽可能第一时间更新新版本文档

https://github.com/cby-chen/Kubernetes/releases

手动项目地址：https://github.com/cby-chen/Kubernetes

脚本项目地址：https://github.com/cby-chen/Binary_installation_of_Kubernetes

kubernetes 1.24 变化较大，详细见：https://kubernetes.io/zh/blog/2022/04/07/upcoming-changes-in-kubernetes-1-24/


# 1.环境

| 主机名称 | IP地址    | 说明       | 软件                                                         |
| -------- | --------- | ---------- | ------------------------------------------------------------ |
| Master01 | 10.0.0.81 | master节点 | kube-apiserver、kube-controller-manager、kube-scheduler、etcd、<br />kubelet、kube-proxy、nfs-client |
| Master02 | 10.0.0.82 | master节点 | kube-apiserver、kube-controller-manager、kube-scheduler、etcd、<br />kubelet、kube-proxy、nfs-client |
| Master03 | 10.0.0.83 | master节点 | kube-apiserver、kube-controller-manager、kube-scheduler、etcd、<br />kubelet、kube-proxy、nfs-client |
| Node01   | 10.0.0.84 | node节点   | kubelet、kube-proxy、nfs-client                              |
| Node02   | 10.0.0.85 | node节点   | kubelet、kube-proxy、nfs-client                              |
| Node03   | 10.0.0.86 | node节点   | kubelet、kube-proxy、nfs-client                              |
| Node04   | 10.0.0.87 | node节点   | kubelet、kube-proxy、nfs-client                              |
| Node05   | 10.0.0.88 | node节点   | kubelet、kube-proxy、nfs-client                              |
| Lb01     | 10.0.0.80 | Lb01节点   | haproxy、keepalived                                          |
| Lb02     | 10.0.0.90 | Lb02节点   | haproxy、keepalived                                          |
|          | 10.0.0.89 | VIP        |                                                              |

| 软件                                                         | 版本                |
| :----------------------------------------------------------- | :------------------ |
| 内核                                                         | 5.17.5-1.el8.elrepo |
| CentOS 8                                                     | v8 或者 v7          |
| kube-apiserver、kube-controller-manager、kube-scheduler、kubelet、kube-proxy | v1.24.0             |
| etcd                                                         | v3.5.4              |
| containerd                                                   | v1.5.11             |
| cfssl                                                        | v1.6.1              |
| cni                                                          | v1.1.1              |
| crictl                                                       | v1.23.0             |
| haproxy                                                      | v1.8.27             |
| keepalived                                                   | v2.1.5              |



网段

物理主机：10.0.0.0/24

service：10.96.0.0/12

pod：172.16.0.0/12

建议k8s集群与etcd集群分开安装



安装包已经整理好：https://github.com/cby-chen/Kubernetes/releases/download/v1.24.0/kubernetes-v1.24.0.tar



## 1.1.k8s基础系统环境配置

### 1.2.配置IP

```shell
ssh root@10.0.0.143 "nmcli con mod ens160 ipv4.addresses 10.0.0.81/24; nmcli con mod ens160 ipv4.gateway 10.0.0.1; nmcli con mod ens160 ipv4.method manual; nmcli con mod ens160 ipv4.dns "8.8.8.8"; nmcli con up ens160"
ssh root@10.0.0.130 "nmcli con mod ens160 ipv4.addresses 10.0.0.82/24; nmcli con mod ens160 ipv4.gateway 10.0.0.1; nmcli con mod ens160 ipv4.method manual; nmcli con mod ens160 ipv4.dns "8.8.8.8"; nmcli con up ens160"
ssh root@10.0.0.191 "nmcli con mod ens160 ipv4.addresses 10.0.0.83/24; nmcli con mod ens160 ipv4.gateway 10.0.0.1; nmcli con mod ens160 ipv4.method manual; nmcli con mod ens160 ipv4.dns "8.8.8.8"; nmcli con up ens160"
ssh root@10.0.0.154 "nmcli con mod ens160 ipv4.addresses 10.0.0.84/24; nmcli con mod ens160 ipv4.gateway 10.0.0.1; nmcli con mod ens160 ipv4.method manual; nmcli con mod ens160 ipv4.dns "8.8.8.8"; nmcli con up ens160"
ssh root@10.0.0.172 "nmcli con mod ens160 ipv4.addresses 10.0.0.85/24; nmcli con mod ens160 ipv4.gateway 10.0.0.1; nmcli con mod ens160 ipv4.method manual; nmcli con mod ens160 ipv4.dns "8.8.8.8"; nmcli con up ens160"
ssh root@10.0.0.134 "nmcli con mod ens160 ipv4.addresses 10.0.0.86/24; nmcli con mod ens160 ipv4.gateway 10.0.0.1; nmcli con mod ens160 ipv4.method manual; nmcli con mod ens160 ipv4.dns "8.8.8.8"; nmcli con up ens160"
ssh root@10.0.0.167 "nmcli con mod ens160 ipv4.addresses 10.0.0.87/24; nmcli con mod ens160 ipv4.gateway 10.0.0.1; nmcli con mod ens160 ipv4.method manual; nmcli con mod ens160 ipv4.dns "8.8.8.8"; nmcli con up ens160"
ssh root@10.0.0.183 "nmcli con mod ens160 ipv4.addresses 10.0.0.88/24; nmcli con mod ens160 ipv4.gateway 10.0.0.1; nmcli con mod ens160 ipv4.method manual; nmcli con mod ens160 ipv4.dns "8.8.8.8"; nmcli con up ens160"
ssh root@10.0.0.249 "nmcli con mod ens160 ipv4.addresses 10.0.0.80/24; nmcli con mod ens160 ipv4.gateway 10.0.0.1; nmcli con mod ens160 ipv4.method manual; nmcli con mod ens160 ipv4.dns "8.8.8.8"; nmcli con up ens160"
ssh root@10.0.0.128 "nmcli con mod ens160 ipv4.addresses 10.0.0.90/24; nmcli con mod ens160 ipv4.gateway 10.0.0.1; nmcli con mod ens160 ipv4.method manual; nmcli con mod ens160 ipv4.dns "8.8.8.8"; nmcli con up ens160"


ssh root@10.0.0.81 "nmcli con mod ens160 ipv6.addresses 2408:8207:78ce:7561::10; nmcli con mod ens160 ipv6.gateway 2408:8207:78ce:7561::1; nmcli con mod ens160 ipv6.method manual; nmcli con mod ens160 ipv6.dns "2001:4860:4860::8888"; nmcli con up ens160"
ssh root@10.0.0.82 "nmcli con mod ens160 ipv6.addresses 2408:8207:78ce:7561::20; nmcli con mod ens160 ipv6.gateway 2408:8207:78ce:7561::1; nmcli con mod ens160 ipv6.method manual; nmcli con mod ens160 ipv6.dns "2001:4860:4860::8888"; nmcli con up ens160"
ssh root@10.0.0.83 "nmcli con mod ens160 ipv6.addresses 2408:8207:78ce:7561::30; nmcli con mod ens160 ipv6.gateway 2408:8207:78ce:7561::1; nmcli con mod ens160 ipv6.method manual; nmcli con mod ens160 ipv6.dns "2001:4860:4860::8888"; nmcli con up ens160"
ssh root@10.0.0.84 "nmcli con mod ens160 ipv6.addresses 2408:8207:78ce:7561::40; nmcli con mod ens160 ipv6.gateway 2408:8207:78ce:7561::1; nmcli con mod ens160 ipv6.method manual; nmcli con mod ens160 ipv6.dns "2001:4860:4860::8888"; nmcli con up ens160"
ssh root@10.0.0.85 "nmcli con mod ens160 ipv6.addresses 2408:8207:78ce:7561::50; nmcli con mod ens160 ipv6.gateway 2408:8207:78ce:7561::1; nmcli con mod ens160 ipv6.method manual; nmcli con mod ens160 ipv6.dns "2001:4860:4860::8888"; nmcli con up ens160"
ssh root@10.0.0.86 "nmcli con mod ens160 ipv6.addresses 2408:8207:78ce:7561::60; nmcli con mod ens160 ipv6.gateway 2408:8207:78ce:7561::1; nmcli con mod ens160 ipv6.method manual; nmcli con mod ens160 ipv6.dns "2001:4860:4860::8888"; nmcli con up ens160"
ssh root@10.0.0.87 "nmcli con mod ens160 ipv6.addresses 2408:8207:78ce:7561::70; nmcli con mod ens160 ipv6.gateway 2408:8207:78ce:7561::1; nmcli con mod ens160 ipv6.method manual; nmcli con mod ens160 ipv6.dns "2001:4860:4860::8888"; nmcli con up ens160"
ssh root@10.0.0.88 "nmcli con mod ens160 ipv6.addresses 2408:8207:78ce:7561::80; nmcli con mod ens160 ipv6.gateway 2408:8207:78ce:7561::1; nmcli con mod ens160 ipv6.method manual; nmcli con mod ens160 ipv6.dns "2001:4860:4860::8888"; nmcli con up ens160"
ssh root@10.0.0.80 "nmcli con mod ens160 ipv6.addresses 2408:8207:78ce:7561::90; nmcli con mod ens160 ipv6.gateway 2408:8207:78ce:7561::1; nmcli con mod ens160 ipv6.method manual; nmcli con mod ens160 ipv6.dns "2001:4860:4860::8888"; nmcli con up ens160"
ssh root@10.0.0.90 "nmcli con mod ens160 ipv6.addresses 2408:8207:78ce:7561::100; nmcli con mod ens160 ipv6.gateway 2408:8207:78ce:7561::1; nmcli con mod ens160 ipv6.method manual; nmcli con mod ens160 ipv6.dns "2001:4860:4860::8888"; nmcli con up ens160"

```

### 1.3.设置主机名

```shell
hostnamectl set-hostname k8s-master01
hostnamectl set-hostname k8s-master02
hostnamectl set-hostname k8s-master03
hostnamectl set-hostname k8s-node01
hostnamectl set-hostname k8s-node02
hostnamectl set-hostname k8s-node03
hostnamectl set-hostname k8s-node04
hostnamectl set-hostname k8s-node05
hostnamectl set-hostname lb01
hostnamectl set-hostname lb02
```

### 1.4.配置yum源

```shell
# 对于 CentOS 7
sudo sed -e 's|^mirrorlist=|#mirrorlist=|g' \
         -e 's|^#baseurl=http://mirror.centos.org|baseurl=https://mirrors.tuna.tsinghua.edu.cn|g' \
         -i.bak \
         /etc/yum.repos.d/CentOS-*.repo

# 对于 CentOS 8
sudo sed -e 's|^mirrorlist=|#mirrorlist=|g' \
         -e 's|^#baseurl=http://mirror.centos.org/$contentdir|baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos|g' \
         -i.bak \
         /etc/yum.repos.d/CentOS-*.repo

# 对于私有仓库
sed -e 's|^mirrorlist=|#mirrorlist=|g' -e 's|^#baseurl=http://mirror.centos.org/\$contentdir|baseurl=http://10.0.0.123/centos|g' -i.bak  /etc/yum.repos.d/CentOS-*.repo
```

### 1.5.安装一些必备工具

```shell
yum -y install wget jq psmisc vim net-tools nfs-utils telnet yum-utils device-mapper-persistent-data lvm2 git network-scripts tar curl -y
```

### 1.6.选择性下载需要工具

```shell
1.下载kubernetes1.24.+的二进制包
github二进制包下载地址：https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.24.md

wget https://dl.k8s.io/v1.24.0/kubernetes-server-linux-amd64.tar.gz

2.下载etcdctl二进制包
github二进制包下载地址：https://github.com/etcd-io/etcd/releases

wget https://github.com/etcd-io/etcd/releases/download/v3.5.4/etcd-v3.5.4-linux-amd64.tar.gz

3.docker-ce二进制包下载地址
二进制包下载地址：https://download.docker.com/linux/static/stable/x86_64/

这里需要下载20.10.+版本

wget https://download.docker.com/linux/static/stable/x86_64/docker-20.10.14.tgz

4.containerd二进制包下载
github下载地址：https://github.com/containerd/containerd/releases

containerd下载时下载带cni插件的二进制包。

wget https://github.com/containerd/containerd/releases/download/v1.6.4/cri-containerd-cni-1.6.4-linux-amd64.tar.gz

5.下载cfssl二进制包
github二进制包下载地址：https://github.com/cloudflare/cfssl/releases

wget https://github.com/cloudflare/cfssl/releases/download/v1.6.1/cfssl_1.6.1_linux_amd64
wget https://github.com/cloudflare/cfssl/releases/download/v1.6.1/cfssljson_1.6.1_linux_amd64
wget https://github.com/cloudflare/cfssl/releases/download/v1.6.1/cfssl-certinfo_1.6.1_linux_amd64

6.cni插件下载
github下载地址：https://github.com/containernetworking/plugins/releases

wget https://github.com/containernetworking/plugins/releases/download/v1.1.1/cni-plugins-linux-amd64-v1.1.1.tgz

7.crictl客户端二进制下载
github下载：https://github.com/kubernetes-sigs/cri-tools/releases

wget https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.23.0/crictl-v1.23.0-linux-amd64.tar.gz
```

### 1.7.关闭防火墙

```shell
systemctl disable --now firewalld
```

### 1.8.关闭SELinux

```shell
setenforce 0
sed -i 's#SELINUX=enforcing#SELINUX=disabled#g' /etc/selinux/config
```

### 1.9.关闭交换分区

```shell
sed -ri 's/.*swap.*/#&/' /etc/fstab
swapoff -a && sysctl -w vm.swappiness=0

cat /etc/fstab
# /dev/mapper/centos-swap swap                    swap    defaults        0 0
```

### 1.10.关闭NetworkManager 并启用 network (lb除外)

```shell
systemctl disable --now NetworkManager
systemctl start network && systemctl enable network
```

### 1.11.进行时间同步 (lb除外)

```shell
# 服务端

yum install chrony -y
cat > /etc/chrony.conf << EOF 
pool ntp.aliyun.com iburst
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
allow 10.0.0.0/24
local stratum 10
keyfile /etc/chrony.keys
leapsectz right/UTC
logdir /var/log/chrony
EOF

systemctl restart chronyd
systemctl enable chronyd

# 客户端

yum install chrony -y
vim /etc/chrony.conf
cat /etc/chrony.conf | grep -v  "^#" | grep -v "^$"
pool 10.0.0.81 iburst
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
keyfile /etc/chrony.keys
leapsectz right/UTC
logdir /var/log/chrony

systemctl restart chronyd ; systemctl enable chronyd

# 客户端安装一条命令
yum install chrony -y ; sed -i "s#2.centos.pool.ntp.org#10.0.0.81#g" /etc/chrony.conf ; systemctl restart chronyd ; systemctl enable chronyd


#使用客户端进行验证
chronyc sources -v
```

### 1.12.配置ulimit

```shell
ulimit -SHn 65535
cat >> /etc/security/limits.conf <<EOF
* soft nofile 655360
* hard nofile 131072
* soft nproc 655350
* hard nproc 655350
* seft memlock unlimited
* hard memlock unlimitedd
EOF
```

### 1.13.配置免密登录

```shell
yum install -y sshpass
ssh-keygen -f /root/.ssh/id_rsa -P ''
export IP="10.0.0.81 10.0.0.82 10.0.0.83 10.0.0.84 10.0.0.85 10.0.0.86 10.0.0.87 10.0.0.88 10.0.0.80 10.0.0.90"
export SSHPASS=123123
for HOST in $IP;do
     sshpass -e ssh-copy-id -o StrictHostKeyChecking=no $HOST
done
```

### 1.14.添加启用源 (lb除外)

```shell
# 为 RHEL-8或 CentOS-8配置源
yum install https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm

# 为 RHEL-7 SL-7 或 CentOS-7 安装 ELRepo 
yum install https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm

# 查看可用安装包
yum  --disablerepo="*"  --enablerepo="elrepo-kernel"  list  available
```

### 1.15.升级内核至4.18版本以上 (lb除外)

```shell
# 安装最新的内核
# 我这里选择的是稳定版kernel-ml   如需更新长期维护版本kernel-lt  
yum  --enablerepo=elrepo-kernel  install  kernel-ml

# 查看已安装那些内核
rpm -qa | grep kernel
kernel-core-4.18.0-358.el8.x86_64
kernel-tools-4.18.0-358.el8.x86_64
kernel-ml-core-5.16.7-1.el8.elrepo.x86_64
kernel-ml-5.16.7-1.el8.elrepo.x86_64
kernel-modules-4.18.0-358.el8.x86_64
kernel-4.18.0-358.el8.x86_64
kernel-tools-libs-4.18.0-358.el8.x86_64
kernel-ml-modules-5.16.7-1.el8.elrepo.x86_64

# 查看默认内核
grubby --default-kernel
/boot/vmlinuz-5.16.7-1.el8.elrepo.x86_64


# 若不是最新的使用命令设置
grubby --set-default /boot/vmlinuz-「您的内核版本」.x86_64

# 重启生效
reboot


# v8 整合命令为：
yum install https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm -y ; yum  --disablerepo="*"  --enablerepo="elrepo-kernel"  list  available -y ; yum  --enablerepo=elrepo-kernel  install  kernel-ml -y ; grubby --default-kernel ; reboot

# v7 整合命令为：
yum install https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm -y ; yum  --disablerepo="*"  --enablerepo="elrepo-kernel"  list  available -y ; yum  --enablerepo=elrepo-kernel  install  kernel-ml -y ; grubby --set-default \$(ls /boot/vmlinuz-* | grep elrepo) ; grubby --default-kernel
```

### 1.16.安装ipvsadm (lb除外)

```shell
yum install ipvsadm ipset sysstat conntrack libseccomp -y

cat >> /etc/modules-load.d/ipvs.conf <<EOF 
ip_vs
ip_vs_rr
ip_vs_wrr
ip_vs_sh
nf_conntrack
ip_tables
ip_set
xt_set
ipt_set
ipt_rpfilter
ipt_REJECT
ipip
EOF

systemctl restart systemd-modules-load.service

lsmod | grep -e ip_vs -e nf_conntrack
ip_vs_sh               16384  0
ip_vs_wrr              16384  0
ip_vs_rr               16384  0
ip_vs                 180224  6 ip_vs_rr,ip_vs_sh,ip_vs_wrr
nf_conntrack          176128  1 ip_vs
nf_defrag_ipv6         24576  2 nf_conntrack,ip_vs
nf_defrag_ipv4         16384  1 nf_conntrack
libcrc32c              16384  3 nf_conntrack,xfs,ip_vs
```

### 1.17.修改内核参数 (lb除外)

```shell
cat <<EOF > /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
fs.may_detach_mounts = 1
vm.overcommit_memory=1
vm.panic_on_oom=0
fs.inotify.max_user_watches=89100
fs.file-max=52706963
fs.nr_open=52706963
net.netfilter.nf_conntrack_max=2310720


net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.tcp_keepalive_intvl =15
net.ipv4.tcp_max_tw_buckets = 36000
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_max_orphans = 327680
net.ipv4.tcp_orphan_retries = 3
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.ip_conntrack_max = 65536
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_timestamps = 0
net.core.somaxconn = 16384

net.ipv6.conf.all.disable_ipv6 = 0
net.ipv6.conf.default.disable_ipv6 = 0
net.ipv6.conf.lo.disable_ipv6 = 0
net.ipv6.conf.all.forwarding = 1

EOF

sysctl --system
```

### 1.18.所有节点配置hosts本地解析

```shell
cat > /etc/hosts <<EOF
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

2408:8207:78ce:7561::10 k8s-master01
2408:8207:78ce:7561::20 k8s-master02
2408:8207:78ce:7561::30 k8s-master03
2408:8207:78ce:7561::40 k8s-node01
2408:8207:78ce:7561::50 k8s-node02
2408:8207:78ce:7561::60 k8s-node03
2408:8207:78ce:7561::70 k8s-node04
2408:8207:78ce:7561::80 k8s-node05
2408:8207:78ce:7561::90 lb01
2408:8207:78ce:7561::100 lb02

10.0.0.81 k8s-master01
10.0.0.82 k8s-master02
10.0.0.83 k8s-master03
10.0.0.84 k8s-node01
10.0.0.85 k8s-node02
10.0.0.86 k8s-node03
10.0.0.87 k8s-node04
10.0.0.88 k8s-node05
10.0.0.80 lb01
10.0.0.90 lb02
10.0.0.89 lb-vip
EOF
```

# 2.k8s基本组件安装

## 2.1.所有k8s节点安装Containerd作为Runtime

```shell
wget https://github.com/containernetworking/plugins/releases/download/v1.1.1/cni-plugins-linux-amd64-v1.1.1.tgz

#创建cni插件所需目录
mkdir -p /etc/cni/net.d /opt/cni/bin 
#解压cni二进制包
tar xf cni-plugins-linux-amd64-v1.1.1.tgz -C /opt/cni/bin/


wget https://github.com/containerd/containerd/releases/download/v1.6.4/cri-containerd-cni-1.6.4-linux-amd64.tar.gz

#解压
tar -C / -xzf cri-containerd-cni-1.6.4-linux-amd64.tar.gz

#创建服务启动文件
cat > /etc/systemd/system/containerd.service <<EOF
[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target local-fs.target

[Service]
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/local/bin/containerd
Type=notify
Delegate=yes
KillMode=process
Restart=always
RestartSec=5
LimitNPROC=infinity
LimitCORE=infinity
LimitNOFILE=infinity
TasksMax=infinity
OOMScoreAdjust=-999

[Install]
WantedBy=multi-user.target
EOF
```

### 2.1.1配置Containerd所需的模块

```shell
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
```

### 2.1.2加载模块

```shell
systemctl restart systemd-modules-load.service
```

### 2.1.3配置Containerd所需的内核

```shell
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# 加载内核

sysctl --system
```

### 2.1.4创建Containerd的配置文件

```shell
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml


修改Containerd的配置文件
sed -i "s#SystemdCgroup\ \=\ false#SystemdCgroup\ \=\ true#g" /etc/containerd/config.toml

cat /etc/containerd/config.toml | grep SystemdCgroup

# 找到containerd.runtimes.runc.options，在其下加入SystemdCgroup = true

[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
              SystemdCgroup = true
    [plugins."io.containerd.grpc.v1.cri".cni]


# 将sandbox_image默认地址改为符合版本地址

    sandbox_image = "registry.cn-hangzhou.aliyuncs.com/chenby/pause:3.6"
```

### 2.1.5启动并设置为开机启动

```shell
systemctl daemon-reload
systemctl enable --now containerd
```

### 2.1.6配置crictl客户端连接的运行时位置

```shell
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.23.0/crictl-v1.23.0-linux-amd64.tar.gz

#解压
tar xf crictl-v1.23.0-linux-amd64.tar.gz -C /usr/bin/
#生成配置文件

cat > /etc/crictl.yaml <<EOF
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 10
debug: false
EOF

#测试
systemctl restart  containerd
crictl info

```



## 2.2.k8s与etcd下载及安装（仅在master01操作）

### 2.2.1解压k8s安装包

```shell
# 解压k8s安装文件
cd cby
tar -xf kubernetes-server-linux-amd64.tar.gz  --strip-components=3 -C /usr/local/bin kubernetes/server/bin/kube{let,ctl,-apiserver,-controller-manager,-scheduler,-proxy}

# 解压etcd安装文件
tar -xf etcd-v3.5.4-linux-amd64.tar.gz --strip-components=1 -C /usr/local/bin etcd-v3.5.4-linux-amd64/etcd{,ctl}

# 查看/usr/local/bin下内容

ls /usr/local/bin/
etcd  etcdctl  kube-apiserver  kube-controller-manager  kubectl  kubelet  kube-proxy  kube-scheduler

```

### 2.2.2查看版本

```shell
[root@k8s-master01 ~]# kubelet --version
Kubernetes v1.24.0
[root@k8s-master01 ~]# etcdctl version
etcdctl version: 3.5.4
API version: 3.5
[root@k8s-master01 ~]# 
```

### 2.2.3将组件发送至其他k8s节点

```shell
Master='k8s-master02 k8s-master03'
Work='k8s-node01 k8s-node02 k8s-node03 k8s-node04 k8s-node05'

for NODE in $Master; do echo $NODE; scp /usr/local/bin/kube{let,ctl,-apiserver,-controller-manager,-scheduler,-proxy} $NODE:/usr/local/bin/; scp /usr/local/bin/etcd* $NODE:/usr/local/bin/; done

for NODE in $Work; do     scp /usr/local/bin/kube{let,-proxy} $NODE:/usr/local/bin/ ; done

mkdir -p /opt/cni/bin
```

## 2.3创建证书相关文件

```shell
mkdir pki
cd pki
cat > admin-csr.json << EOF 
{
  "CN": "admin",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Beijing",
      "L": "Beijing",
      "O": "system:masters",
      "OU": "Kubernetes-manual"
    }
  ]
}
EOF

cat > ca-config.json << EOF 
{
  "signing": {
    "default": {
      "expiry": "876000h"
    },
    "profiles": {
      "kubernetes": {
        "usages": [
            "signing",
            "key encipherment",
            "server auth",
            "client auth"
        ],
        "expiry": "876000h"
      }
    }
  }
}
EOF

cat > etcd-ca-csr.json  << EOF 
{
  "CN": "etcd",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Beijing",
      "L": "Beijing",
      "O": "etcd",
      "OU": "Etcd Security"
    }
  ],
  "ca": {
    "expiry": "876000h"
  }
}
EOF

cat > front-proxy-ca-csr.json  << EOF 
{
  "CN": "kubernetes",
  "key": {
     "algo": "rsa",
     "size": 2048
  },
  "ca": {
    "expiry": "876000h"
  }
}
EOF

cat > kubelet-csr.json  << EOF 
{
  "CN": "system:node:$NODE",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "L": "Beijing",
      "ST": "Beijing",
      "O": "system:nodes",
      "OU": "Kubernetes-manual"
    }
  ]
}
EOF

cat > manager-csr.json << EOF 
{
  "CN": "system:kube-controller-manager",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Beijing",
      "L": "Beijing",
      "O": "system:kube-controller-manager",
      "OU": "Kubernetes-manual"
    }
  ]
}
EOF

cat > apiserver-csr.json << EOF 
{
  "CN": "kube-apiserver",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Beijing",
      "L": "Beijing",
      "O": "Kubernetes",
      "OU": "Kubernetes-manual"
    }
  ]
}
EOF


cat > ca-csr.json   << EOF 
{
  "CN": "kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Beijing",
      "L": "Beijing",
      "O": "Kubernetes",
      "OU": "Kubernetes-manual"
    }
  ],
  "ca": {
    "expiry": "876000h"
  }
}
EOF

cat > etcd-csr.json << EOF 
{
  "CN": "etcd",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Beijing",
      "L": "Beijing",
      "O": "etcd",
      "OU": "Etcd Security"
    }
  ]
}
EOF


cat > front-proxy-client-csr.json  << EOF 
{
  "CN": "front-proxy-client",
  "key": {
     "algo": "rsa",
     "size": 2048
  }
}
EOF


cat > kube-proxy-csr.json  << EOF 
{
  "CN": "system:kube-proxy",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Beijing",
      "L": "Beijing",
      "O": "system:kube-proxy",
      "OU": "Kubernetes-manual"
    }
  ]
}
EOF


cat > scheduler-csr.json << EOF 
{
  "CN": "system:kube-scheduler",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Beijing",
      "L": "Beijing",
      "O": "system:kube-scheduler",
      "OU": "Kubernetes-manual"
    }
  ]
}
EOF

cd ..
mkdir bootstrap
cd bootstrap
cat > bootstrap.secret.yaml << EOF 
apiVersion: v1
kind: Secret
metadata:
  name: bootstrap-token-c8ad9c
  namespace: kube-system
type: bootstrap.kubernetes.io/token
stringData:
  description: "The default bootstrap token generated by 'kubelet '."
  token-id: c8ad9c
  token-secret: 2e4d610cf3e7426e
  usage-bootstrap-authentication: "true"
  usage-bootstrap-signing: "true"
  auth-extra-groups:  system:bootstrappers:default-node-token,system:bootstrappers:worker,system:bootstrappers:ingress
 
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: kubelet-bootstrap
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:node-bootstrapper
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: system:bootstrappers:default-node-token
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: node-autoapprove-bootstrap
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:certificates.k8s.io:certificatesigningrequests:nodeclient
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: system:bootstrappers:default-node-token
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: node-autoapprove-certificate-rotation
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:certificates.k8s.io:certificatesigningrequests:selfnodeclient
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: system:nodes
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: system:kube-apiserver-to-kubelet
rules:
  - apiGroups:
      - ""
    resources:
      - nodes/proxy
      - nodes/stats
      - nodes/log
      - nodes/spec
      - nodes/metrics
    verbs:
      - "*"
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: system:kube-apiserver
  namespace: ""
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:kube-apiserver-to-kubelet
subjects:
  - apiGroup: rbac.authorization.k8s.io
    kind: User
    name: kube-apiserver
EOF


cd ..
mkdir coredns
cd coredns
cat > coredns.yaml << EOF 
apiVersion: v1
kind: ServiceAccount
metadata:
  name: coredns
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: system:coredns
rules:
  - apiGroups:
    - ""
    resources:
    - endpoints
    - services
    - pods
    - namespaces
    verbs:
    - list
    - watch
  - apiGroups:
    - discovery.k8s.io
    resources:
    - endpointslices
    verbs:
    - list
    - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: system:coredns
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:coredns
subjects:
- kind: ServiceAccount
  name: coredns
  namespace: kube-system
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        errors
        health {
          lameduck 5s
        }
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
          fallthrough in-addr.arpa ip6.arpa
        }
        prometheus :9153
        forward . /etc/resolv.conf {
          max_concurrent 1000
        }
        cache 30
        loop
        reload
        loadbalance
    }
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: coredns
  namespace: kube-system
  labels:
    k8s-app: kube-dns
    kubernetes.io/name: "CoreDNS"
spec:
  # replicas: not specified here:
  # 1. Default is 1.
  # 2. Will be tuned in real time if DNS horizontal auto-scaling is turned on.
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
  selector:
    matchLabels:
      k8s-app: kube-dns
  template:
    metadata:
      labels:
        k8s-app: kube-dns
    spec:
      priorityClassName: system-cluster-critical
      serviceAccountName: coredns
      tolerations:
        - key: "CriticalAddonsOnly"
          operator: "Exists"
      nodeSelector:
        kubernetes.io/os: linux
      affinity:
         podAntiAffinity:
           preferredDuringSchedulingIgnoredDuringExecution:
           - weight: 100
             podAffinityTerm:
               labelSelector:
                 matchExpressions:
                   - key: k8s-app
                     operator: In
                     values: ["kube-dns"]
               topologyKey: kubernetes.io/hostname
      containers:
      - name: coredns
        image: registry.cn-beijing.aliyuncs.com/dotbalo/coredns:1.8.6 
        imagePullPolicy: IfNotPresent
        resources:
          limits:
            memory: 170Mi
          requests:
            cpu: 100m
            memory: 70Mi
        args: [ "-conf", "/etc/coredns/Corefile" ]
        volumeMounts:
        - name: config-volume
          mountPath: /etc/coredns
          readOnly: true
        ports:
        - containerPort: 53
          name: dns
          protocol: UDP
        - containerPort: 53
          name: dns-tcp
          protocol: TCP
        - containerPort: 9153
          name: metrics
          protocol: TCP
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            add:
            - NET_BIND_SERVICE
            drop:
            - all
          readOnlyRootFilesystem: true
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
            scheme: HTTP
          initialDelaySeconds: 60
          timeoutSeconds: 5
          successThreshold: 1
          failureThreshold: 5
        readinessProbe:
          httpGet:
            path: /ready
            port: 8181
            scheme: HTTP
      dnsPolicy: Default
      volumes:
        - name: config-volume
          configMap:
            name: coredns
            items:
            - key: Corefile
              path: Corefile
---
apiVersion: v1
kind: Service
metadata:
  name: kube-dns
  namespace: kube-system
  annotations:
    prometheus.io/port: "9153"
    prometheus.io/scrape: "true"
  labels:
    k8s-app: kube-dns
    kubernetes.io/cluster-service: "true"
    kubernetes.io/name: "CoreDNS"
spec:
  selector:
    k8s-app: kube-dns
  clusterIP: 10.96.0.10 
  ports:
  - name: dns
    port: 53
    protocol: UDP
  - name: dns-tcp
    port: 53
    protocol: TCP
  - name: metrics
    port: 9153
    protocol: TCP
EOF


cd ..
mkdir metrics-server
cd metrics-server
cat > metrics-server.yaml << EOF 
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    k8s-app: metrics-server
    rbac.authorization.k8s.io/aggregate-to-admin: "true"
    rbac.authorization.k8s.io/aggregate-to-edit: "true"
    rbac.authorization.k8s.io/aggregate-to-view: "true"
  name: system:aggregated-metrics-reader
rules:
- apiGroups:
  - metrics.k8s.io
  resources:
  - pods
  - nodes
  verbs:
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    k8s-app: metrics-server
  name: system:metrics-server
rules:
- apiGroups:
  - ""
  resources:
  - pods
  - nodes
  - nodes/stats
  - namespaces
  - configmaps
  verbs:
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server-auth-reader
  namespace: kube-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: extension-apiserver-authentication-reader
subjects:
- kind: ServiceAccount
  name: metrics-server
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server:system:auth-delegator
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator
subjects:
- kind: ServiceAccount
  name: metrics-server
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    k8s-app: metrics-server
  name: system:metrics-server
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:metrics-server
subjects:
- kind: ServiceAccount
  name: metrics-server
  namespace: kube-system
---
apiVersion: v1
kind: Service
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server
  namespace: kube-system
spec:
  ports:
  - name: https
    port: 443
    protocol: TCP
    targetPort: https
  selector:
    k8s-app: metrics-server
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server
  namespace: kube-system
spec:
  selector:
    matchLabels:
      k8s-app: metrics-server
  strategy:
    rollingUpdate:
      maxUnavailable: 0
  template:
    metadata:
      labels:
        k8s-app: metrics-server
    spec:
      containers:
      - args:
        - --cert-dir=/tmp
        - --secure-port=4443
        - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
        - --kubelet-use-node-status-port
        - --metric-resolution=15s
        - --kubelet-insecure-tls
        - --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.pem # change to front-proxy-ca.crt for kubeadm
        - --requestheader-username-headers=X-Remote-User
        - --requestheader-group-headers=X-Remote-Group
        - --requestheader-extra-headers-prefix=X-Remote-Extra-
        image: registry.cn-beijing.aliyuncs.com/dotbalo/metrics-server:0.5.0
        imagePullPolicy: IfNotPresent
        livenessProbe:
          failureThreshold: 3
          httpGet:
            path: /livez
            port: https
            scheme: HTTPS
          periodSeconds: 10
        name: metrics-server
        ports:
        - containerPort: 4443
          name: https
          protocol: TCP
        readinessProbe:
          failureThreshold: 3
          httpGet:
            path: /readyz
            port: https
            scheme: HTTPS
          initialDelaySeconds: 20
          periodSeconds: 10
        resources:
          requests:
            cpu: 100m
            memory: 200Mi
        securityContext:
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          runAsUser: 1000
        volumeMounts:
        - mountPath: /tmp
          name: tmp-dir
        - name: ca-ssl
          mountPath: /etc/kubernetes/pki
      nodeSelector:
        kubernetes.io/os: linux
      priorityClassName: system-cluster-critical
      serviceAccountName: metrics-server
      volumes:
      - emptyDir: {}
        name: tmp-dir
      - name: ca-ssl
        hostPath:
          path: /etc/kubernetes/pki

---
apiVersion: apiregistration.k8s.io/v1
kind: APIService
metadata:
  labels:
    k8s-app: metrics-server
  name: v1beta1.metrics.k8s.io
spec:
  group: metrics.k8s.io
  groupPriorityMinimum: 100
  insecureSkipTLSVerify: true
  service:
    name: metrics-server
    namespace: kube-system
  version: v1beta1
  versionPriority: 100
EOF
```

# 3.相关证书生成

```shell
master01节点下载证书生成工具
wget "https://github.com/cloudflare/cfssl/releases/download/v1.6.1/cfssl_1.6.1_linux_amd64" -O /usr/local/bin/cfssl
wget "https://github.com/cloudflare/cfssl/releases/download/v1.6.1/cfssljson_1.6.1_linux_amd64" -O /usr/local/bin/cfssljson
chmod +x /usr/local/bin/cfssl /usr/local/bin/cfssljson
```

## 3.1.生成etcd证书

特别说明除外，以下操作在所有master节点操作

### 3.1.1所有master节点创建证书存放目录

```shell
mkdir /etc/etcd/ssl -p
```

### 3.1.2master01节点生成etcd证书

```shell
cd pki

# 生成etcd证书和etcd证书的key（如果你觉得以后可能会扩容，可以在ip那多写几个预留出来）

cfssl gencert -initca etcd-ca-csr.json | cfssljson -bare /etc/etcd/ssl/etcd-ca

cfssl gencert \
   -ca=/etc/etcd/ssl/etcd-ca.pem \
   -ca-key=/etc/etcd/ssl/etcd-ca-key.pem \
   -config=ca-config.json \
   -hostname=127.0.0.1,k8s-master01,k8s-master02,k8s-master03,10.0.0.81,10.0.0.82,10.0.0.83,2408:8207:78ce:7561::10,2408:8207:78ce:7561::20,2408:8207:78ce:7561::30 \
   -profile=kubernetes \
   etcd-csr.json | cfssljson -bare /etc/etcd/ssl/etcd
```

### 3.1.3将证书复制到其他节点

```shell
Master='k8s-master02 k8s-master03'

for NODE in $Master; do ssh $NODE "mkdir -p /etc/etcd/ssl"; for FILE in etcd-ca-key.pem  etcd-ca.pem  etcd-key.pem  etcd.pem; do scp /etc/etcd/ssl/${FILE} $NODE:/etc/etcd/ssl/${FILE}; done; done
```

## 3.2.生成k8s相关证书

特别说明除外，以下操作在所有master节点操作

### 3.2.1所有k8s节点创建证书存放目录

```shell
mkdir -p /etc/kubernetes/pki
```

### 3.2.2master01节点生成k8s证书

```shell
# 生成一个根证书

cfssl gencert -initca ca-csr.json | cfssljson -bare /etc/kubernetes/pki/ca

# 10.96.0.1是service网段的第一个地址，需要计算，10.0.0.89为高可用vip地址

cfssl gencert   \
-ca=/etc/kubernetes/pki/ca.pem   \
-ca-key=/etc/kubernetes/pki/ca-key.pem   \
-config=ca-config.json   \
-hostname=10.96.0.1,10.0.0.89,127.0.0.1,kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.default.svc.cluster.local,x.oiox.cn,k.oiox.cn,l.oiox.cn,o.oiox.cn,10.0.0.81,10.0.0.82,10.0.0.83,10.0.0.84,10.0.0.85,10.0.0.86,10.0.0.87,10.0.0.88,10.0.0.80,10.0.0.90,10.0.0.40,10.0.0.41,2408:8207:78ce:7561::10,2408:8207:78ce:7561::20,2408:8207:78ce:7561::30,2408:8207:78ce:7561::40,2408:8207:78ce:7561::50,2408:8207:78ce:7561::60,2408:8207:78ce:7561::70,2408:8207:78ce:7561::80,2408:8207:78ce:7561::90,2408:8207:78ce:7561::100   \
-profile=kubernetes   apiserver-csr.json | cfssljson -bare /etc/kubernetes/pki/apiserver
```

### 3.2.3生成apiserver聚合证书

```shell
cfssl gencert   -initca front-proxy-ca-csr.json | cfssljson -bare /etc/kubernetes/pki/front-proxy-ca 

# 有一个警告，可以忽略

cfssl gencert  \
-ca=/etc/kubernetes/pki/front-proxy-ca.pem   \
-ca-key=/etc/kubernetes/pki/front-proxy-ca-key.pem   \
-config=ca-config.json   \
-profile=kubernetes   front-proxy-client-csr.json | cfssljson -bare /etc/kubernetes/pki/front-proxy-client
```

### 3.2.4生成controller-manage的证书

```shell
cfssl gencert \
   -ca=/etc/kubernetes/pki/ca.pem \
   -ca-key=/etc/kubernetes/pki/ca-key.pem \
   -config=ca-config.json \
   -profile=kubernetes \
   manager-csr.json | cfssljson -bare /etc/kubernetes/pki/controller-manager

# 设置一个集群项

kubectl config set-cluster kubernetes \
     --certificate-authority=/etc/kubernetes/pki/ca.pem \
     --embed-certs=true \
     --server=https://10.0.0.89:8443 \
     --kubeconfig=/etc/kubernetes/controller-manager.kubeconfig

# 设置一个环境项，一个上下文

kubectl config set-context system:kube-controller-manager@kubernetes \
    --cluster=kubernetes \
    --user=system:kube-controller-manager \
    --kubeconfig=/etc/kubernetes/controller-manager.kubeconfig

# 设置一个用户项

kubectl config set-credentials system:kube-controller-manager \
     --client-certificate=/etc/kubernetes/pki/controller-manager.pem \
     --client-key=/etc/kubernetes/pki/controller-manager-key.pem \
     --embed-certs=true \
     --kubeconfig=/etc/kubernetes/controller-manager.kubeconfig

# 设置默认环境

kubectl config use-context system:kube-controller-manager@kubernetes \
     --kubeconfig=/etc/kubernetes/controller-manager.kubeconfig

cfssl gencert \
   -ca=/etc/kubernetes/pki/ca.pem \
   -ca-key=/etc/kubernetes/pki/ca-key.pem \
   -config=ca-config.json \
   -profile=kubernetes \
   scheduler-csr.json | cfssljson -bare /etc/kubernetes/pki/scheduler

kubectl config set-cluster kubernetes \
     --certificate-authority=/etc/kubernetes/pki/ca.pem \
     --embed-certs=true \
     --server=https://10.0.0.89:8443 \
     --kubeconfig=/etc/kubernetes/scheduler.kubeconfig

kubectl config set-credentials system:kube-scheduler \
     --client-certificate=/etc/kubernetes/pki/scheduler.pem \
     --client-key=/etc/kubernetes/pki/scheduler-key.pem \
     --embed-certs=true \
     --kubeconfig=/etc/kubernetes/scheduler.kubeconfig

kubectl config set-context system:kube-scheduler@kubernetes \
     --cluster=kubernetes \
     --user=system:kube-scheduler \
     --kubeconfig=/etc/kubernetes/scheduler.kubeconfig

kubectl config use-context system:kube-scheduler@kubernetes \
     --kubeconfig=/etc/kubernetes/scheduler.kubeconfig

cfssl gencert \
   -ca=/etc/kubernetes/pki/ca.pem \
   -ca-key=/etc/kubernetes/pki/ca-key.pem \
   -config=ca-config.json \
   -profile=kubernetes \
   admin-csr.json | cfssljson -bare /etc/kubernetes/pki/admin

kubectl config set-cluster kubernetes     \
  --certificate-authority=/etc/kubernetes/pki/ca.pem     \
  --embed-certs=true     \
  --server=https://10.0.0.89:8443     \
  --kubeconfig=/etc/kubernetes/admin.kubeconfig

kubectl config set-credentials kubernetes-admin  \
  --client-certificate=/etc/kubernetes/pki/admin.pem     \
  --client-key=/etc/kubernetes/pki/admin-key.pem     \
  --embed-certs=true     \
  --kubeconfig=/etc/kubernetes/admin.kubeconfig

kubectl config set-context kubernetes-admin@kubernetes    \
  --cluster=kubernetes     \
  --user=kubernetes-admin     \
  --kubeconfig=/etc/kubernetes/admin.kubeconfig

kubectl config use-context kubernetes-admin@kubernetes  --kubeconfig=/etc/kubernetes/admin.kubeconfig
```

### 3.2.5创建ServiceAccount Key ——secret

```shell
openssl genrsa -out /etc/kubernetes/pki/sa.key 2048
openssl rsa -in /etc/kubernetes/pki/sa.key -pubout -out /etc/kubernetes/pki/sa.pub
```

### 3.2.6将证书发送到其他master节点

```shell
for NODE in k8s-master02 k8s-master03; do  for FILE in $(ls /etc/kubernetes/pki | grep -v etcd); do  scp /etc/kubernetes/pki/${FILE} $NODE:/etc/kubernetes/pki/${FILE}; done;  for FILE in admin.kubeconfig controller-manager.kubeconfig scheduler.kubeconfig; do  scp /etc/kubernetes/${FILE} $NODE:/etc/kubernetes/${FILE}; done; done
```

### 3.2.7查看证书

```shell
ls /etc/kubernetes/pki/
admin.csr      apiserver-key.pem  ca.pem                      front-proxy-ca.csr      front-proxy-client-key.pem  scheduler.csr
admin-key.pem  apiserver.pem      controller-manager.csr      front-proxy-ca-key.pem  front-proxy-client.pem      scheduler-key.pem
admin.pem      ca.csr             controller-manager-key.pem  front-proxy-ca.pem      sa.key                      scheduler.pem
apiserver.csr  ca-key.pem         controller-manager.pem      front-proxy-client.csr  sa.pub

# 一共23个就对了

ls /etc/kubernetes/pki/ |wc -l
23
```

# 4.k8s系统组件配置

## 4.1.etcd配置

### 4.1.1master01配置

```shell
# 如果要用IPv6那么把IPv4地址修改为IPv6即可
cat > /etc/etcd/etcd.config.yml << EOF 
name: 'k8s-master01'
data-dir: /var/lib/etcd
wal-dir: /var/lib/etcd/wal
snapshot-count: 5000
heartbeat-interval: 100
election-timeout: 1000
quota-backend-bytes: 0
listen-peer-urls: 'https://10.0.0.81:2380'
listen-client-urls: 'https://10.0.0.81:2379,http://127.0.0.1:2379'
max-snapshots: 3
max-wals: 5
cors:
initial-advertise-peer-urls: 'https://10.0.0.81:2380'
advertise-client-urls: 'https://10.0.0.81:2379'
discovery:
discovery-fallback: 'proxy'
discovery-proxy:
discovery-srv:
initial-cluster: 'k8s-master01=https://10.0.0.81:2380,k8s-master02=https://10.0.0.82:2380,k8s-master03=https://10.0.0.83:2380'
initial-cluster-token: 'etcd-k8s-cluster'
initial-cluster-state: 'new'
strict-reconfig-check: false
enable-v2: true
enable-pprof: true
proxy: 'off'
proxy-failure-wait: 5000
proxy-refresh-interval: 30000
proxy-dial-timeout: 1000
proxy-write-timeout: 5000
proxy-read-timeout: 0
client-transport-security:
  cert-file: '/etc/kubernetes/pki/etcd/etcd.pem'
  key-file: '/etc/kubernetes/pki/etcd/etcd-key.pem'
  client-cert-auth: true
  trusted-ca-file: '/etc/kubernetes/pki/etcd/etcd-ca.pem'
  auto-tls: true
peer-transport-security:
  cert-file: '/etc/kubernetes/pki/etcd/etcd.pem'
  key-file: '/etc/kubernetes/pki/etcd/etcd-key.pem'
  peer-client-cert-auth: true
  trusted-ca-file: '/etc/kubernetes/pki/etcd/etcd-ca.pem'
  auto-tls: true
debug: false
log-package-levels:
log-outputs: [default]
force-new-cluster: false
EOF
```

### 4.1.2master02配置

```shell
# 如果要用IPv6那么把IPv4地址修改为IPv6即可
cat > /etc/etcd/etcd.config.yml << EOF 
name: 'k8s-master02'
data-dir: /var/lib/etcd
wal-dir: /var/lib/etcd/wal
snapshot-count: 5000
heartbeat-interval: 100
election-timeout: 1000
quota-backend-bytes: 0
listen-peer-urls: 'https://10.0.0.82:2380'
listen-client-urls: 'https://10.0.0.82:2379,http://127.0.0.1:2379'
max-snapshots: 3
max-wals: 5
cors:
initial-advertise-peer-urls: 'https://10.0.0.82:2380'
advertise-client-urls: 'https://10.0.0.82:2379'
discovery:
discovery-fallback: 'proxy'
discovery-proxy:
discovery-srv:
initial-cluster: 'k8s-master01=https://10.0.0.81:2380,k8s-master02=https://10.0.0.82:2380,k8s-master03=https://10.0.0.83:2380'
initial-cluster-token: 'etcd-k8s-cluster'
initial-cluster-state: 'new'
strict-reconfig-check: false
enable-v2: true
enable-pprof: true
proxy: 'off'
proxy-failure-wait: 5000
proxy-refresh-interval: 30000
proxy-dial-timeout: 1000
proxy-write-timeout: 5000
proxy-read-timeout: 0
client-transport-security:
  cert-file: '/etc/kubernetes/pki/etcd/etcd.pem'
  key-file: '/etc/kubernetes/pki/etcd/etcd-key.pem'
  client-cert-auth: true
  trusted-ca-file: '/etc/kubernetes/pki/etcd/etcd-ca.pem'
  auto-tls: true
peer-transport-security:
  cert-file: '/etc/kubernetes/pki/etcd/etcd.pem'
  key-file: '/etc/kubernetes/pki/etcd/etcd-key.pem'
  peer-client-cert-auth: true
  trusted-ca-file: '/etc/kubernetes/pki/etcd/etcd-ca.pem'
  auto-tls: true
debug: false
log-package-levels:
log-outputs: [default]
force-new-cluster: false
EOF
```

### 4.1.3master03配置

```shell
# 如果要用IPv6那么把IPv4地址修改为IPv6即可
cat > /etc/etcd/etcd.config.yml << EOF 
name: 'k8s-master03'
data-dir: /var/lib/etcd
wal-dir: /var/lib/etcd/wal
snapshot-count: 5000
heartbeat-interval: 100
election-timeout: 1000
quota-backend-bytes: 0
listen-peer-urls: 'https://10.0.0.83:2380'
listen-client-urls: 'https://10.0.0.83:2379,http://127.0.0.1:2379'
max-snapshots: 3
max-wals: 5
cors:
initial-advertise-peer-urls: 'https://10.0.0.83:2380'
advertise-client-urls: 'https://10.0.0.83:2379'
discovery:
discovery-fallback: 'proxy'
discovery-proxy:
discovery-srv:
initial-cluster: 'k8s-master01=https://10.0.0.81:2380,k8s-master02=https://10.0.0.82:2380,k8s-master03=https://10.0.0.83:2380'
initial-cluster-token: 'etcd-k8s-cluster'
initial-cluster-state: 'new'
strict-reconfig-check: false
enable-v2: true
enable-pprof: true
proxy: 'off'
proxy-failure-wait: 5000
proxy-refresh-interval: 30000
proxy-dial-timeout: 1000
proxy-write-timeout: 5000
proxy-read-timeout: 0
client-transport-security:
  cert-file: '/etc/kubernetes/pki/etcd/etcd.pem'
  key-file: '/etc/kubernetes/pki/etcd/etcd-key.pem'
  client-cert-auth: true
  trusted-ca-file: '/etc/kubernetes/pki/etcd/etcd-ca.pem'
  auto-tls: true
peer-transport-security:
  cert-file: '/etc/kubernetes/pki/etcd/etcd.pem'
  key-file: '/etc/kubernetes/pki/etcd/etcd-key.pem'
  peer-client-cert-auth: true
  trusted-ca-file: '/etc/kubernetes/pki/etcd/etcd-ca.pem'
  auto-tls: true
debug: false
log-package-levels:
log-outputs: [default]
force-new-cluster: false
EOF
```

## 4.2.创建service（所有master节点操作）

### 4.2.1创建etcd.service并启动

```shell
cat > /usr/lib/systemd/system/etcd.service << EOF

[Unit]
Description=Etcd Service
Documentation=https://coreos.com/etcd/docs/latest/
After=network.target

[Service]
Type=notify
ExecStart=/usr/local/bin/etcd --config-file=/etc/etcd/etcd.config.yml
Restart=on-failure
RestartSec=10
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
Alias=etcd3.service

EOF
```

### 4.2.2创建etcd证书目录

```shell
mkdir /etc/kubernetes/pki/etcd
ln -s /etc/etcd/ssl/* /etc/kubernetes/pki/etcd/
systemctl daemon-reload
systemctl enable --now etcd
```

### 4.2.3查看etcd状态

```shell
# 如果要用IPv6那么把IPv4地址修改为IPv6即可
export ETCDCTL_API=3
etcdctl --endpoints="10.0.0.83:2379,10.0.0.82:2379,10.0.0.81:2379" --cacert=/etc/kubernetes/pki/etcd/etcd-ca.pem --cert=/etc/kubernetes/pki/etcd/etcd.pem --key=/etc/kubernetes/pki/etcd/etcd-key.pem  endpoint status --write-out=table
+----------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|    ENDPOINT    |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+----------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| 10.0.0.83:2379 | c0c8142615b9523f |   3.5.4 |   20 kB |     false |      false |         2 |          9 |                  9 |        |
| 10.0.0.82:2379 | de8396604d2c160d |   3.5.4 |   20 kB |     false |      false |         2 |          9 |                  9 |        |
| 10.0.0.81:2379 | 33c9d6df0037ab97 |   3.5.4 |   20 kB |      true |      false |         2 |          9 |                  9 |        |
+----------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+

[root@k8s-master01 pki]# 
```

# 5.高可用配置

## 5.1在lb01和lb02两台服务器上操作

### 5.1.1安装keepalived和haproxy服务

```shell
systemctl disable --now firewalld

setenforce 0
sed -i 's#SELINUX=enforcing#SELINUX=disabled#g' /etc/selinux/config


yum -y install keepalived haproxy
```

### 5.1.2修改haproxy配置文件（两台配置文件一样）

```shell
# cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.bak

cat >/etc/haproxy/haproxy.cfg<<"EOF"
global
 maxconn 2000
 ulimit-n 16384
 log 127.0.0.1 local0 err
 stats timeout 30s

defaults
 log global
 mode http
 option httplog
 timeout connect 5000
 timeout client 50000
 timeout server 50000
 timeout http-request 15s
 timeout http-keep-alive 15s


frontend monitor-in
 bind *:33305
 mode http
 option httplog
 monitor-uri /monitor

frontend k8s-master
 bind 0.0.0.0:8443
 bind 127.0.0.1:8443
 mode tcp
 option tcplog
 tcp-request inspect-delay 5s
 default_backend k8s-master


backend k8s-master
 mode tcp
 option tcplog
 option tcp-check
 balance roundrobin
 default-server inter 10s downinter 5s rise 2 fall 2 slowstart 60s maxconn 250 maxqueue 256 weight 100
 server  k8s-master01  10.0.0.81:6443 check
 server  k8s-master02  10.0.0.82:6443 check
 server  k8s-master03  10.0.0.83:6443 check
EOF
```

### 5.1.3lb01配置keepalived master节点

```shell
#cp /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf.bak

cat > /etc/keepalived/keepalived.conf << EOF
! Configuration File for keepalived

global_defs {
    router_id LVS_DEVEL
}
vrrp_script chk_apiserver {
    script "/etc/keepalived/check_apiserver.sh"
    interval 5 
    weight -5
    fall 2
    rise 1
}
vrrp_instance VI_1 {
    state MASTER
    interface ens160
    mcast_src_ip 10.0.0.80
    virtual_router_id 51
    priority 100
    nopreempt
    advert_int 2
    authentication {
        auth_type PASS
        auth_pass K8SHA_KA_AUTH
    }
    virtual_ipaddress {
        10.0.0.89
    }
    track_script {
      chk_apiserver 
} }

EOF
```

### 5.1.4lb02配置keepalived backup节点

```shell
# cp /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf.bak

cat > /etc/keepalived/keepalived.conf << EOF
! Configuration File for keepalived

global_defs {
    router_id LVS_DEVEL
}
vrrp_script chk_apiserver {
    script "/etc/keepalived/check_apiserver.sh"
    interval 5 
    weight -5
    fall 2
    rise 1

}
vrrp_instance VI_1 {
    state BACKUP
    interface ens160
    mcast_src_ip 10.0.0.90
    virtual_router_id 51
    priority 50
    nopreempt
    advert_int 2
    authentication {
        auth_type PASS
        auth_pass K8SHA_KA_AUTH
    }
    virtual_ipaddress {
        10.0.0.89
    }
    track_script {
      chk_apiserver 
} }

EOF
```

### 5.1.5健康检查脚本配置（两台lb主机）

```shell
cat >  /etc/keepalived/check_apiserver.sh << EOF
#!/bin/bash

err=0
for k in \$(seq 1 3)
do
    check_code=\$(pgrep haproxy)
    if [[ \$check_code == "" ]]; then
        err=\$(expr \$err + 1)
        sleep 1
        continue
    else
        err=0
        break
    fi
done

if [[ \$err != "0" ]]; then
    echo "systemctl stop keepalived"
    /usr/bin/systemctl stop keepalived
    exit 1
else
    exit 0
fi
EOF

# 给脚本授权

chmod +x /etc/keepalived/check_apiserver.sh
```

### 5.1.6启动服务

```shell
systemctl daemon-reload
systemctl enable --now haproxy
systemctl enable --now keepalived
```

### 5.1.7测试高可用

```shell
# 能ping同

[root@k8s-node02 ~]# ping 10.0.0.89

# 能telnet访问

[root@k8s-node02 ~]# telnet 10.0.0.89 8443

# 关闭主节点，看vip是否漂移到备节点
```

# 6.k8s组件配置（区别于第4点）

所有k8s节点创建以下目录

```shell
mkdir -p /etc/kubernetes/manifests/ /etc/systemd/system/kubelet.service.d /var/lib/kubelet /var/log/kubernetes
```

## 6.1.创建apiserver（所有master节点）

### 6.1.1master01节点配置

```shell
cat > /usr/lib/systemd/system/kube-apiserver.service << EOF

[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes
After=network.target

[Service]
ExecStart=/usr/local/bin/kube-apiserver \
      --v=2  \
      --logtostderr=true  \
      --allow-privileged=true  \
      --bind-address=0.0.0.0  \
      --secure-port=6443  \
      --advertise-address=10.0.0.81 \
      --service-cluster-ip-range=10.96.0.0/12,fd00::/108  \
      --feature-gates=IPv6DualStack=true  \
      --service-node-port-range=30000-32767  \
      --etcd-servers=https://10.0.0.81:2379,https://10.0.0.82:2379,https://10.0.0.83:2379 \
      --etcd-cafile=/etc/etcd/ssl/etcd-ca.pem  \
      --etcd-certfile=/etc/etcd/ssl/etcd.pem  \
      --etcd-keyfile=/etc/etcd/ssl/etcd-key.pem  \
      --client-ca-file=/etc/kubernetes/pki/ca.pem  \
      --tls-cert-file=/etc/kubernetes/pki/apiserver.pem  \
      --tls-private-key-file=/etc/kubernetes/pki/apiserver-key.pem  \
      --kubelet-client-certificate=/etc/kubernetes/pki/apiserver.pem  \
      --kubelet-client-key=/etc/kubernetes/pki/apiserver-key.pem  \
      --service-account-key-file=/etc/kubernetes/pki/sa.pub  \
      --service-account-signing-key-file=/etc/kubernetes/pki/sa.key  \
      --service-account-issuer=https://kubernetes.default.svc.cluster.local \
      --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname  \
      --enable-admission-plugins=NamespaceLifecycle,LimitRanger,ServiceAccount,DefaultStorageClass,DefaultTolerationSeconds,NodeRestriction,ResourceQuota  \
      --authorization-mode=Node,RBAC  \
      --enable-bootstrap-token-auth=true  \
      --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.pem  \
      --proxy-client-cert-file=/etc/kubernetes/pki/front-proxy-client.pem  \
      --proxy-client-key-file=/etc/kubernetes/pki/front-proxy-client-key.pem  \
      --requestheader-allowed-names=aggregator  \
      --requestheader-group-headers=X-Remote-Group  \
      --requestheader-extra-headers-prefix=X-Remote-Extra-  \
      --requestheader-username-headers=X-Remote-User \
      --enable-aggregator-routing=true
      # --token-auth-file=/etc/kubernetes/token.csv

Restart=on-failure
RestartSec=10s
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target

EOF
```

### 6.1.2master02节点配置

```shell
cat > /usr/lib/systemd/system/kube-apiserver.service << EOF
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes
After=network.target

[Service]
ExecStart=/usr/local/bin/kube-apiserver \
      --v=2  \
      --logtostderr=true  \
      --allow-privileged=true  \
      --bind-address=0.0.0.0  \
      --secure-port=6443  \
      --advertise-address=10.0.0.82 \
      --service-cluster-ip-range=10.96.0.0/12,fd00::/108  \
			--feature-gates=IPv6DualStack=true \
      --service-node-port-range=30000-32767  \
      --etcd-servers=https://10.0.0.81:2379,https://10.0.0.82:2379,https://10.0.0.83:2379 \
      --etcd-cafile=/etc/etcd/ssl/etcd-ca.pem  \
      --etcd-certfile=/etc/etcd/ssl/etcd.pem  \
      --etcd-keyfile=/etc/etcd/ssl/etcd-key.pem  \
      --client-ca-file=/etc/kubernetes/pki/ca.pem  \
      --tls-cert-file=/etc/kubernetes/pki/apiserver.pem  \
      --tls-private-key-file=/etc/kubernetes/pki/apiserver-key.pem  \
      --kubelet-client-certificate=/etc/kubernetes/pki/apiserver.pem  \
      --kubelet-client-key=/etc/kubernetes/pki/apiserver-key.pem  \
      --service-account-key-file=/etc/kubernetes/pki/sa.pub  \
      --service-account-signing-key-file=/etc/kubernetes/pki/sa.key  \
      --service-account-issuer=https://kubernetes.default.svc.cluster.local \
      --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname  \
      --enable-admission-plugins=NamespaceLifecycle,LimitRanger,ServiceAccount,DefaultStorageClass,DefaultTolerationSeconds,NodeRestriction,ResourceQuota  \
      --authorization-mode=Node,RBAC  \
      --enable-bootstrap-token-auth=true  \
      --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.pem  \
      --proxy-client-cert-file=/etc/kubernetes/pki/front-proxy-client.pem  \
      --proxy-client-key-file=/etc/kubernetes/pki/front-proxy-client-key.pem  \
      --requestheader-allowed-names=aggregator  \
      --requestheader-group-headers=X-Remote-Group  \
      --requestheader-extra-headers-prefix=X-Remote-Extra-  \
      --requestheader-username-headers=X-Remote-User \
      --enable-aggregator-routing=true
      # --token-auth-file=/etc/kubernetes/token.csv

Restart=on-failure
RestartSec=10s
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target

EOF
```

### 6.1.3master03节点配置

```shell
cat > /usr/lib/systemd/system/kube-apiserver.service  << EOF

[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes
After=network.target

[Service]
ExecStart=/usr/local/bin/kube-apiserver \
      --v=2  \
      --logtostderr=true  \
      --allow-privileged=true  \
      --bind-address=0.0.0.0  \
      --secure-port=6443  \
      --advertise-address=10.0.0.83 \
      --service-cluster-ip-range=10.96.0.0/12,fd00::/108  \
			--feature-gates=IPv6DualStack=true \
      --service-node-port-range=30000-32767  \
      --etcd-servers=https://10.0.0.81:2379,https://10.0.0.82:2379,https://10.0.0.83:2379 \
      --etcd-cafile=/etc/etcd/ssl/etcd-ca.pem  \
      --etcd-certfile=/etc/etcd/ssl/etcd.pem  \
      --etcd-keyfile=/etc/etcd/ssl/etcd-key.pem  \
      --client-ca-file=/etc/kubernetes/pki/ca.pem  \
      --tls-cert-file=/etc/kubernetes/pki/apiserver.pem  \
      --tls-private-key-file=/etc/kubernetes/pki/apiserver-key.pem  \
      --kubelet-client-certificate=/etc/kubernetes/pki/apiserver.pem  \
      --kubelet-client-key=/etc/kubernetes/pki/apiserver-key.pem  \
      --service-account-key-file=/etc/kubernetes/pki/sa.pub  \
      --service-account-signing-key-file=/etc/kubernetes/pki/sa.key  \
      --service-account-issuer=https://kubernetes.default.svc.cluster.local \
      --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname  \
      --enable-admission-plugins=NamespaceLifecycle,LimitRanger,ServiceAccount,DefaultStorageClass,DefaultTolerationSeconds,NodeRestriction,ResourceQuota  \
      --authorization-mode=Node,RBAC  \
      --enable-bootstrap-token-auth=true  \
      --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.pem  \
      --proxy-client-cert-file=/etc/kubernetes/pki/front-proxy-client.pem  \
      --proxy-client-key-file=/etc/kubernetes/pki/front-proxy-client-key.pem  \
      --requestheader-allowed-names=aggregator  \
      --requestheader-group-headers=X-Remote-Group  \
      --requestheader-extra-headers-prefix=X-Remote-Extra-  \
      --requestheader-username-headers=X-Remote-User \
      --enable-aggregator-routing=true

Restart=on-failure
RestartSec=10s
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target

EOF
```

### 6.1.4启动apiserver（所有master节点）

```shell
systemctl daemon-reload && systemctl enable --now kube-apiserver

# 注意查看状态是否启动正常

systemctl status kube-apiserver
```

## 6.2.配置kube-controller-manager service

```shell
# 所有master节点配置，且配置相同
# 172.16.0.0/12为pod网段，按需求设置你自己的网段

cat > /usr/lib/systemd/system/kube-controller-manager.service << EOF

[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/kubernetes/kubernetes
After=network.target

[Service]
ExecStart=/usr/local/bin/kube-controller-manager \
      --v=2 \
      --logtostderr=true \
      --bind-address=127.0.0.1 \
      --root-ca-file=/etc/kubernetes/pki/ca.pem \
      --cluster-signing-cert-file=/etc/kubernetes/pki/ca.pem \
      --cluster-signing-key-file=/etc/kubernetes/pki/ca-key.pem \
      --service-account-private-key-file=/etc/kubernetes/pki/sa.key \
      --kubeconfig=/etc/kubernetes/controller-manager.kubeconfig \
      --leader-elect=true \
      --use-service-account-credentials=true \
      --node-monitor-grace-period=40s \
      --node-monitor-period=5s \
      --pod-eviction-timeout=2m0s \
      --controllers=*,bootstrapsigner,tokencleaner \
      --allocate-node-cidrs=true \
      --feature-gates=IPv6DualStack=true \
      --service-cluster-ip-range=10.96.0.0/12,fd00::/108 \
      --cluster-cidr=172.16.0.0/12,fc00::/48 \
      --node-cidr-mask-size-ipv4=24 \
      --node-cidr-mask-size-ipv6=64 \
      --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.pem 

Restart=always
RestartSec=10s

[Install]
WantedBy=multi-user.target

EOF
```

### 6.2.1启动kube-controller-manager，并查看状态

```shell
systemctl daemon-reload
systemctl enable --now kube-controller-manager
systemctl  status kube-controller-manager
```

## 6.3.配置kube-scheduler service

### 6.3.1所有master节点配置，且配置相同

```shell
cat > /usr/lib/systemd/system/kube-scheduler.service << EOF

[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/kubernetes/kubernetes
After=network.target

[Service]
ExecStart=/usr/local/bin/kube-scheduler \
      --v=2 \
      --logtostderr=true \
      --bind-address=127.0.0.1 \
      --leader-elect=true \
      --kubeconfig=/etc/kubernetes/scheduler.kubeconfig

Restart=always
RestartSec=10s

[Install]
WantedBy=multi-user.target

EOF
```

### 6.3.2启动并查看服务状态

```shell
systemctl daemon-reload
systemctl enable --now kube-scheduler
systemctl status kube-scheduler
```

# 7.TLS Bootstrapping配置

## 7.1在master01上配置

```shell
cd bootstrap

kubectl config set-cluster kubernetes     \
--certificate-authority=/etc/kubernetes/pki/ca.pem     \
--embed-certs=true     --server=https://10.0.0.89:8443     \
--kubeconfig=/etc/kubernetes/bootstrap-kubelet.kubeconfig

kubectl config set-credentials tls-bootstrap-token-user     \
--token=c8ad9c.2e4d610cf3e7426e \
--kubeconfig=/etc/kubernetes/bootstrap-kubelet.kubeconfig

kubectl config set-context tls-bootstrap-token-user@kubernetes     \
--cluster=kubernetes     \
--user=tls-bootstrap-token-user     \
--kubeconfig=/etc/kubernetes/bootstrap-kubelet.kubeconfig

kubectl config use-context tls-bootstrap-token-user@kubernetes     \
--kubeconfig=/etc/kubernetes/bootstrap-kubelet.kubeconfig

# token的位置在bootstrap.secret.yaml，如果修改的话到这个文件修改

mkdir -p /root/.kube ; cp /etc/kubernetes/admin.kubeconfig /root/.kube/config
```

## 7.2查看集群状态，没问题的话继续后续操作

```shell
kubectl get cs

Warning: v1 ComponentStatus is deprecated in v1.19+
NAME                 STATUS    MESSAGE                         ERROR
scheduler            Healthy   ok                              
controller-manager   Healthy   ok                              
etcd-0               Healthy   {"health":"true","reason":""}   
etcd-2               Healthy   {"health":"true","reason":""}   
etcd-1               Healthy   {"health":"true","reason":""} 

kubectl create -f bootstrap.secret.yaml
```

# 8.node节点配置

## 8.1.在master01上将证书复制到node节点

```shell
cd /etc/kubernetes/
 
for NODE in k8s-master02 k8s-master03 k8s-node01 k8s-node02 k8s-node03 k8s-node04 k8s-node05; do ssh $NODE mkdir -p /etc/kubernetes/pki; for FILE in pki/ca.pem pki/ca-key.pem pki/front-proxy-ca.pem bootstrap-kubelet.kubeconfig; do scp /etc/kubernetes/$FILE $NODE:/etc/kubernetes/${FILE}; done; done
```

## 8.2.kubelet配置

### 8.2.1所有k8s节点创建相关目录

```shell
mkdir -p /var/lib/kubelet /var/log/kubernetes /etc/systemd/system/kubelet.service.d /etc/kubernetes/manifests/

# 所有k8s节点配置kubelet service
cat > /usr/lib/systemd/system/kubelet.service << EOF

[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=containerd.service
Requires=containerd.service

[Service]
ExecStart=/usr/local/bin/kubelet \
    --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.kubeconfig  \
    --kubeconfig=/etc/kubernetes/kubelet.kubeconfig \
    --config=/etc/kubernetes/kubelet-conf.yml \
    --container-runtime=remote  \
    --runtime-request-timeout=15m  \
    --container-runtime-endpoint=unix:///run/containerd/containerd.sock  \
    --cgroup-driver=systemd \
    --node-labels=node.kubernetes.io/node='' \
    --feature-gates=IPv6DualStack=true

[Install]
WantedBy=multi-user.target
EOF
```

### 8.2.2所有k8s节点创建kubelet的配置文件

```shell
cat > /etc/kubernetes/kubelet-conf.yml <<EOF
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
address: 0.0.0.0
port: 10250
readOnlyPort: 10255
authentication:
  anonymous:
    enabled: false
  webhook:
    cacheTTL: 2m0s
    enabled: true
  x509:
    clientCAFile: /etc/kubernetes/pki/ca.pem
authorization:
  mode: Webhook
  webhook:
    cacheAuthorizedTTL: 5m0s
    cacheUnauthorizedTTL: 30s
cgroupDriver: systemd
cgroupsPerQOS: true
clusterDNS:
- 10.96.0.10
clusterDomain: cluster.local
containerLogMaxFiles: 5
containerLogMaxSize: 10Mi
contentType: application/vnd.kubernetes.protobuf
cpuCFSQuota: true
cpuManagerPolicy: none
cpuManagerReconcilePeriod: 10s
enableControllerAttachDetach: true
enableDebuggingHandlers: true
enforceNodeAllocatable:
- pods
eventBurst: 10
eventRecordQPS: 5
evictionHard:
  imagefs.available: 15%
  memory.available: 100Mi
  nodefs.available: 10%
  nodefs.inodesFree: 5%
evictionPressureTransitionPeriod: 5m0s
failSwapOn: true
fileCheckFrequency: 20s
hairpinMode: promiscuous-bridge
healthzBindAddress: 127.0.0.1
healthzPort: 10248
httpCheckFrequency: 20s
imageGCHighThresholdPercent: 85
imageGCLowThresholdPercent: 80
imageMinimumGCAge: 2m0s
iptablesDropBit: 15
iptablesMasqueradeBit: 14
kubeAPIBurst: 10
kubeAPIQPS: 5
makeIPTablesUtilChains: true
maxOpenFiles: 1000000
maxPods: 110
nodeStatusUpdateFrequency: 10s
oomScoreAdj: -999
podPidsLimit: -1
registryBurst: 10
registryPullQPS: 5
resolvConf: /etc/resolv.conf
rotateCertificates: true
runtimeRequestTimeout: 2m0s
serializeImagePulls: true
staticPodPath: /etc/kubernetes/manifests
streamingConnectionIdleTimeout: 4h0m0s
syncFrequency: 1m0s
volumeStatsAggPeriod: 1m0s
EOF
```

### 8.2.3启动kubelet

```shell
systemctl daemon-reload
systemctl restart kubelet
systemctl enable --now kubelet
```

### 8.2.4查看集群

```shell
[root@k8s-master01 ~]# kubectl  get node
NAME           STATUS     ROLES    AGE   VERSION
k8s-master01   NotReady   <none>   12s   v1.24.0
k8s-master02   NotReady   <none>   12s   v1.24.0
k8s-master03   NotReady   <none>   12s   v1.24.0
k8s-node01     NotReady   <none>   12s   v1.24.0
k8s-node02     NotReady   <none>   12s   v1.24.0
k8s-node03     NotReady   <none>   12s   v1.24.0
k8s-node04     NotReady   <none>   12s   v1.24.0
k8s-node05     NotReady   <none>   12s   v1.24.0
[root@k8s-master01 ~]#

```

## 8.3.kube-proxy配置

### 8.3.1此配置只在master01操作

```shell
cp /etc/kubernetes/admin.kubeconfig /etc/kubernetes/kube-proxy.kubeconfig
```

### 8.3.2将kubeconfig发送至其他节点

```shell
for NODE in k8s-master02 k8s-master03; do scp /etc/kubernetes/kube-proxy.kubeconfig $NODE:/etc/kubernetes/kube-proxy.kubeconfig; done

for NODE in k8s-node01 k8s-node02 k8s-node03 k8s-node04 k8s-node05; do scp /etc/kubernetes/kube-proxy.kubeconfig $NODE:/etc/kubernetes/kube-proxy.kubeconfig;  done
```

### 8.3.3所有k8s节点添加kube-proxy的配置和service文件

```shell
cat >  /usr/lib/systemd/system/kube-proxy.service << EOF
[Unit]
Description=Kubernetes Kube Proxy
Documentation=https://github.com/kubernetes/kubernetes
After=network.target

[Service]
ExecStart=/usr/local/bin/kube-proxy \
  --config=/etc/kubernetes/kube-proxy.yaml \
  --v=2

Restart=always
RestartSec=10s

[Install]
WantedBy=multi-user.target

EOF
```

```shell
cat > /etc/kubernetes/kube-proxy.yaml << EOF
apiVersion: kubeproxy.config.k8s.io/v1alpha1
bindAddress: 0.0.0.0
clientConnection:
  acceptContentTypes: ""
  burst: 10
  contentType: application/vnd.kubernetes.protobuf
  kubeconfig: /etc/kubernetes/kube-proxy.kubeconfig
  qps: 5
clusterCIDR: 172.16.0.0/12,fc00::/48 
configSyncPeriod: 15m0s
conntrack:
  max: null
  maxPerCore: 32768
  min: 131072
  tcpCloseWaitTimeout: 1h0m0s
  tcpEstablishedTimeout: 24h0m0s
enableProfiling: false
healthzBindAddress: 0.0.0.0:10256
hostnameOverride: ""
iptables:
  masqueradeAll: false
  masqueradeBit: 14
  minSyncPeriod: 0s
  syncPeriod: 30s
ipvs:
  masqueradeAll: true
  minSyncPeriod: 5s
  scheduler: "rr"
  syncPeriod: 30s
kind: KubeProxyConfiguration
metricsBindAddress: 127.0.0.1:10249
mode: "ipvs"
nodePortAddresses: null
oomScoreAdj: -999
portRange: ""
udpIdleTimeout: 250ms

EOF
```

### 8.3.4启动kube-proxy

```shell
 systemctl daemon-reload
 systemctl restart kube-proxy
 systemctl enable --now kube-proxy
```

# 9.安装Calico

## 9.1以下步骤只在master01操作

### 9.1.1更改calico网段

```shell
# vim calico.yaml
# calico-config ConfigMap处
    "ipam": {
        "type": "calico-ipam",
        "assign_ipv4": "true",
        "assign_ipv6": "true"
    },
    - name: IP
      value: "autodetect"

    - name: IP6
      value: "autodetect"

    - name: CALICO_IPV4POOL_CIDR
      value: "172.16.0.0/16"

    - name: CALICO_IPV6POOL_CIDR
      value: "fc00::/48"

    - name: FELIX_IPV6SUPPORT
      value: "true"

# kubectl apply -f calico.yaml
kubectl apply -f calico-ipv6.yaml 
```

### 9.1.2查看容器状态

```shell
[root@k8s-master01 ~]# kubectl  get pod -A
NAMESPACE     NAME                                       READY   STATUS    RESTARTS   AGE
kube-system   calico-kube-controllers-7fb57bc4b5-dwwg8   1/1     Running   0          23s
kube-system   calico-node-b8p4z                          1/1     Running   0          23s
kube-system   calico-node-c4lzj                          1/1     Running   0          23s
kube-system   calico-node-dfh2m                          1/1     Running   0          23s
kube-system   calico-node-gbhgn                          1/1     Running   0          23s
kube-system   calico-node-ht6nl                          1/1     Running   0          23s
kube-system   calico-node-lv8bm                          1/1     Running   0          23s
kube-system   calico-node-rm7d4                          1/1     Running   0          23s
kube-system   calico-node-z976w                          1/1     Running   0          23s
kube-system   calico-typha-dd885f47-jvgsj                1/1     Running   0          23s
[root@k8s-master01 ~]# 


[root@k8s-master01 ~]# kubectl  get node
NAME           STATUS   ROLES    AGE   VERSION
k8s-master01   Ready    <none>   14h   v1.23.5
k8s-master02   Ready    <none>   14h   v1.23.5
k8s-master03   Ready    <none>   14h   v1.23.5
k8s-node01     Ready    <none>   14h   v1.23.5
k8s-node02     Ready    <none>   14h   v1.23.5
k8s-node03     Ready    <none>   14h   v1.23.5
k8s-node04     Ready    <none>   14h   v1.23.5
k8s-node05     Ready    <none>   14h   v1.23.5
[root@k8s-master01 ~]# 
```

# 10.安装CoreDNS

## 10.1以下步骤只在master01操作

### 10.1.1修改文件

```shell
cd coredns/

sed -i "s#10.96.0.10#10.96.0.10#g" coredns.yaml

cat coredns.yaml | grep clusterIP:
  clusterIP: 10.96.0.10 
```

### 10.1.2安装

```shell
kubectl  create -f coredns.yaml 
serviceaccount/coredns created
clusterrole.rbac.authorization.k8s.io/system:coredns created
clusterrolebinding.rbac.authorization.k8s.io/system:coredns created
configmap/coredns created
deployment.apps/coredns created
service/kube-dns created
```

# 11.安装Metrics Server

## 11.1以下步骤只在master01操作

### 11.1.1安装Metrics-server

在新版的Kubernetes中系统资源的采集均使用Metrics-server，可以通过Metrics采集节点和Pod的内存、磁盘、CPU和网络的使用率

```shell
# 安装metrics server
cd metrics-server/

kubectl  apply -f metrics-server.yaml 
```

### 11.1.2稍等片刻查看状态

```shell
kubectl  top node
NAME           CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%   
k8s-master01   154m         1%     1715Mi          21%       
k8s-master02   151m         1%     1274Mi          16%       
k8s-master03   523m         6%     1345Mi          17%       
k8s-node01     84m          1%     671Mi           8%        
k8s-node02     73m          0%     727Mi           9%        
k8s-node03     96m          1%     769Mi           9%        
k8s-node04     68m          0%     673Mi           8%        
k8s-node05     82m          1%     679Mi           8% 
```

# 12.集群验证

## 12.1部署pod资源

```shell
cat<<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: busybox
  namespace: default
spec:
  containers:
  - name: busybox
    image: busybox:1.28
    command:
      - sleep
      - "3600"
    imagePullPolicy: IfNotPresent
  restartPolicy: Always
EOF



# 查看

kubectl  get pod
NAME      READY   STATUS    RESTARTS   AGE
busybox   1/1     Running   0          17s
```

## 12.2用pod解析默认命名空间中的kubernetes

```shell
kubectl get svc
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   17h


kubectl exec  busybox -n default -- nslookup kubernetes
3Server:    10.96.0.10
Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local

Name:      kubernetes
Address 1: 10.96.0.1 kubernetes.default.svc.cluster.local
```

## 12.3测试跨命名空间是否可以解析

```shell
kubectl exec  busybox -n default -- nslookup kube-dns.kube-system
Server:    10.96.0.10
Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local

Name:      kube-dns.kube-system
Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local
```

## 12.4每个节点都必须要能访问Kubernetes的kubernetes svc 443和kube-dns的service 53

```shell
telnet 10.96.0.1 443
Trying 10.96.0.1...
Connected to 10.96.0.1.
Escape character is '^]'.

 telnet 10.96.0.10 53
Trying 10.96.0.10...
Connected to 10.96.0.10.
Escape character is '^]'.

curl 10.96.0.10:53
curl: (52) Empty reply from server
```

## 12.5Pod和Pod之前要能通

```shell
kubectl get po -owide
NAME      READY   STATUS    RESTARTS   AGE   IP              NODE         NOMINATED NODE   READINESS GATES
busybox   1/1     Running   0          17m   172.27.14.193   k8s-node02   <none>           <none>

 kubectl get po -n kube-system -owide
NAME                                       READY   STATUS    RESTARTS      AGE   IP               NODE           NOMINATED NODE   READINESS GATES
calico-kube-controllers-5dffd5886b-4blh6   1/1     Running   0             77m   172.25.244.193   k8s-master01   <none>           <none>
calico-node-fvbdq                          1/1     Running   1 (75m ago)   77m   10.0.0.81     k8s-master01   <none>           <none>
calico-node-g8nqd                          1/1     Running   0             77m   10.0.0.84     k8s-node01     <none>           <none>
calico-node-mdps8                          1/1     Running   0             77m   10.0.0.85     k8s-node02     <none>           <none>
calico-node-nf4nt                          1/1     Running   0             77m   10.0.0.83     k8s-master03   <none>           <none>
calico-node-sq2ml                          1/1     Running   0             77m   10.0.0.82     k8s-master02   <none>           <none>
calico-typha-8445487f56-mg6p8              1/1     Running   0             77m   10.0.0.85     k8s-node02     <none>           <none>
calico-typha-8445487f56-pxbpj              1/1     Running   0             77m   10.0.0.81     k8s-master01   <none>           <none>
calico-typha-8445487f56-tnssl              1/1     Running   0             77m   10.0.0.84     k8s-node01     <none>           <none>
coredns-5db5696c7-67h79                    1/1     Running   0             63m   172.25.92.65     k8s-master02   <none>           <none>
metrics-server-6bf7dcd649-5fhrw            1/1     Running   0             61m   172.18.195.1     k8s-master03   <none>           <none>

# 进入busybox ping其他节点上的pod

kubectl exec -ti busybox -- sh
/ # ping 10.0.0.84
PING 10.0.0.84 (10.0.0.84): 56 data bytes
64 bytes from 10.0.0.84: seq=0 ttl=63 time=0.358 ms
64 bytes from 10.0.0.84: seq=1 ttl=63 time=0.668 ms
64 bytes from 10.0.0.84: seq=2 ttl=63 time=0.637 ms
64 bytes from 10.0.0.84: seq=3 ttl=63 time=0.624 ms
64 bytes from 10.0.0.84: seq=4 ttl=63 time=0.907 ms

# 可以连通证明这个pod是可以跨命名空间和跨主机通信的
```

## 12.6创建三个副本，可以看到3个副本分布在不同的节点上（用完可以删了）

```shell
cat > deployments.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80

EOF


kubectl  apply -f deployments.yaml 
deployment.apps/nginx-deployment created

kubectl  get pod 
NAME                               READY   STATUS    RESTARTS   AGE
busybox                            1/1     Running   0          6m25s
nginx-deployment-9456bbbf9-4bmvk   1/1     Running   0          8s
nginx-deployment-9456bbbf9-9rcdk   1/1     Running   0          8s
nginx-deployment-9456bbbf9-dqv8s   1/1     Running   0          8s

# 删除nginx

[root@k8s-master01 ~]# kubectl delete -f deployments.yaml 
```





# 13.安装dashboard

```shell
kubectl  apply -f dashboard.yaml
kubectl  apply -f dashboard-user.yaml
```

## 13.1更改dashboard的svc为NodePort，如果已是请忽略

```shell
kubectl edit svc kubernetes-dashboard -n kubernetes-dashboard
  type: NodePort
```

## 13.2查看端口号

```shell
kubectl get svc kubernetes-dashboard -n kubernetes-dashboard
NAME                   TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)         AGE
kubernetes-dashboard   NodePort   10.98.201.22   <none>        443:31473/TCP   10m
```

## 13.3登录dashboard

https://10.0.0.81:31245/

# 14.ingress安装

## 14.1写入配置文件，并执行

```shell
[root@hello ~/yaml]# vim deploy.yaml
[root@hello ~/yaml]# cat deploy.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: ingress-nginx
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx


---
# Source: ingress-nginx/templates/controller-serviceaccount.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    helm.sh/chart: ingress-nginx-4.0.10
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 1.1.0
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: controller
  name: ingress-nginx
  namespace: ingress-nginx
automountServiceAccountToken: true
---
# Source: ingress-nginx/templates/controller-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  labels:
    helm.sh/chart: ingress-nginx-4.0.10
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 1.1.0
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: controller
  name: ingress-nginx-controller
  namespace: ingress-nginx
data:
  allow-snippet-annotations: 'true'
---
# Source: ingress-nginx/templates/clusterrole.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    helm.sh/chart: ingress-nginx-4.0.10
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 1.1.0
    app.kubernetes.io/managed-by: Helm
  name: ingress-nginx
rules:
  - apiGroups:
      - ''
    resources:
      - configmaps
      - endpoints
      - nodes
      - pods
      - secrets
      - namespaces
    verbs:
      - list
      - watch
  - apiGroups:
      - ''
    resources:
      - nodes
    verbs:
      - get
  - apiGroups:
      - ''
    resources:
      - services
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - networking.k8s.io
    resources:
      - ingresses
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - ''
    resources:
      - events
    verbs:
      - create
      - patch
  - apiGroups:
      - networking.k8s.io
    resources:
      - ingresses/status
    verbs:
      - update
  - apiGroups:
      - networking.k8s.io
    resources:
      - ingressclasses
    verbs:
      - get
      - list
      - watch
---
# Source: ingress-nginx/templates/clusterrolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    helm.sh/chart: ingress-nginx-4.0.10
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 1.1.0
    app.kubernetes.io/managed-by: Helm
  name: ingress-nginx
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: ingress-nginx
subjects:
  - kind: ServiceAccount
    name: ingress-nginx
    namespace: ingress-nginx
---
# Source: ingress-nginx/templates/controller-role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  labels:
    helm.sh/chart: ingress-nginx-4.0.10
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 1.1.0
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: controller
  name: ingress-nginx
  namespace: ingress-nginx
rules:
  - apiGroups:
      - ''
    resources:
      - namespaces
    verbs:
      - get
  - apiGroups:
      - ''
    resources:
      - configmaps
      - pods
      - secrets
      - endpoints
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - ''
    resources:
      - services
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - networking.k8s.io
    resources:
      - ingresses
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - networking.k8s.io
    resources:
      - ingresses/status
    verbs:
      - update
  - apiGroups:
      - networking.k8s.io
    resources:
      - ingressclasses
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - ''
    resources:
      - configmaps
    resourceNames:
      - ingress-controller-leader
    verbs:
      - get
      - update
  - apiGroups:
      - ''
    resources:
      - configmaps
    verbs:
      - create
  - apiGroups:
      - ''
    resources:
      - events
    verbs:
      - create
      - patch
---
# Source: ingress-nginx/templates/controller-rolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  labels:
    helm.sh/chart: ingress-nginx-4.0.10
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 1.1.0
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: controller
  name: ingress-nginx
  namespace: ingress-nginx
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: ingress-nginx
subjects:
  - kind: ServiceAccount
    name: ingress-nginx
    namespace: ingress-nginx
---
# Source: ingress-nginx/templates/controller-service-webhook.yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    helm.sh/chart: ingress-nginx-4.0.10
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 1.1.0
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: controller
  name: ingress-nginx-controller-admission
  namespace: ingress-nginx
spec:
  type: ClusterIP
  ports:
    - name: https-webhook
      port: 443
      targetPort: webhook
      appProtocol: https
  selector:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/component: controller
---
# Source: ingress-nginx/templates/controller-service.yaml
apiVersion: v1
kind: Service
metadata:
  annotations:
  labels:
    helm.sh/chart: ingress-nginx-4.0.10
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 1.1.0
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: controller
  name: ingress-nginx-controller
  namespace: ingress-nginx
spec:
  type: NodePort
  externalTrafficPolicy: Local
  ipFamilyPolicy: SingleStack
  ipFamilies:
    - IPv4
  ports:
    - name: http
      port: 80
      protocol: TCP
      targetPort: http
      appProtocol: http
    - name: https
      port: 443
      protocol: TCP
      targetPort: https
      appProtocol: https
  selector:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/component: controller
---
# Source: ingress-nginx/templates/controller-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    helm.sh/chart: ingress-nginx-4.0.10
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 1.1.0
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: controller
  name: ingress-nginx-controller
  namespace: ingress-nginx
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: ingress-nginx
      app.kubernetes.io/instance: ingress-nginx
      app.kubernetes.io/component: controller
  revisionHistoryLimit: 10
  minReadySeconds: 0
  template:
    metadata:
      labels:
        app.kubernetes.io/name: ingress-nginx
        app.kubernetes.io/instance: ingress-nginx
        app.kubernetes.io/component: controller
    spec:
      dnsPolicy: ClusterFirst
      containers:
        - name: controller
          image: registry.cn-hangzhou.aliyuncs.com/chenby/controller:v1.1.3 
          imagePullPolicy: IfNotPresent
          lifecycle:
            preStop:
              exec:
                command:
                  - /wait-shutdown
          args:
            - /nginx-ingress-controller
            - --election-id=ingress-controller-leader
            - --controller-class=k8s.io/ingress-nginx
            - --configmap=$(POD_NAMESPACE)/ingress-nginx-controller
            - --validating-webhook=:8443
            - --validating-webhook-certificate=/usr/local/certificates/cert
            - --validating-webhook-key=/usr/local/certificates/key
          securityContext:
            capabilities:
              drop:
                - ALL
              add:
                - NET_BIND_SERVICE
            runAsUser: 101
            allowPrivilegeEscalation: true
          env:
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: POD_NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
            - name: LD_PRELOAD
              value: /usr/local/lib/libmimalloc.so
          livenessProbe:
            failureThreshold: 5
            httpGet:
              path: /healthz
              port: 10254
              scheme: HTTP
            initialDelaySeconds: 10
            periodSeconds: 10
            successThreshold: 1
            timeoutSeconds: 1
          readinessProbe:
            failureThreshold: 3
            httpGet:
              path: /healthz
              port: 10254
              scheme: HTTP
            initialDelaySeconds: 10
            periodSeconds: 10
            successThreshold: 1
            timeoutSeconds: 1
          ports:
            - name: http
              containerPort: 80
              protocol: TCP
            - name: https
              containerPort: 443
              protocol: TCP
            - name: webhook
              containerPort: 8443
              protocol: TCP
          volumeMounts:
            - name: webhook-cert
              mountPath: /usr/local/certificates/
              readOnly: true
          resources:
            requests:
              cpu: 100m
              memory: 90Mi
      nodeSelector:
        kubernetes.io/os: linux
      serviceAccountName: ingress-nginx
      terminationGracePeriodSeconds: 300
      volumes:
        - name: webhook-cert
          secret:
            secretName: ingress-nginx-admission
---
# Source: ingress-nginx/templates/controller-ingressclass.yaml
# We don't support namespaced ingressClass yet
# So a ClusterRole and a ClusterRoleBinding is required
apiVersion: networking.k8s.io/v1
kind: IngressClass
metadata:
  labels:
    helm.sh/chart: ingress-nginx-4.0.10
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 1.1.0
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: controller
  name: nginx
  namespace: ingress-nginx
spec:
  controller: k8s.io/ingress-nginx
---
# Source: ingress-nginx/templates/admission-webhooks/validating-webhook.yaml
# before changing this value, check the required kubernetes version
# https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/#prerequisites
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingWebhookConfiguration
metadata:
  labels:
    helm.sh/chart: ingress-nginx-4.0.10
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 1.1.0
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: admission-webhook
  name: ingress-nginx-admission
webhooks:
  - name: validate.nginx.ingress.kubernetes.io
    matchPolicy: Equivalent
    rules:
      - apiGroups:
          - networking.k8s.io
        apiVersions:
          - v1
        operations:
          - CREATE
          - UPDATE
        resources:
          - ingresses
    failurePolicy: Fail
    sideEffects: None
    admissionReviewVersions:
      - v1
    clientConfig:
      service:
        namespace: ingress-nginx
        name: ingress-nginx-controller-admission
        path: /networking/v1/ingresses
---
# Source: ingress-nginx/templates/admission-webhooks/job-patch/serviceaccount.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ingress-nginx-admission
  namespace: ingress-nginx
  annotations:
    helm.sh/hook: pre-install,pre-upgrade,post-install,post-upgrade
    helm.sh/hook-delete-policy: before-hook-creation,hook-succeeded
  labels:
    helm.sh/chart: ingress-nginx-4.0.10
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 1.1.0
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: admission-webhook
---
# Source: ingress-nginx/templates/admission-webhooks/job-patch/clusterrole.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: ingress-nginx-admission
  annotations:
    helm.sh/hook: pre-install,pre-upgrade,post-install,post-upgrade
    helm.sh/hook-delete-policy: before-hook-creation,hook-succeeded
  labels:
    helm.sh/chart: ingress-nginx-4.0.10
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 1.1.0
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: admission-webhook
rules:
  - apiGroups:
      - admissionregistration.k8s.io
    resources:
      - validatingwebhookconfigurations
    verbs:
      - get
      - update
---
# Source: ingress-nginx/templates/admission-webhooks/job-patch/clusterrolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: ingress-nginx-admission
  annotations:
    helm.sh/hook: pre-install,pre-upgrade,post-install,post-upgrade
    helm.sh/hook-delete-policy: before-hook-creation,hook-succeeded
  labels:
    helm.sh/chart: ingress-nginx-4.0.10
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 1.1.0
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: admission-webhook
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: ingress-nginx-admission
subjects:
  - kind: ServiceAccount
    name: ingress-nginx-admission
    namespace: ingress-nginx
---
# Source: ingress-nginx/templates/admission-webhooks/job-patch/role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: ingress-nginx-admission
  namespace: ingress-nginx
  annotations:
    helm.sh/hook: pre-install,pre-upgrade,post-install,post-upgrade
    helm.sh/hook-delete-policy: before-hook-creation,hook-succeeded
  labels:
    helm.sh/chart: ingress-nginx-4.0.10
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 1.1.0
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: admission-webhook
rules:
  - apiGroups:
      - ''
    resources:
      - secrets
    verbs:
      - get
      - create
---
# Source: ingress-nginx/templates/admission-webhooks/job-patch/rolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: ingress-nginx-admission
  namespace: ingress-nginx
  annotations:
    helm.sh/hook: pre-install,pre-upgrade,post-install,post-upgrade
    helm.sh/hook-delete-policy: before-hook-creation,hook-succeeded
  labels:
    helm.sh/chart: ingress-nginx-4.0.10
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 1.1.0
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: admission-webhook
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: ingress-nginx-admission
subjects:
  - kind: ServiceAccount
    name: ingress-nginx-admission
    namespace: ingress-nginx
---
# Source: ingress-nginx/templates/admission-webhooks/job-patch/job-createSecret.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: ingress-nginx-admission-create
  namespace: ingress-nginx
  annotations:
    helm.sh/hook: pre-install,pre-upgrade
    helm.sh/hook-delete-policy: before-hook-creation,hook-succeeded
  labels:
    helm.sh/chart: ingress-nginx-4.0.10
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 1.1.0
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: admission-webhook
spec:
  template:
    metadata:
      name: ingress-nginx-admission-create
      labels:
        helm.sh/chart: ingress-nginx-4.0.10
        app.kubernetes.io/name: ingress-nginx
        app.kubernetes.io/instance: ingress-nginx
        app.kubernetes.io/version: 1.1.0
        app.kubernetes.io/managed-by: Helm
        app.kubernetes.io/component: admission-webhook
    spec:
      containers:
        - name: create
          image: registry.cn-hangzhou.aliyuncs.com/chenby/kube-webhook-certgen:v1.1.1 
          imagePullPolicy: IfNotPresent
          args:
            - create
            - --host=ingress-nginx-controller-admission,ingress-nginx-controller-admission.$(POD_NAMESPACE).svc
            - --namespace=$(POD_NAMESPACE)
            - --secret-name=ingress-nginx-admission
          env:
            - name: POD_NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
          securityContext:
            allowPrivilegeEscalation: false
      restartPolicy: OnFailure
      serviceAccountName: ingress-nginx-admission
      nodeSelector:
        kubernetes.io/os: linux
      securityContext:
        runAsNonRoot: true
        runAsUser: 2000
---
# Source: ingress-nginx/templates/admission-webhooks/job-patch/job-patchWebhook.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: ingress-nginx-admission-patch
  namespace: ingress-nginx
  annotations:
    helm.sh/hook: post-install,post-upgrade
    helm.sh/hook-delete-policy: before-hook-creation,hook-succeeded
  labels:
    helm.sh/chart: ingress-nginx-4.0.10
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 1.1.0
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: admission-webhook
spec:
  template:
    metadata:
      name: ingress-nginx-admission-patch
      labels:
        helm.sh/chart: ingress-nginx-4.0.10
        app.kubernetes.io/name: ingress-nginx
        app.kubernetes.io/instance: ingress-nginx
        app.kubernetes.io/version: 1.1.0
        app.kubernetes.io/managed-by: Helm
        app.kubernetes.io/component: admission-webhook
    spec:
      containers:
        - name: patch
          image: registry.cn-hangzhou.aliyuncs.com/chenby/kube-webhook-certgen:v1.1.1 
          imagePullPolicy: IfNotPresent
          args:
            - patch
            - --webhook-name=ingress-nginx-admission
            - --namespace=$(POD_NAMESPACE)
            - --patch-mutating=false
            - --secret-name=ingress-nginx-admission
            - --patch-failure-policy=Fail
          env:
            - name: POD_NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
          securityContext:
            allowPrivilegeEscalation: false
      restartPolicy: OnFailure
      serviceAccountName: ingress-nginx-admission
      nodeSelector:
        kubernetes.io/os: linux
      securityContext:
        runAsNonRoot: true
        runAsUser: 2000
[root@hello ~/yaml]#

```



## 14.2启用后端，写入配置文件执行

```shell
[root@hello ~/yaml]# vim backend.yaml
[root@hello ~/yaml]# cat backend.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: default-http-backend
  labels:
    app.kubernetes.io/name: default-http-backend
  namespace: kube-system
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: default-http-backend
  template:
    metadata:
      labels:
        app.kubernetes.io/name: default-http-backend
    spec:
      terminationGracePeriodSeconds: 60
      containers:
      - name: default-http-backend
        image: registry.cn-hangzhou.aliyuncs.com/chenby/defaultbackend-amd64:1.5 
        livenessProbe:
          httpGet:
            path: /healthz
            port: 8080
            scheme: HTTP
          initialDelaySeconds: 30
          timeoutSeconds: 5
        ports:
        - containerPort: 8080
        resources:
          limits:
            cpu: 10m
            memory: 20Mi
          requests:
            cpu: 10m
            memory: 20Mi
---
apiVersion: v1
kind: Service
metadata:
  name: default-http-backend
  namespace: kube-system
  labels:
    app.kubernetes.io/name: default-http-backend
spec:
  ports:
  - port: 80
    targetPort: 8080
  selector:
    app.kubernetes.io/name: default-http-backend
[root@hello ~/yaml]#

```



## 14.3安装测试应用

```shell
[root@hello ~/yaml]# vim ingress-demo-app.yaml
[root@hello ~/yaml]#
[root@hello ~/yaml]# cat ingress-demo-app.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-server
spec:
  replicas: 2
  selector:
    matchLabels:
      app: hello-server
  template:
    metadata:
      labels:
        app: hello-server
    spec:
      containers:
      - name: hello-server
        image: registry.cn-hangzhou.aliyuncs.com/lfy_k8s_images/hello-server
        ports:
        - containerPort: 9000
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx-demo
  name: nginx-demo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx-demo
  template:
    metadata:
      labels:
        app: nginx-demo
    spec:
      containers:
      - image: nginx
        name: nginx
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: nginx-demo
  name: nginx-demo
spec:
  selector:
    app: nginx-demo
  ports:
  - port: 8000
    protocol: TCP
    targetPort: 80
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: hello-server
  name: hello-server
spec:
  selector:
    app: hello-server
  ports:
  - port: 8000
    protocol: TCP
    targetPort: 9000
---
apiVersion: networking.k8s.io/v1
kind: Ingress  
metadata:
  name: ingress-host-bar
spec:
  ingressClassName: nginx
  rules:
  - host: "hello.chenby.cn"
    http:
      paths:
      - pathType: Prefix
        path: "/"
        backend:
          service:
            name: hello-server
            port:
              number: 8000
  - host: "demo.chenby.cn"
    http:
      paths:
      - pathType: Prefix
        path: "/nginx"  
        backend:
          service:
            name: nginx-demo
            port:
              number: 8000


```

## 14.4执行部署

```shell
kubectl  apply -f deploy.yaml 

kubectl  apply -f backend.yaml 

kubectl  apply -f ingress-demo-app.yaml 

kubectl  get ingress
NAME               CLASS   HOSTS                            ADDRESS     PORTS   AGE
ingress-host-bar   nginx   hello.chenby.cn,demo.chenby.cn   10.0.0.87   80      7s

```

## 14.5过滤查看ingress端口

```shell
[root@hello ~/yaml]# kubectl  get svc -A | grep ingress
ingress-nginx          ingress-nginx-controller             NodePort    10.104.231.36    <none>        80:32636/TCP,443:30579/TCP   104s
ingress-nginx          ingress-nginx-controller-admission   ClusterIP   10.101.85.88     <none>        443/TCP                      105s
[root@hello ~/yaml]#

```

# 15.IPv6测试



```shell
#部署应用
[root@k8s-master01 ~]# vim cby.yaml 
[root@k8s-master01 ~]# cat cby.yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: chenby
spec:
  replicas: 3
  selector:
    matchLabels:
      app: chenby
  template:
    metadata:
      labels:
        app: chenby
    spec:
      containers:
      - name: chenby
        image: nginx
        resources:
          limits:
            memory: "128Mi"
            cpu: "500m"
        ports:
        - containerPort: 80

---
apiVersion: v1
kind: Service
metadata:
  name: chenby
spec:
  ipFamilyPolicy: PreferDualStack
  ipFamilies:
  - IPv6
  - IPv4
  type: NodePort
  selector:
    app: chenby
  ports:
  - port: 80
    targetPort: 80
[root@k8s-master01 ~]# kubectl  apply -f cby.yaml

#查看端口
[root@k8s-master01 ~]# kubectl  get svc
NAME           TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
chenby         NodePort    fd00::a29c       <none>        80:30779/TCP   5s
[root@k8s-master01 ~]# 

#使用内网访问
[root@localhost yaml]# curl -I http://[fd00::a29c]
HTTP/1.1 200 OK
Server: nginx/1.21.6
Date: Thu, 05 May 2022 10:20:35 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Tue, 25 Jan 2022 15:03:52 GMT
Connection: keep-alive
ETag: "61f01158-267"
Accept-Ranges: bytes

[root@localhost yaml]# curl -I http://10.0.0.81:30779
HTTP/1.1 200 OK
Server: nginx/1.21.6
Date: Thu, 05 May 2022 10:20:59 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Tue, 25 Jan 2022 15:03:52 GMT
Connection: keep-alive
ETag: "61f01158-267"
Accept-Ranges: bytes

[root@localhost yaml]# 

#使用公网访问

[root@localhost yaml]# curl -I http://[2408:8207:78ce:7561::10]:30779
HTTP/1.1 200 OK
Server: nginx/1.21.6
Date: Thu, 05 May 2022 10:20:54 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Tue, 25 Jan 2022 15:03:52 GMT
Connection: keep-alive
ETag: "61f01158-267"
Accept-Ranges: bytes


```

# 16.安装命令行自动补全功能

```shell
yum install bash-completion -y
source /usr/share/bash-completion/bash_completion
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> ~/.bashrc
```





> https://www.oiox.cn/   
>
> https://www.chenby.cn/  
>
> https://cby-chen.github.io/  
>
> https://blog.csdn.net/qq_33921750  
>
> https://my.oschina.net/u/3981543  
>
> https://www.zhihu.com/people/chen-bu-yun-2  
>
> https://segmentfault.com/u/hppyvyv6/articles  
>
> https://juejin.cn/user/3315782802482007  
>
> https://cloud.tencent.com/developer/column/93230  
>
> https://www.jianshu.com/u/0f894314ae2c  
>
> https://www.toutiao.com/c/user/token/MS4wLjABAAAAeqOrhjsoRZSj7iBJbjLJyMwYT5D0mLOgCoo4pEmpr4A/
>
> CSDN、GitHub、知乎、开源中国、思否、掘金、简书、腾讯云、今日头条、个人博客、全网可搜《小陈运维》
>
> 文章主要发布于微信公众号：《Linux运维交流社区》
