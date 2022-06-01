使用kubeadm初始化IPV4/IPV6集群
=======================

![图片](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6d3da68f95d943bb9691ea9b660b9d63~tplv-k3u1fbpfcp-zoom-1.image)

CentOS 配置YUM源
=============

```shell
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=kubernetes
baseurl=https://mirrors.ustc.edu.cn/kubernetes/yum/repos/kubernetes-el7-$basearch
enabled=1
EOF
setenforce 0
yum install -y kubelet kubeadm kubectl

# 如安装老版本
# yum install kubelet-1.16.9-0 kubeadm-1.16.9-0 kubectl-1.16.9-0

systemctl enable kubelet && systemctl start kubelet


# 将 SELinux 设置为 permissive 模式（相当于将其禁用）
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
sudo systemctl enable --now kubelet

```

Ubuntu 配置APT源
=============

```shell
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://mirrors.ustc.edu.cn/kubernetes/apt kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet kubeadm kubectl

# 如安装老版本
# apt install kubelet=1.23.6-00 kubeadm=1.23.6-00 kubectl=1.23.6-00

```

配置containerd
============

```shell
wget https://github.com/containerd/containerd/releases/download/v1.6.4/cri-containerd-cni-1.6.4-linux-amd64.tar.gz

#解压
tar -C / -xzf cri-containerd-cni-1.6.4-linux-amd64.tar.gz

#创建服务启动文件
cat > /etc/systemd/system/containerd.service <<EOF
[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target local-fs.target

[Service]
ExecStartPre=-/sbin/modprobe overlay
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


mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml

sed -i "s#SystemdCgroup\ \=\ false#SystemdCgroup\ \=\ true#g" /etc/containerd/config.toml
sed -i "s#k8s.gcr.io#registry.cn-hangzhou.aliyuncs.com/chenby#g" /etc/containerd/config.toml

systemctl daemon-reload
systemctl enable --now containerd

```

配置基础环境
======

```shell
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
fs.may_detach_mounts = 1
vm.overcommit_memory=1
vm.panic_on_oom=0
fs.inotify.max_user_watches=89100
fs.file-max=52706963
fs.nr_open=52706963
net.netfilter.nf_conntrack_max=2310720


net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.tcp_keepalive_intvl =15
net.ipv4.tcp_max_tw_buckets = 36000
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_max_orphans = 327680
net.ipv4.tcp_orphan_retries = 3
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.ip_conntrack_max = 65536
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_timestamps = 0
net.core.somaxconn = 16384


net.ipv6.conf.all.disable_ipv6 = 0
net.ipv6.conf.default.disable_ipv6 = 0
net.ipv6.conf.lo.disable_ipv6 = 0
net.ipv6.conf.all.forwarding = 1
EOF


modprobe br_netfilter

sudo sysctl --system


hostnamectl set-hostname k8s-master01
hostnamectl set-hostname k8s-node01
hostnamectl set-hostname k8s-node02


sed -ri 's/.*swap.*/#&/' /etc/fstab
swapoff -a && sysctl -w vm.swappiness=0

cat /etc/fstab


cat > /etc/hosts <<EOF
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

2408:8207:78ce:7561::21 k8s-master01
2408:8207:78ce:7561::22 k8s-node01
2408:8207:78ce:7561::23 k8s-node02

10.0.0.21 k8s-master01
10.0.0.22 k8s-node01
10.0.0.23 k8s-node02
EOF

```

初始化安装
=====

```shell
root@k8s-master01:~# kubeadm config images list --image-repository registry.cn-hangzhou.aliyuncs.com/chenby
registry.cn-hangzhou.aliyuncs.com/chenby/kube-apiserver:v1.24.0
registry.cn-hangzhou.aliyuncs.com/chenby/kube-controller-manager:v1.24.0
registry.cn-hangzhou.aliyuncs.com/chenby/kube-scheduler:v1.24.0
registry.cn-hangzhou.aliyuncs.com/chenby/kube-proxy:v1.24.0
registry.cn-hangzhou.aliyuncs.com/chenby/pause:3.7
registry.cn-hangzhou.aliyuncs.com/chenby/etcd:3.5.3-0
registry.cn-hangzhou.aliyuncs.com/chenby/coredns:v1.8.6

root@k8s-master01:~# vim kubeadm.yaml 
root@k8s-master01:~# cat kubeadm.yaml
apiVersion: kubeadm.k8s.io/v1beta3
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: "10.0.0.21"
  bindPort: 6443
nodeRegistration:
  taints:
  - effect: PreferNoSchedule
    key: node-role.kubernetes.io/master
---
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
kubernetesVersion: v1.24.0
imageRepository: registry.cn-hangzhou.aliyuncs.com/chenby
networking:
  podSubnet: 172.16.0.0/12,fc00::/48
  serviceSubnet: 10.96.0.0/12,fd00::/108
root@k8s-master01:~#


root@k8s-master01:~# 
root@k8s-master01:~# kubeadm init --config=kubeadm.yaml 
[init] Using Kubernetes version: v1.24.0
[preflight] Running pre-flight checks
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [k8s-master01 kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 10.0.0.21]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/ca" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [k8s-master01 localhost] and IPs [10.0.0.21 127.0.0.1 ::1]
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [k8s-master01 localhost] and IPs [10.0.0.21 127.0.0.1 ::1]
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Generating "sa" key and public key
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[kubeconfig] Writing "admin.conf" kubeconfig file
[kubeconfig] Writing "kubelet.conf" kubeconfig file
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
[kubeconfig] Writing "scheduler.conf" kubeconfig file
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Starting the kubelet
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
[control-plane] Creating static Pod manifest for "kube-scheduler"
[etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
[wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
[apiclient] All control plane components are healthy after 6.504341 seconds
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config" in namespace kube-system with the configuration for the kubelets in the cluster
[upload-certs] Skipping phase. Please see --upload-certs
[mark-control-plane] Marking the node k8s-master01 as control-plane by adding the labels: [node-role.kubernetes.io/control-plane node.kubernetes.io/exclude-from-external-load-balancers]
[mark-control-plane] Marking the node k8s-master01 as control-plane by adding the taints [node-role.kubernetes.io/master:PreferNoSchedule]
[bootstrap-token] Using token: lnodkp.3n8i4m33sqwg39w2
[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to get nodes
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] Configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] Configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
[kubelet-finalize] Updating "/etc/kubernetes/kubelet.conf" to point to a rotatable kubelet client certificate and key
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 10.0.0.21:6443 --token lnodkp.3n8i4m33sqwg39w2 \
    --discovery-token-ca-cert-hash sha256:0ed7e18ea2b49bb599bc45e72f764bbe034ef1dce47729f2722467c167754da8 
root@k8s-master01:~# 
root@k8s-master01:~#   mkdir -p $HOME/.kube
root@k8s-master01:~#   sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
root@k8s-master01:~#   sudo chown $(id -u):$(id -g) $HOME/.kube/config
root@k8s-master01:~# 




root@k8s-node01:~# kubeadm join 10.0.0.21:6443 --token qf3z22.qwtqieutbkik6dy4 \
> --discovery-token-ca-cert-hash sha256:2ade8c834a41cc1960993a600c89fa4bb86e3594f82e09bcd42633d4defbda0d
[preflight] Running pre-flight checks
[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Starting the kubelet
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.

root@k8s-node01:~# 


root@k8s-node02:~# kubeadm join 10.0.0.21:6443 --token qf3z22.qwtqieutbkik6dy4 \
> --discovery-token-ca-cert-hash sha256:2ade8c834a41cc1960993a600c89fa4bb86e3594f82e09bcd42633d4defbda0d
[preflight] Running pre-flight checks
[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Starting the kubelet
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.

root@k8s-node02:~# 

```

查看集群
====

```shell
root@k8s-master01:~# kubectl  get node
NAME           STATUS   ROLES           AGE    VERSION
k8s-master01   Ready    control-plane   111s   v1.24.0
k8s-node01     Ready    <none>          82s    v1.24.0
k8s-node02     Ready    <none>          92s    v1.24.0
root@k8s-master01:~# 
root@k8s-master01:~# 
root@k8s-master01:~# kubectl  get pod -A
NAMESPACE     NAME                                   READY   STATUS    RESTARTS   AGE
kube-system   coredns-bc77466fc-jxkpv                1/1     Running   0          83s
kube-system   coredns-bc77466fc-nrc9l                1/1     Running   0          83s
kube-system   etcd-k8s-master01                      1/1     Running   0          87s
kube-system   kube-apiserver-k8s-master01            1/1     Running   0          89s
kube-system   kube-controller-manager-k8s-master01   1/1     Running   0          87s
kube-system   kube-proxy-2lgrn                       1/1     Running   0          83s
kube-system   kube-proxy-69p9r                       1/1     Running   0          47s
kube-system   kube-proxy-g58m2                       1/1     Running   0          42s
kube-system   kube-scheduler-k8s-master01            1/1     Running   0          87s
root@k8s-master01:~# 

```

配置calico
========

```shell
wget https://raw.githubusercontent.com/cby-chen/Kubernetes/main/yaml/calico-ipv6.yaml

# vim calico-ipv6.yaml
# calico-config ConfigMap处
    "ipam": {
        "type": "calico-ipam",
        "assign_ipv4": "true",
        "assign_ipv6": "true"
    },
    - name: IP
      value: "autodetect"

    - name: IP6
      value: "autodetect"

    - name: CALICO_IPV4POOL_CIDR
      value: "172.16.0.0/16"

    - name: CALICO_IPV6POOL_CIDR
      value: "fc00::/48"

    - name: FELIX_IPV6SUPPORT
      value: "true"

kubectl  apply -f calico-ipv6.yaml 

```

测试IPV6
======

```shell
root@k8s-master01:~# cat cby.yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: chenby
spec:
  replicas: 3
  selector:
    matchLabels:
      app: chenby
  template:
    metadata:
      labels:
        app: chenby
    spec:
      containers:
      - name: chenby
        image: nginx
        resources:
          limits:
            memory: "128Mi"
            cpu: "500m"
        ports:
        - containerPort: 80

---
apiVersion: v1
kind: Service
metadata:
  name: chenby
spec:
  ipFamilyPolicy: PreferDualStack
  ipFamilies:
  - IPv6
  - IPv4
  type: NodePort
  selector:
    app: chenby
  ports:
  - port: 80
    targetPort: 80

kubectl  apply -f cby.yaml 

root@k8s-master01:~# kubectl  get pod 
NAME                      READY   STATUS    RESTARTS   AGE
chenby-57479d5997-6pfzg   1/1     Running   0          6m
chenby-57479d5997-jjwpk   1/1     Running   0          6m
chenby-57479d5997-pzrkc   1/1     Running   0          6m

root@k8s-master01:~# kubectl  get svc
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)        AGE
chenby       NodePort    fd00::f816   <none>        80:30265/TCP   6m7s
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP        168m

root@k8s-master01:~# curl -I http://[2408:8207:78ce:7561::21]:30265/
HTTP/1.1 200 OK
Server: nginx/1.21.6
Date: Wed, 11 May 2022 07:01:43 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Tue, 25 Jan 2022 15:03:52 GMT
Connection: keep-alive
ETag: "61f01158-267"
Accept-Ranges: bytes

root@k8s-master01:~# curl -I http://10.0.0.21:30265/
HTTP/1.1 200 OK
Server: nginx/1.21.6
Date: Wed, 11 May 2022 07:01:54 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Tue, 25 Jan 2022 15:03:52 GMT
Connection: keep-alive
ETag: "61f01158-267"
Accept-Ranges: bytes

```

> https://www.oiox.cn/
> 
> https://www.chenby.cn/
> 
> https://blog.oiox.cn/
> 
> https://cby-chen.github.io/
> 
> https://blog.csdn.net/qq\_33921750
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
