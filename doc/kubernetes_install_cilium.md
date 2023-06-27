## kubernetes 安装cilium

### Cilium介绍
Cilium是一个开源软件，用于透明地提供和保护使用Kubernetes，Docker和Mesos等Linux容器管理平台部署的应用程序服务之间的网络和API连接。

Cilium基于一种名为BPF的新Linux内核技术，它可以在Linux内部动态插入强大的安全性，可见性和网络控制逻辑。 除了提供传统的网络级安全性之外，BPF的灵活性还可以在API和进程级别上实现安全性，以保护容器或容器内的通信。由于BPF在Linux内核中运行，因此可以应用和更新Cilium安全策略，而无需对应用程序代码或容器配置进行任何更改。


### 1 安装helm

```shell
[root@k8s-master01 ~]# curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
[root@k8s-master01 ~]# chmod 700 get_helm.sh
[root@k8s-master01 ~]# ./get_helm.sh
```

### 2 安装cilium

```shell
[root@k8s-master01 ~]# helm repo add cilium https://helm.cilium.io
[root@k8s-master01 ~]# helm install cilium cilium/cilium    --namespace kube-system    --set hubble.relay.enabled=true     --set hubble.ui.enabled=true    --set prometheus.enabled=true    --set operator.prometheus.enabled=true    --set hubble.enabled=true    --set hubble.metrics.enabled="{dns,drop,tcp,flow,port-distribution,icmp,http}"

NAME: cilium
LAST DEPLOYED: Sun Sep 11 00:04:30 2022
NAMESPACE: kube-system
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
You have successfully installed Cilium with Hubble.

Your release version is 1.12.1.

For any further help, visit https://docs.cilium.io/en/v1.12/gettinghelp
[root@k8s-master01 ~]#
```

### 3 查看

```shell
[root@k8s-master01 ~]# kubectl  get pod -A | grep cil
kube-system   cilium-gmr6c                       1/1     Running       0             5m3s
kube-system   cilium-kzgdj                       1/1     Running       0             5m3s
kube-system   cilium-operator-69b677f97c-6pw4k   1/1     Running       0             5m3s
kube-system   cilium-operator-69b677f97c-xzzdk   1/1     Running       0             5m3s
kube-system   cilium-q2rnr                       1/1     Running       0             5m3s
kube-system   cilium-smx5v                       1/1     Running       0             5m3s
kube-system   cilium-tdjq4                       1/1     Running       0             5m3s
[root@k8s-master01 ~]#
```

### 4 下载专属监控面板

```shell
[root@k8s-master01 yaml]# wget https://raw.githubusercontent.com/cilium/cilium/1.12.1/examples/kubernetes/addons/prometheus/monitoring-example.yaml
[root@k8s-master01 yaml]#
[root@k8s-master01 yaml]# kubectl  apply -f monitoring-example.yaml
namespace/cilium-monitoring created
serviceaccount/prometheus-k8s created
configmap/grafana-config created
configmap/grafana-cilium-dashboard created
configmap/grafana-cilium-operator-dashboard created
configmap/grafana-hubble-dashboard created
configmap/prometheus created
clusterrole.rbac.authorization.k8s.io/prometheus created
clusterrolebinding.rbac.authorization.k8s.io/prometheus created
service/grafana created
service/prometheus created
deployment.apps/grafana created
deployment.apps/prometheus created
[root@k8s-master01 yaml]#
```

### 5 下载部署测试用例

```shell
[root@k8s-master01 yaml]# wget https://raw.githubusercontent.com/cilium/cilium/master/examples/kubernetes/connectivity-check/connectivity-check.yaml

[root@k8s-master01 yaml]# sed -i "s#google.com#baidu.cn#g" connectivity-check.yaml

[root@k8s-master01 yaml]# kubectl  apply -f connectivity-check.yaml
deployment.apps/echo-a created
deployment.apps/echo-b created
deployment.apps/echo-b-host created
deployment.apps/pod-to-a created
deployment.apps/pod-to-external-1111 created
deployment.apps/pod-to-a-denied-cnp created
deployment.apps/pod-to-a-allowed-cnp created
deployment.apps/pod-to-external-fqdn-allow-google-cnp created
deployment.apps/pod-to-b-multi-node-clusterip created
deployment.apps/pod-to-b-multi-node-headless created
deployment.apps/host-to-b-multi-node-clusterip created
deployment.apps/host-to-b-multi-node-headless created
deployment.apps/pod-to-b-multi-node-nodeport created
deployment.apps/pod-to-b-intra-node-nodeport created
service/echo-a created
service/echo-b created
service/echo-b-headless created
service/echo-b-host-headless created
ciliumnetworkpolicy.cilium.io/pod-to-a-denied-cnp created
ciliumnetworkpolicy.cilium.io/pod-to-a-allowed-cnp created
ciliumnetworkpolicy.cilium.io/pod-to-external-fqdn-allow-google-cnp created
[root@k8s-master01 yaml]#
```

### 6 查看pod

```shell
[root@k8s-master01 yaml]# kubectl  get pod -A
NAMESPACE           NAME                                                     READY   STATUS    RESTARTS      AGE
cilium-monitoring   grafana-59957b9549-6zzqh                                 1/1     Running   0             10m
cilium-monitoring   prometheus-7c8c9684bb-4v9cl                              1/1     Running   0             10m
default             chenby-75b5d7fbfb-7zjsr                                  1/1     Running   0             27h
default             chenby-75b5d7fbfb-hbvr8                                  1/1     Running   0             27h
default             chenby-75b5d7fbfb-ppbzg                                  1/1     Running   0             27h
default             echo-a-6799dff547-pnx6w                                  1/1     Running   0             10m
default             echo-b-fc47b659c-4bdg9                                   1/1     Running   0             10m
default             echo-b-host-67fcfd59b7-28r9s                             1/1     Running   0             10m
default             host-to-b-multi-node-clusterip-69c57975d6-z4j2z          1/1     Running   0             10m
default             host-to-b-multi-node-headless-865899f7bb-frrmc           1/1     Running   0             10m
default             pod-to-a-allowed-cnp-5f9d7d4b9d-hcd8x                    1/1     Running   0             10m
default             pod-to-a-denied-cnp-65cc5ff97b-2rzb8                     1/1     Running   0             10m
default             pod-to-a-dfc64f564-p7xcn                                 1/1     Running   0             10m
default             pod-to-b-intra-node-nodeport-677868746b-trk2l            1/1     Running   0             10m
default             pod-to-b-multi-node-clusterip-76bbbc677b-knfq2           1/1     Running   0             10m
default             pod-to-b-multi-node-headless-698c6579fd-mmvd7            1/1     Running   0             10m
default             pod-to-b-multi-node-nodeport-5dc4b8cfd6-8dxmz            1/1     Running   0             10m
default             pod-to-external-1111-8459965778-pjt9b                    1/1     Running   0             10m
default             pod-to-external-fqdn-allow-google-cnp-64df9fb89b-l9l4q   1/1     Running   0             10m
kube-system         cilium-7rfj6                                             1/1     Running   0             56s
kube-system         cilium-d4cch                                             1/1     Running   0             56s
kube-system         cilium-h5x8r                                             1/1     Running   0             56s
kube-system         cilium-operator-5dbddb6dbf-flpl5                         1/1     Running   0             56s
kube-system         cilium-operator-5dbddb6dbf-gcznc                         1/1     Running   0             56s
kube-system         cilium-t2xlz                                             1/1     Running   0             56s
kube-system         cilium-z65z7                                             1/1     Running   0             56s
kube-system         coredns-665475b9f8-jkqn8                                 1/1     Running   1 (36h ago)   36h
kube-system         hubble-relay-59d8575-9pl9z                               1/1     Running   0             56s
kube-system         hubble-ui-64d4995d57-nsv9j                               2/2     Running   0             56s
kube-system         metrics-server-776f58c94b-c6zgs                          1/1     Running   1 (36h ago)   37h
[root@k8s-master01 yaml]#
```

### 7 修改为NodePort

```shell
[root@k8s-master01 yaml]# kubectl  edit svc  -n kube-system hubble-ui
service/hubble-ui edited
[root@k8s-master01 yaml]#
[root@k8s-master01 yaml]# kubectl  edit svc  -n cilium-monitoring grafana
service/grafana edited
[root@k8s-master01 yaml]#
[root@k8s-master01 yaml]# kubectl  edit svc  -n cilium-monitoring prometheus
service/prometheus edited
[root@k8s-master01 yaml]#

type: NodePort
```

### 8 查看端口

```shell
[root@k8s-master01 yaml]# kubectl get svc -A | grep monit
cilium-monitoring   grafana                NodePort    10.100.250.17    <none>        3000:30707/TCP           15m
cilium-monitoring   prometheus             NodePort    10.100.131.243   <none>        9090:31155/TCP           15m
[root@k8s-master01 yaml]#
[root@k8s-master01 yaml]# kubectl get svc -A | grep hubble
kube-system         hubble-metrics         ClusterIP   None             <none>        9965/TCP                 5m12s
kube-system         hubble-peer            ClusterIP   10.100.150.29    <none>        443/TCP                  5m12s
kube-system         hubble-relay           ClusterIP   10.109.251.34    <none>        80/TCP                   5m12s
kube-system         hubble-ui              NodePort    10.102.253.59    <none>        80:31219/TCP             5m12s
[root@k8s-master01 yaml]#
```

### 9 访问

```shell
http://192.168.1.61:30707
http://192.168.1.61:31155
http://192.168.1.61:31219
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
> **文章主要发布于微信公众号**