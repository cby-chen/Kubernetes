# 修复kube-proxy证书权限过大问题



之前kube-proxy服务都是用admin集群证书，造成权限过大不安全，后续该问题，将在文档中修复

请关注 https://github.com/cby-chen/Kubernetes



## 创建生成证书配置文件

```shell
详细见：https://github.com/cby-chen/Kubernetes#23%E5%88%9B%E5%BB%BA%E8%AF%81%E4%B9%A6%E7%9B%B8%E5%85%B3%E6%96%87%E4%BB%B6

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
```



## 生成 CA 证书和私钥

```shell
cfssl gencert \
   -ca=/etc/kubernetes/pki/ca.pem \
   -ca-key=/etc/kubernetes/pki/ca-key.pem \
   -config=ca-config.json \
   -profile=kubernetes \
   kube-proxy-csr.json | cfssljson -bare /etc/kubernetes/pki/kube-proxy




ll /etc/kubernetes/pki/kube-proxy*
-rw-r--r-- 1 root root 1045 May 26 10:21 /etc/kubernetes/pki/kube-proxy.csr
-rw------- 1 root root 1675 May 26 10:21 /etc/kubernetes/pki/kube-proxy-key.pem
-rw-r--r-- 1 root root 1464 May 26 10:21 /etc/kubernetes/pki/kube-proxy.pem
```

设置集群参数和客户端认证参数时 --embed-certs 都为 true，这会将 certificate-authority、client-certificate 和 client-key 指向的证书文件内容写入到生成的 kube-proxy.kubeconfig 文件中；

kube-proxy.pem 证书中 CN 为 system:kube-proxy，kube-apiserver 预定义的 RoleBinding cluster-admin 将User system:kube-proxy 与 Role system:node-proxier 绑定，该 Role 授予了调用 kube-apiserver Proxy 相关 API 的权限；



## 创建 kubeconfig 文件

```shell
kubectl config set-cluster kubernetes     \
  --certificate-authority=/etc/kubernetes/pki/ca.pem     \
  --embed-certs=true     \
  --server=https://10.0.0.89:8443     \
  --kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig

kubectl config set-credentials kube-proxy  \
  --client-certificate=/etc/kubernetes/pki/kube-proxy.pem     \
  --client-key=/etc/kubernetes/pki/kube-proxy-key.pem     \
  --embed-certs=true     \
  --kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig

kubectl config set-context kube-proxy@kubernetes    \
  --cluster=kubernetes     \
  --user=kube-proxy     \
  --kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig

kubectl config use-context kube-proxy@kubernetes  --kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig
```



## 无法访问 pod资源

```shell
[cby@k8s-master01 ~]$ kubectl  get pod 
Error from server (Forbidden): pods is forbidden: User "system:kube-proxy" cannot list resource "pods" in API group "" in the namespace "default"
[cby@k8s-master01 ~]$ 
```



## 可以访问 node资源

```shell
[cby@k8s-master01 ~]$ kubectl  get node
NAME           STATUS   ROLES    AGE     VERSION
k8s-master01   Ready    <none>   2d21h   v1.24.0
k8s-master02   Ready    <none>   2d21h   v1.24.0
k8s-master03   Ready    <none>   2d21h   v1.24.0
k8s-node01     Ready    <none>   2d21h   v1.24.0
k8s-node02     Ready    <none>   2d21h   v1.24.0
[cby@k8s-master01 ~]$ 

```



## 将配置进行替换

```shell
for NODE in k8s-master02 k8s-master03; do scp /etc/kubernetes/kube-proxy.kubeconfig $NODE:/etc/kubernetes/kube-proxy.kubeconfig; done

for NODE in k8s-node01 k8s-node02; do scp /etc/kubernetes/kube-proxy.kubeconfig $NODE:/etc/kubernetes/kube-proxy.kubeconfig;  done

[root@k8s-master01 ~]# cat /etc/kubernetes/kube-proxy.yaml 
apiVersion: kubeproxy.config.k8s.io/v1alpha1
bindAddress: 0.0.0.0
clientConnection:
  acceptContentTypes: ""
  burst: 10
  contentType: application/vnd.kubernetes.protobuf
  kubeconfig: /etc/kubernetes/kube-proxy.kubeconfig
  qps: 5
clusterCIDR: 172.16.0.0/12,fc00:2222::/112 
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

[root@k8s-master01 ~]# systemctl  restart kube-proxy
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
