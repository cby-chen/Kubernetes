背景
==

如今IPv4IP地址已经使用完毕，未来全球会以IPv6地址为中心，会大力发展IPv6网络环境，由于IPv6可以实现给任何一个设备分配到公网IP，所以资源是非常丰富的。


配置hosts
=======

```shell
[root@k8s-master01 ~]# vim /etc/hosts
[root@k8s-master01 ~]# cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
2408:8207:78ce:7561::10 k8s-master01
2408:8207:78ce:7561::20 k8s-master02
2408:8207:78ce:7561::30 k8s-master03
2408:8207:78ce:7561::40 k8s-node01
2408:8207:78ce:7561::50 k8s-node02
2408:8207:78ce:7561::60 k8s-node03
2408:8207:78ce:7561::70 k8s-node04
2408:8207:78ce:7561::80 k8s-node05

10.0.0.81 k8s-master01
10.0.0.82 k8s-master02
10.0.0.83 k8s-master03
10.0.0.84 k8s-node01
10.0.0.85 k8s-node02
10.0.0.86 k8s-node03
10.0.0.87 k8s-node04
10.0.0.88 k8s-node05
10.0.0.80 lb01
10.0.0.90 lb02
10.0.0.99 lb-vip

[root@k8s-master01 ~]# 

```

配置ipv6地址
========

```shell
[root@k8s-master01 ~]# vim /etc/sysconfig/network-scripts/ifcfg-ens160 
[root@k8s-master01 ~]# cat /etc/sysconfig/network-scripts/ifcfg-ens160
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=none
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=no
IPV6ADDR=2408:8207:78ce:7561::10/64
IPV6_DEFAULTGW=2408:8207:78ce:7561::1
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
NAME=ens160
UUID=56ca7c8c-21c6-484f-acbd-349111b3ddb5
DEVICE=ens160
ONBOOT=yes
IPADDR=10.0.0.81
PREFIX=24
GATEWAY=10.0.0.1
DNS1=8.8.8.8
DNS2=2408:8000:1010:1::8
[root@k8s-master01 ~]# 

```

注意：每一台主机都需要配置为静态IPv6地址！若不进行配置，在内核中开启IPv6数据包转发功能后会出现IPv6异常。

sysctl参数启用ipv6
==============

```shell
[root@k8s-master01 ~]# vim /etc/sysctl.d/k8s.conf
[root@k8s-master01 ~]# cat /etc/sysctl.d/k8s.conf
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


net.ipv6.conf.all.disable_ipv6 = 0
net.ipv6.conf.default.disable_ipv6 = 0
net.ipv6.conf.lo.disable_ipv6 = 0
net.ipv6.conf.all.forwarding = 0

[root@k8s-master01 ~]# 
[root@k8s-master01 ~]# reboot

```

测试访问公网IPv6
==========

```shell
[root@k8s-master01 ~]# ping www.chenby.cn -6
PING www.chenby.cn(2408:871a:5100:119:1d:: (2408:871a:5100:119:1d::)) 56 data bytes
64 bytes from 2408:871a:5100:119:1d:: (2408:871a:5100:119:1d::): icmp_seq=1 ttl=53 time=10.6 ms
64 bytes from 2408:871a:5100:119:1d:: (2408:871a:5100:119:1d::): icmp_seq=2 ttl=53 time=9.94 ms
^C
--- www.chenby.cn ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1002ms
rtt min/avg/max/mdev = 9.937/10.269/10.602/0.347 ms
[root@k8s-master01 ~]# 

```

修改kube-apiserver如下配置
====================

```shell
--service-cluster-ip-range=10.96.0.0/12,fd00:1111::/112  
--feature-gates=IPv6DualStack=true 

[root@k8s-master01 ~]# vim /usr/lib/systemd/system/kube-apiserver.service
[root@k8s-master01 ~]# cat /usr/lib/systemd/system/kube-apiserver.service

[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes
After=network.target

[Service]
ExecStart=/usr/local/bin/kube-apiserver \
      --v=2  \
      --logtostderr=true  \
      --allow-privileged=true  \
      --bind-address=0.0.0.0  \
      --secure-port=6443  \
      --insecure-port=0  \
      --advertise-address=192.168.1.81 \
      --service-cluster-ip-range=10.96.0.0/12,fd00:1111::/112  \
      --feature-gates=IPv6DualStack=true \
      --service-node-port-range=30000-32767  \
      --etcd-servers=https://192.168.1.81:2379,https://192.168.1.82:2379,https://192.168.1.83:2379 \
      --etcd-cafile=/etc/etcd/ssl/etcd-ca.pem  \
      --etcd-certfile=/etc/etcd/ssl/etcd.pem  \
      --etcd-keyfile=/etc/etcd/ssl/etcd-key.pem  \
      --client-ca-file=/etc/kubernetes/pki/ca.pem  \
      --tls-cert-file=/etc/kubernetes/pki/apiserver.pem  \
      --tls-private-key-file=/etc/kubernetes/pki/apiserver-key.pem  \
      --kubelet-client-certificate=/etc/kubernetes/pki/apiserver.pem  \
      --kubelet-client-key=/etc/kubernetes/pki/apiserver-key.pem  \
      --service-account-key-file=/etc/kubernetes/pki/sa.pub  \
      --service-account-signing-key-file=/etc/kubernetes/pki/sa.key  \
      --service-account-issuer=https://kubernetes.default.svc.cluster.local \
      --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname  \
      --enable-admission-plugins=NamespaceLifecycle,LimitRanger,ServiceAccount,DefaultStorageClass,DefaultTolerationSeconds,NodeRestriction,ResourceQuota  \
      --authorization-mode=Node,RBAC  \
      --enable-bootstrap-token-auth=true  \
      --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.pem  \
      --proxy-client-cert-file=/etc/kubernetes/pki/front-proxy-client.pem  \
      --proxy-client-key-file=/etc/kubernetes/pki/front-proxy-client-key.pem  \
      --requestheader-allowed-names=aggregator  \
      --requestheader-group-headers=X-Remote-Group  \
      --requestheader-extra-headers-prefix=X-Remote-Extra-  \
      --requestheader-username-headers=X-Remote-User \
      --enable-aggregator-routing=true
      # --token-auth-file=/etc/kubernetes/token.csv

Restart=on-failure
RestartSec=10s
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target

```

修改kube-controller-manager如下配置
====================

```shell
--feature-gates=IPv6DualStack=true
--service-cluster-ip-range=10.96.0.0/12,fd00:1111::/112
--cluster-cidr=172.16.0.0/12,fc00:2222::/112
--node-cidr-mask-size-ipv4=24
--node-cidr-mask-size-ipv6=64

[root@k8s-master01 ~]# vim /usr/lib/systemd/system/kube-controller-manager.service
[root@k8s-master01 ~]# cat /usr/lib/systemd/system/kube-controller-manager.service
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/kubernetes/kubernetes
After=network.target

[Service]
ExecStart=/usr/local/bin/kube-controller-manager \
      --v=2 \
      --logtostderr=true \
      --address=127.0.0.1 \
      --root-ca-file=/etc/kubernetes/pki/ca.pem \
      --cluster-signing-cert-file=/etc/kubernetes/pki/ca.pem \
      --cluster-signing-key-file=/etc/kubernetes/pki/ca-key.pem \
      --service-account-private-key-file=/etc/kubernetes/pki/sa.key \
      --kubeconfig=/etc/kubernetes/controller-manager.kubeconfig \
      --leader-elect=true \
      --use-service-account-credentials=true \
      --node-monitor-grace-period=40s \
      --node-monitor-period=5s \
      --pod-eviction-timeout=2m0s \
      --controllers=*,bootstrapsigner,tokencleaner \
      --allocate-node-cidrs=true \
      --feature-gates=IPv6DualStack=true \
      --service-cluster-ip-range=10.96.0.0/12,fd00:1111::/112 \
      --cluster-cidr=172.16.0.0/12,fc00:2222::/112 \
      --node-cidr-mask-size-ipv4=24 \
      --node-cidr-mask-size-ipv6=64 \
      --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.pem 

Restart=always
RestartSec=10s

[Install]
WantedBy=multi-user.target

```

修改kubelet如下配置
=============

```shell
--feature-gates=IPv6DualStack=true

[root@k8s-master01 ~]# vim /usr/lib/systemd/system/kubelet.service
[root@k8s-master01 ~]# cat /usr/lib/systemd/system/kubelet.service
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=docker.service
Requires=docker.service

[Service]
ExecStart=/usr/local/bin/kubelet \
    --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.kubeconfig  \
    --kubeconfig=/etc/kubernetes/kubelet.kubeconfig \
    --config=/etc/kubernetes/kubelet-conf.yml \
    --network-plugin=cni  \
    --cni-conf-dir=/etc/cni/net.d  \
    --cni-bin-dir=/opt/cni/bin  \
    --container-runtime=remote  \
    --runtime-request-timeout=15m  \
    --container-runtime-endpoint=unix:///run/containerd/containerd.sock  \
    --cgroup-driver=systemd \
    --node-labels=node.kubernetes.io/node='' \
    --feature-gates=IPv6DualStack=true

Restart=always
StartLimitInterval=0
RestartSec=10

[Install]
WantedBy=multi-user.target

```

修改kube-proxy如下配置
====================

```shell
#修改如下配置
clusterCIDR: 172.16.0.0/12,fc00:2222::/112 

[root@k8s-master01 ~]# vim /etc/kubernetes/kube-proxy.yaml
[root@k8s-master01 ~]# cat /etc/kubernetes/kube-proxy.yaml
apiVersion: kubeproxy.config.k8s.io/v1alpha1
bindAddress: 0.0.0.0
clientConnection:
  acceptContentTypes: ""
  burst: 10
  contentType: application/vnd.kubernetes.protobuf
  kubeconfig: /etc/kubernetes/kube-proxy.kubeconfig
  qps: 5
clusterCIDR: 172.16.0.0/12,fc00:2222::/112 
configSyncPeriod: 15m0s
conntrack:
  max: null
  maxPerCore: 32768
  min: 131072
  tcpCloseWaitTimeout: 1h0m0s
  tcpEstablishedTimeout: 24h0m0s
enableProfiling: false
healthzBindAddress: 0.0.0.0:10256
hostnameOverride: ""
iptables:
  masqueradeAll: false
  masqueradeBit: 14
  minSyncPeriod: 0s
  syncPeriod: 30s
ipvs:
  masqueradeAll: true
  minSyncPeriod: 5s
  scheduler: "rr"
  syncPeriod: 30s
kind: KubeProxyConfiguration
metricsBindAddress: 127.0.0.1:10249
mode: "ipvs"
nodePortAddresses: null
oomScoreAdj: -999
portRange: ""
udpIdleTimeout: 250ms
[root@k8s-master01 ~]# 

```

修改calico如下配置
============

```shell
# vim calico.yaml
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
      value: "172.16.0.0/12"

    - name: CALICO_IPV6POOL_CIDR
      value: "fc00::/48"

    - name: FELIX_IPV6SUPPORT
      value: "true"
# kubectl apply -f calico.yaml

```

测试
==

```shell
#部署应用
[root@k8s-master01 ~]# cat cby.yaml 
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
[root@k8s-master01 ~]# kubectl  apply -f cby.yaml

#查看端口
[root@k8s-master01 ~]# kubectl  get svc
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)        AGE
chenby       NodePort    fd00::d80a   <none>        80:31535/TCP   54s
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP        22h
[root@k8s-master01 ~]# 

#使用内网访问
[root@k8s-master01 ~]# curl -I http://[fd00::d80a]
HTTP/1.1 200 OK
Server: nginx/1.21.6
Date: Fri, 29 Apr 2022 07:29:28 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Tue, 25 Jan 2022 15:03:52 GMT
Connection: keep-alive
ETag: "61f01158-267"
Accept-Ranges: bytes

[root@k8s-master01 ~]# 

#使用公网访问
[root@k8s-master01 ~]# curl -I http://[2408:8207:78ce:7561::10]:31535
HTTP/1.1 200 OK
Server: nginx/1.21.6
Date: Fri, 29 Apr 2022 07:25:16 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Tue, 25 Jan 2022 15:03:52 GMT
Connection: keep-alive
ETag: "61f01158-267"
Accept-Ranges: bytes

[root@k8s-master01 ~]# 

[root@k8s-master01 ~]# curl -I http://10.0.0.81:31535
HTTP/1.1 200 OK
Server: nginx/1.21.6
Date: Fri, 29 Apr 2022 07:26:16 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Tue, 25 Jan 2022 15:03:52 GMT
Connection: keep-alive
ETag: "61f01158-267"
Accept-Ranges: bytes

[root@k8s-master01 ~]# 

```

  

  

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d8de32581aaf4257987ed41a29ed55e4~tplv-k3u1fbpfcp-zoom-1.image)

  

  

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
