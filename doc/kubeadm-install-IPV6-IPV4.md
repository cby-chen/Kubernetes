## 使用kubeadm初始化IPV4/IPV6集群

## CentOS 配置YUM源

```shell
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.ustc.edu.cn/kubernetes/core:/stable:/v1.37/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.37/rpm/repodata/repomd.xml.key
EOF

# 将 SELinux 设置为 permissive 模式（相当于将其禁用）
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config



yum install -y kubelet kubeadm kubectl

# 如安装老版本
# yum install kubelet-1.16.9-0 kubeadm-1.16.9-0 kubectl-1.16.9-0

systemctl enable kubelet && systemctl start kubelet
sudo systemctl enable --now kubelet
```

## Ubuntu 配置APT源

```shell
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://mirrors.ustc.edu.cn/kubernetes/core:/stable:/v1.37/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y kubelet kubeadm kubectl

# 如安装老版本
# apt install kubelet=1.23.6-00 kubeadm=1.23.6-00 kubectl=1.23.6-00
```

配置containerd


## 安装Containerd作为Runtime

```shell

# https://github.com/opencontainers/runc/releases
# 升级runc
wget https://github.com/opencontainers/runc/releases/download/v1.5.2/runc.amd64

install -m 755 runc.amd64 /usr/local/sbin/runc
cp -p /usr/local/sbin/runc  /usr/local/bin/runc
cp -p /usr/local/sbin/runc  /usr/bin/runc


# https://github.com/containerd/containerd/releases/
wget https://github.com/containerd/containerd/releases/download/v2.4.1/containerd-2.4.1-linux-amd64.tar.gz

# https://github.com/containernetworking/plugins/releases/
wget https://github.com/containernetworking/plugins/releases/download/v1.9.1/cni-plugins-linux-amd64-v1.9.1.tgz


#创建cni插件所需目录
mkdir -p /etc/cni/net.d /opt/cni/bin 
#解压cni二进制包
tar xf cni-plugins-linux-amd64-v*.tgz -C /opt/cni/bin/

# https://github.com/containerd/containerd/releases/
# wget https://github.com/containerd/containerd/releases/download/v2.0.5/containerd-2.0.5-linux-amd64.tar.gz

#解压
tar -xzf containerd-*-linux-amd64.tar.gz -C /usr/local/

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

### 配置Containerd所需的模块

```shell
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
```

### 加载模块

```shell
systemctl restart systemd-modules-load.service
```

### 配置Containerd所需的内核

```shell
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# 加载内核
sysctl --system
```

### 创建Containerd的配置文件

```shell
# 创建默认配置文件
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml

# 沙箱pause镜像
sed -i "s#registry.k8s.io#registry.aliyuncs.com/chenby#g" /etc/containerd/config.toml
cat /etc/containerd/config.toml | grep sandbox

# 配置加速器
[root@k8s-master01 ~]# vim /etc/containerd/config.toml
[root@k8s-master01 ~]# cat /etc/containerd/config.toml | grep certs.d -C 5

    [plugins.'io.containerd.cri.v1.images'.pinned_images]
      sandbox = 'registry.aliyuncs.com/chenby/pause:3.10'

    [plugins.'io.containerd.cri.v1.images'.registry]
      config_path = '/etc/containerd/certs.d'

    [plugins.'io.containerd.cri.v1.images'.image_decryption]
      key_model = 'node'

  [plugins.'io.containerd.cri.v1.runtime']
[root@k8s-master01 ~]# 


mkdir /etc/containerd/certs.d/docker.io -pv
cat > /etc/containerd/certs.d/docker.io/hosts.toml << EOF
server = "https://docker.io"
[host."https://jockerhub.com"]
  capabilities = ["pull", "resolve"]
EOF

# 配置 GFW 代理
mkdir -p /etc/systemd/system/containerd.service.d
cat > /etc/systemd/system/containerd.service.d/http-proxy.conf <<'EOF'
[Service]
Environment="HTTP_PROXY=http://192.168.1.100:7897"
Environment="HTTPS_PROXY=http://192.168.1.100:7897"
Environment="NO_PROXY=localhost,127.0.0.1,containerd,192.168.1.0/24,10.96.0.0/16,172.16.0.0/16,.svc,.svc.cluster.local,cluster.local,fd00:1111::/108,fd00:2222::/48"
EOF
systemctl daemon-reload
systemctl restart containerd
```

### 启动并设置为开机启动

```shell
systemctl daemon-reload
# 用于重新加载systemd管理的单位文件。当你新增或修改了某个单位文件（如.service文件、.socket文件等），需要运行该命令来刷新systemd对该文件的配置。

systemctl enable --now containerd.service
# 启用并立即启动docker.service单元。docker.service是Docker守护进程的systemd服务单元。

systemctl stop containerd.service
# 停止运行中的docker.service单元，即停止Docker守护进程。

systemctl start containerd.service
# 启动docker.service单元，即启动Docker守护进程。

systemctl restart containerd.service
# 重启docker.service单元，即重新启动Docker守护进程。

systemctl status containerd.service
# 显示docker.service单元的当前状态，包括运行状态、是否启用等信息。
```

### 配置crictl客户端连接的运行时位置

```shell
# https://github.com/kubernetes-sigs/cri-tools/releases/
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.37.0/crictl-v1.37.0-linux-amd64.tar.gz

#解压
tar xf crictl-v*-linux-amd64.tar.gz -C /usr/bin/
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

## 配置基础环境


```shell
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
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
net.ipv6.conf.default.forwarding = 1
EOF

sudo sysctl --system


sed -ri 's/.*swap.*/#&/' /etc/fstab
swapoff -a && sysctl -w vm.swappiness=0

cat /etc/fstab

cat > /etc/hosts <<EOF
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

fc00::21 k8s-master01
fc00::22 k8s-node01
fc00::23 k8s-node02

192.168.1.21 k8s-master01
192.168.1.22 k8s-node01
192.168.1.23 k8s-node02
EOF


hostnamectl set-hostname k8s-master01
hostnamectl set-hostname k8s-node01
hostnamectl set-hostname k8s-node02

systemctl stop firewalld
systemctl disable firewalld

```

## 初始化安装

```shell
[root@k8s-master01 ~]# kubeadm config images list
registry.k8s.io/kube-apiserver:v1.37.1
registry.k8s.io/kube-controller-manager:v1.37.1
registry.k8s.io/kube-scheduler:v1.37.1
registry.k8s.io/kube-proxy:v1.37.1
registry.k8s.io/coredns/coredns:v1.14.6
registry.k8s.io/pause:3.10.2
registry.k8s.io/etcd:3.7.0-0
[root@k8s-master01 ~]# 


[root@k8s-master01 ~]# cat kubeadm.yaml
apiVersion: kubeadm.k8s.io/v1beta4
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: "192.168.1.21"
  bindPort: 6443
nodeRegistration:
  taints:
  - effect: PreferNoSchedule
    key: node-role.kubernetes.io/master
---
apiVersion: kubeadm.k8s.io/v1beta4
kind: ClusterConfiguration
kubernetesVersion: v1.37.1
  #imageRepository: registry.cn-hangzhou.aliyuncs.com/chenby
networking:
  podSubnet: 172.16.0.0/16,fd00:2222::/48
  serviceSubnet: 10.96.0.0/16,fd00:1111::/108
[root@k8s-master01 ~]# 


[root@k8s-master01 ~]# kubeadm init --config=kubeadm.yaml

[root@k8s-node01 ~]# kubeadm join 192.168.1.21:6443 --token nw76f2.otg1p6gtt8wdxhwt \
        --discovery-token-ca-cert-hash sha256:2633c00148c73d5f54db5633aeecbee7e819884d20078f80e90a2233e3752e59


# 重置集群
kubeadm reset -f
rm -rf /etc/kubernetes/manifests
rm -rf /var/lib/etcd
rm -rf /var/lib/kubelet
rm -rf ~/.kube
systemctl restart containerd
systemctl restart kubelet
sleep 5
ss -tulnp | grep -E ':2379|:2380|:6443'

```

## 查看集群


```shell
[root@k8s-master01 ~]# kubectl  get node
NAME           STATUS     ROLES           AGE    VERSION
k8s-master01   NotReady   control-plane   101s   v1.37.1
k8s-node01     NotReady   <none>          49s    v1.37.1
k8s-node02     NotReady   <none>          49s    v1.37.1
[root@k8s-master01 ~]# 
[root@k8s-master01 ~]# kubectl  get po -A
NAMESPACE     NAME                                   READY   STATUS    RESTARTS   AGE
kube-system   coredns-559f6c778d-8nzjj               0/1     Pending   0          97s
kube-system   coredns-559f6c778d-rpt7g               0/1     Pending   0          97s
kube-system   etcd-k8s-master01                      1/1     Running   1          103s
kube-system   kube-apiserver-k8s-master01            1/1     Running   1          103s
kube-system   kube-controller-manager-k8s-master01   1/1     Running   1          103s
kube-system   kube-proxy-5l7bj                       1/1     Running   0          54s
kube-system   kube-proxy-9n7rk                       1/1     Running   0          54s
kube-system   kube-proxy-dct4b                       1/1     Running   0          97s
kube-system   kube-scheduler-k8s-master01            1/1     Running   1          103s
[root@k8s-master01 ~]# 

```



## 更改calico网段

```shell
# 查看版本
https://github.com/projectcalico/calico/tags

# 安装operator
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.32.2/manifests/tigera-operator.yaml

# 下载配置文件
curl https://raw.githubusercontent.com/projectcalico/calico/v3.32.2/manifests/custom-resources.yaml -O

# 修改地址池
vim custom-resources.yaml
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
spec:
  calicoNetwork:
    ipPools:
    - name: default-ipv4-ippool
      blockSize: 26
      cidr: 172.16.0.0/16
      encapsulation: VXLANCrossSubnet
      natOutgoing: Enabled
      nodeSelector: all()

# 修改地址池
vim custom-resources.yaml
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
spec:
  calicoNetwork:
    ipPools:
    - name: ipv4-ippool
      cidr: 172.16.0.0/16
      blockSize: 26
      # encapsulation: IPIP
      encapsulation: VXLANCrossSubnet
      natOutgoing: Enabled
      nodeSelector: all()
    - name: ipv6-ippool
      cidr: "fd00:2222::/48"
      blockSize: 122
      encapsulation: VXLANCrossSubnet
      natOutgoing: Enabled
      nodeSelector: all()
    nodeAddressAutodetectionV4:
      interface: "eth.*|en.*"
    nodeAddressAutodetectionV6:
      interface: "eth.*|en.*"


# 打开vxlan内核  适用于大多数使用 systemd 的发行版
echo "vxlan" | sudo tee /etc/modules-load.d/vxlan.conf
systemctl restart systemd-modules-load.service
lsmod | grep vxlan

# 执行安装
kubectl create -f custom-resources.yaml

# 安装客户端
curl -L https://github.com/projectcalico/calico/releases/download/v3.32.2/calicoctl-linux-amd64 -o calicoctl

# 给客户端添加执行权限
chmod +x ./calicoctl

# 查看集群节点
./calicoctl get nodes --allow-version-mismatch
# 查看集群节点状态
./calicoctl node status --allow-version-mismatch
#查看地址池
./calicoctl get ipPool --allow-version-mismatch
./calicoctl get ipPool --allow-version-mismatch -o yaml

```

## 查看容器状态

```shell
# calico 初始化会很慢 需要耐心等待一下，大约十分钟左右
[root@k8s-master01 kubernetes-v1.36.0]# kubectl get pod -A
NAMESPACE         NAME                                       READY   STATUS    RESTARTS   AGE
calico-system     calico-apiserver-7bb46cd974-2tb62          1/1     Running   0          7m46s
calico-system     calico-apiserver-7bb46cd974-92p96          1/1     Running   0          7m46s
calico-system     calico-kube-controllers-7c4f878bd8-xptks   1/1     Running   0          7m45s
calico-system     calico-node-6wbsv                          1/1     Running   0          7m46s
calico-system     calico-node-djq59                          1/1     Running   0          7m46s
calico-system     calico-node-dm97b                          1/1     Running   0          7m46s
calico-system     calico-node-lvq6w                          1/1     Running   0          7m46s
calico-system     calico-node-pmq6v                          1/1     Running   0          7m46s
calico-system     calico-typha-758c8bf6f7-8tkss              1/1     Running   0          7m43s
calico-system     calico-typha-758c8bf6f7-dqsqq              1/1     Running   0          7m46s
calico-system     calico-typha-758c8bf6f7-h7569              1/1     Running   0          7m43s
calico-system     csi-node-driver-4rld6                      2/2     Running   0          7m45s
calico-system     csi-node-driver-8krh7                      2/2     Running   0          7m45s
calico-system     csi-node-driver-bvq9q                      2/2     Running   0          7m45s
calico-system     csi-node-driver-qcb9d                      2/2     Running   0          7m45s
calico-system     csi-node-driver-xkkcj                      2/2     Running   0          7m45s
calico-system     goldmane-6885dcb7d-k26sd                   1/1     Running   0          7m46s
calico-system     whisker-898cf7b47-75pdh                    2/2     Running   0          6m53s
tigera-operator   tigera-operator-85dbff4478-sntj6           1/1     Running   0          9m13s
[root@k8s-master01 kubernetes-v1.36.0]# 

# IPIP模式 仅支持IPv4，不支持IPv6，有tun网口
[root@k8s-master01 ~]# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         192.168.1.1     0.0.0.0         UG    100    0        0 ens160
172.17.125.0    192.168.1.34    255.255.255.192 UG    0      0        0 tunl0
172.18.195.0    192.168.1.33    255.255.255.192 UG    0      0        0 tunl0
172.25.92.64    192.168.1.32    255.255.255.192 UG    0      0        0 tunl0
172.25.244.192  0.0.0.0         255.255.255.192 U     0      0        0 *
172.25.244.193  0.0.0.0         255.255.255.255 UH    0      0        0 calif3e9d7544a4
172.27.14.192   192.168.1.35    255.255.255.192 UG    0      0        0 tunl0
192.168.1.0     0.0.0.0         255.255.255.0   U     100    0        0 ens160
[root@k8s-master01 ~]#

# VXLANCrossSubnet模式，无tun网口
[root@k8s-master01 ~]# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         192.168.1.1     0.0.0.0         UG    100    0        0 ens160
172.16.32.128   0.0.0.0         255.255.255.192 U     0      0        0 *
172.16.32.129   0.0.0.0         255.255.255.255 UH    1024   0        0 calic9ff772e94d
172.16.58.192   192.168.1.35    255.255.255.192 UG    0      0        0 ens160
172.16.85.192   192.168.1.34    255.255.255.192 UG    0      0        0 ens160
172.16.122.128  192.168.1.32    255.255.255.192 UG    0      0        0 ens160
172.16.195.0    192.168.1.33    255.255.255.192 UG    0      0        0 ens160
172.17.0.0      0.0.0.0         255.255.0.0     U     0      0        0 docker0
192.168.1.0     0.0.0.0         255.255.255.0   U     100    0        0 ens160
[root@k8s-master01 ~]# 

# 路由表
[root@k8s-master01 ~]# route  -n -4 -6  | grep  vxlan
fe80::/64                      ::                         U    256 1      0 vxlan.calico
fd00:100::88bd:e5c3:433c:2080/128 ::                         Un   0   2      0 vxlan-v6.calico
fe80::/128                     ::                         Un   0   3      0 vxlan.calico
fe80::6454:d1ff:fe67:d36d/128  ::                         Un   0   2      0 vxlan.calico
ff00::/8                       ::                         U    256 1      0 vxlan.calico
ff00::/8                       ::                         U    256 1      0 vxlan-v6.calico
[root@k8s-master01 ~]#

```
## 删除
```shell
kubectl delete -f https://raw.githubusercontent.com/projectcalico/calico/v3.32.0/manifests/tigera-operator.yaml  --force --grace-period=0
kubectl delete -f https://raw.githubusercontent.com/projectcalico/calico/v3.32.0/manifests/custom-resources.yaml --force --grace-period=0
# 在所有主机上执行
modprobe -r ipip      # 删除 IPIP 模式虚拟网卡
modprobe -r vxlan     # 删除 VXLAN 模式虚拟网卡
# 在所有主机上执行
sudo rm -rf /etc/cni/net.d/*calico*
sudo rm -f /opt/cni/bin/calico*
sudo rm -f /usr/local/bin/calico*
sudo rm -rf /var/lib/cni/networks/calico/
# 在所有主机上执行
systemctl restart kubelet
```

## 测试IPV6

```shell
[root@k8s-master01 ~]# echo 'KUBELET_EXTRA_ARGS="--node-ip=192.168.1.21,fc00::21"' > /etc/sysconfig/kubelet
[root@k8s-master01 ~]# systemctl daemon-reload && systemctl restart kubelet

[root@k8s-node01 ~]# echo 'KUBELET_EXTRA_ARGS="--node-ip=192.168.1.22,fc00::22"' > /etc/sysconfig/kubelet
[root@k8s-node01 ~]# systemctl daemon-reload && systemctl restart kubelet

[root@k8s-node02 ~]# echo 'KUBELET_EXTRA_ARGS="--node-ip=192.168.1.23,fc00::23"' > /etc/sysconfig/kubelet
[root@k8s-node02 ~]# systemctl daemon-reload && systemctl restart kubelet

cat<<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: chenby
spec:
  replicas: 1
  selector:
    matchLabels:
      app: chenby
  template:
    metadata:
      labels:
        app: chenby
    spec:
      hostNetwork: true
      containers:
      - name: chenby
        image: docker.io/library/nginx
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
EOF


#查看端口
[root@k8s-master01 ~]# kubectl  get svc
NAME         TYPE        CLUSTER-IP          EXTERNAL-IP   PORT(S)        AGE
chenby       NodePort    fd00:1111::a:2aaa   <none>        80:30249/TCP   10s
kubernetes   ClusterIP   10.96.0.1           <none>        443/TCP        9m56s
[root@k8s-master01 ~]# 
[root@k8s-master01 ~]# curl -I http://[fd00:1111::a:2aaa]
HTTP/1.1 200 OK
Server: nginx/1.31.6
Date: Tue, 29 Sep 2026 09:05:19 GMT
Content-Type: text/html
Content-Length: 896
Last-Modified: Tue, 15 Sep 2026 12:54:15 GMT
Connection: keep-alive
ETag: "6aa93ff7-380"
Accept-Ranges: bytes

[root@k8s-master01 ~]# 
[root@k8s-master01 ~]# curl -I http://192.168.1.21:30249
HTTP/1.1 200 OK
Server: nginx/1.31.6
Date: Tue, 29 Sep 2026 09:05:24 GMT
Content-Type: text/html
Content-Length: 896
Last-Modified: Tue, 15 Sep 2026 12:54:15 GMT
Connection: keep-alive
ETag: "6aa93ff7-380"
Accept-Ranges: bytes

[root@k8s-master01 ~]#
[root@k8s-master01 ~]# curl -I http://[fc00::21]:30249
HTTP/1.1 200 OK
Server: nginx/1.31.6
Date: Tue, 29 Sep 2026 09:05:31 GMT
Content-Type: text/html
Content-Length: 896
Last-Modified: Tue, 15 Sep 2026 12:54:15 GMT
Connection: keep-alive
ETag: "6aa93ff7-380"
Accept-Ranges: bytes

[root@k8s-master01 ~]# 
[root@k8s-master01 ~]# curl -I http://[2409:8a10:6d7:b511:c46e:8678:944d:3ddb]:30249
HTTP/1.1 200 OK
Server: nginx/1.31.6
Date: Tue, 29 Sep 2026 09:05:39 GMT
Content-Type: text/html
Content-Length: 896
Last-Modified: Tue, 15 Sep 2026 12:54:15 GMT
Connection: keep-alive
ETag: "6aa93ff7-380"
Accept-Ranges: bytes

[root@k8s-master01 ~]# 

```

> **关于**
>
> https://www.oiox.cn/
>
> https://www.oiox.cn/index.php/start-page.html
>
> **CSDN、GitHub、知乎、开源中国、思否、掘金、简书、华为云、阿里云、腾讯云、哔哩哔哩、今日头条、新浪微博、个人博客**
>
> **全网可搜《小陈运维》**
>
> **文章主要发布于微信公众号：《Linux运维交流社区》**

