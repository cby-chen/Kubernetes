# kubernetes (k8s) 二进制高可用安装

[Kubernetes](https://github.com/cby-chen/Kubernetes) 开源不易，帮忙点个star，谢谢了🌹

GitHub访问不通畅可以访问国内GitEE https://gitee.com/cby-inc/Kubernetes

##  ⚠️ 中国大陆地区 Docker 以及其他仓库镜像已被 GFW 完全封锁！！！
##  ⚠️ 现镜像已无法直接拉取，需要通过一些特殊方式进行！！！

# 一、写在前面

打开文档，使用全文替换，全局替换主机IP即可。

各位仁兄，手动方式部署，没必要折磨自己。

能用自动部署就用自动部署吧。推荐：https://github.com/easzlab/kubeasz

# 二、介绍

我使用IPV6的目的是在公网进行访问，所以我配置了IPV6静态地址。
若您没有IPV6环境，或者不想使用IPv6，不对主机进行配置IPv6地址即可。
不配置IPV6，不影响后续，不过集群依旧是支持IPv6的。为后期留有扩展可能性。
若不要IPv6 ，不给网卡配置IPv6即可，不要对IPv6相关配置删除或操作，否则会出问题。
如果本地没有IPv6，那么Calico需要使用IPv4的yaml配置文件。
后续尽可能第一时间更新新版本文档，更新后内容在GitHub。

不要删除 IPv6 相关配置！！！

不要删除 IPv6 相关配置！！！

不要删除 IPv6 相关配置！！！

# 三、当前文档版本

- 1.21.x
- 1.22.x
- 1.23.x
- 1.24.x
- 1.25.x
- 1.26.x
- 1.27.x
- 1.28.x
- 1.29.x
- 1.30.x

大版本之间是通用的，比如使用 1.26.0 的文档可以安装 1.26.x 各种版本，只是安装过程中的下载新的包即可。

# 四、访问地址

手动项目地址：  
https://github.com/cby-chen/Kubernetes

脚本项目地址（已停更）：  
https://github.com/cby-chen/Binary_installation_of_Kubernetes  
https://github.com/cby-chen/kube_ansible  

# 五、文档

### 最新版本文档
- [kubeadm-install.md](./doc/kubeadm-install.md)
- [v1.30.1-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves-Offline.md](./doc/v1.30.1-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves-Offline.md)

## 安装文档
###  1.29.x版本
- [v1.29.2-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves-Offline.md](./doc/v1.29.2-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves-Offline.md)

###  1.28.x版本
- [v1.28.0-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves-Offline.md](./doc/v1.28.0-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves-Offline.md)
- [v1.28.3-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves-Offline.md](./doc/v1.28.3-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves-Offline.md)

###  1.27.x版本
- [v1.27.1-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves-Offline.md](./doc/v1.27.1-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves-Offline.md)
- [v1.27.3-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves-Offline.md](./doc/v1.27.3-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves-Offline.md)

###  1.26.x版本
- [v1.26.0-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md](./doc/v1.26.0-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md)
- [v1.26.1-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves-Offline.md](./doc/v1.26.1-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves-Offline.md)

###  1.25.x版本
- [v1.25.0-CentOS-binary-install-IPv6-IPv4.md](./doc/v1.25.0-CentOS-binary-install-IPv6-IPv4.md)
- [v1.25.4-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md](./doc/v1.25.4-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md)

###  1.24.x版本
- [v1.24.0-CentOS-binary-install-IPv6-IPv4.md](./doc/v1.24.0-CentOS-binary-install-IPv6-IPv4.md)
- [v1.24.1-CentOS-binary-install-IPv6-IPv4.md](./doc/v1.24.1-CentOS-binary-install-IPv6-IPv4.md)
- [v1.24.2-CentOS-binary-install-IPv6-IPv4.md](./doc/v1.24.2-CentOS-binary-install-IPv6-IPv4.md)
- [v1.24.3-CentOS-binary-install-IPv6-IPv4.md](./doc/v1.24.3-CentOS-binary-install-IPv6-IPv4.md)

###  1.23.x版本
- [v1.23.3-CentOS-binary-install](./doc/v1.23.3-CentOS-binary-install.md)
- [v1.23.4-CentOS-binary-install](./doc/v1.23.4-CentOS-binary-install.md)
- [v1.23.5-CentOS-binary-install](./doc/v1.23.5-CentOS-binary-install.md)
- [v1.23.6-CentOS-binary-install](./doc/v1.23.6-CentOS-binary-install.md)

###  1.22.x版本
- [v1.22.10-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md](./doc/v1.22.10-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md)

###  1.21.x版本
- [v1.21.13-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md](./doc/v1.21.13-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md)

###  三主俩从版本
- [v1.21.13-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md](./doc/v1.21.13-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md)
- [v1.22.10-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md](./doc/v1.22.10-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md)
- [v1.23.7-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md](./doc/v1.23.7-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md)
- [v1.24.0-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md](./doc/v1.24.0-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md)
- [v1.24.1-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md](./doc/v1.24.1-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md)
- [v1.24.1-Ubuntu-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md](./doc/v1.24.1-Ubuntu-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md)
- [v1.25.0-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md](./doc/v1.25.0-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md)
- [v1.25.4-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md](./doc/v1.25.4-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md)
- [v1.26.0-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md](./doc/v1.26.0-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md)

## 其他文档
-  修复kube-proxy证书权限过大问题 [kube-proxy_permissions.md](./doc/kube-proxy_permissions.md)
-  使用kubeadm初始化IPV4/IPV6集群 [kubeadm-install-IPV6-IPV4.md](./doc/kubeadm-install-IPV6-IPV4.md)
-  IPv4集群启用IPv6功能，关闭IPv6则反之 [Enable-implement-IPv4-IPv6.md](./doc/Enable-implement-IPv4-IPv6.md)
-  升级kubernetes集群 [Upgrade_Kubernetes.md](./doc/Upgrade_Kubernetes.md)  
-  Minikube初始化集群 [Minikube_init.md](./doc/Minikube_init.md)  
-  Kubernetes 1.24 1.25 集群使用docker作为容器 [Kubernetes_docker](./doc/Kubernetes_docker.md)
-  kubernetes 安装cilium [kubernetes_install_cilium](./doc/kubernetes_install_cilium.md)
-  二进制安装每个版本文档

# 六、安装包

- 123云盘 https://www.123pan.com/s/Z8ArVv-PG60d
- 夸克云盘 https://pan.quark.cn/s/450ef6406f30

- https://github.com/cby-chen/Kubernetes/releases
- wget https://mirrors.chenby.cn/https://github.com/cby-chen/Kubernetes/releases/download/v1.22.10/kubernetes-v1.22.10.tar
- wget https://mirrors.chenby.cn/https://github.com/cby-chen/Kubernetes/releases/download/v1.21.13/kubernetes-v1.21.13.tar  
- wget https://mirrors.chenby.cn/https://github.com/cby-chen/Kubernetes/releases/download/cby/Kubernetes.tar
- wget https://mirrors.chenby.cn/https://github.com/cby-chen/Kubernetes/releases/download/v1.23.4/kubernetes-v1.23.4.tar
- wget https://mirrors.chenby.cn/https://github.com/cby-chen/Kubernetes/releases/download/v1.23.5/kubernetes-v1.24.5.tar
- wget https://mirrors.chenby.cn/https://github.com/cby-chen/Kubernetes/releases/download/v1.23.6/kubernetes-v1.23.6.tar
- wget https://mirrors.chenby.cn/https://github.com/cby-chen/Kubernetes/releases/download/v1.23.7/kubernetes-v1.23.7.tar
- wget https://mirrors.chenby.cn/https://github.com/cby-chen/Kubernetes/releases/download/v1.24.0/kubernetes-v1.24.0.tar
- wget https://mirrors.chenby.cn/https://github.com/cby-chen/Kubernetes/releases/download/v1.24.1/kubernetes-v1.24.1.tar
- wget https://mirrors.chenby.cn/https://github.com/cby-chen/Kubernetes/releases/download/v1.24.2/kubernetes-v1.24.2.tar
- wget https://mirrors.chenby.cn/https://github.com/cby-chen/Kubernetes/releases/download/v1.24.3/kubernetes-v1.24.3.tar
- wget https://mirrors.chenby.cn/https://github.com/cby-chen/Kubernetes/releases/download/v1.25.0/kubernetes-v1.25.0.tar
- wget https://mirrors.chenby.cn/https://github.com/cby-chen/Kubernetes/releases/download/v1.25.4/kubernetes-v1.25.4.tar
- wget https://mirrors.chenby.cn/https://github.com/cby-chen/Kubernetes/releases/download/v1.26.0/kubernetes-v1.26.0.tar
- wget https://mirrors.chenby.cn/https://github.com/cby-chen/Kubernetes/releases/download/v1.26.1/kubernetes-v1.26.1.tar
- wget https://mirrors.chenby.cn/https://github.com/cby-chen/Kubernetes/releases/download/v1.27.1/kubernetes-v1.27.1.tar
- wget https://mirrors.chenby.cn/https://github.com/cby-chen/Kubernetes/releases/download/v1.27.3/kubernetes-v1.27.3.tar
- wget https://mirrors.chenby.cn/https://github.com/cby-chen/Kubernetes/releases/download/v1.28.0/kubernetes-v1.28.0.tar
- wget https://mirrors.chenby.cn/https://github.com/cby-chen/Kubernetes/releases/download/v1.28.3/kubernetes-v1.28.3.tar
- wget https://mirrors.chenby.cn/https://github.com/cby-chen/Kubernetes/releases/download/v1.29.2/kubernetes-v1.29.2.tar
- wget https://mirrors.chenby.cn/https://github.com/cby-chen/Kubernetes/releases/download/v1.30.1/kubernetes-v1.30.1.tar

*注意：1.23.3 版本当时没想到会后续更新，所以当时命名不太规范。

# 七、旧版本地址

建议查看main版本中的文档。  
https://github.com/cby-chen/Kubernetes/  
若找对应版本文档中的安装包，可以在上方下载安装包，可以在在下方地址中查找。

- https://github.com/cby-chen/Kubernetes/tree/v1.22.10
- https://github.com/cby-chen/Kubernetes/tree/v1.21.13
- https://github.com/cby-chen/Kubernetes/tree/cby
- https://github.com/cby-chen/Kubernetes/tree/v1.23.4
- https://github.com/cby-chen/Kubernetes/tree/v1.23.5
- https://github.com/cby-chen/Kubernetes/tree/v1.23.6
- https://github.com/cby-chen/Kubernetes/tree/v1.23.7
- https://github.com/cby-chen/Kubernetes/tree/v1.24.0
- https://github.com/cby-chen/Kubernetes/tree/v1.24.1
- https://github.com/cby-chen/Kubernetes/tree/v1.24.2
- https://github.com/cby-chen/Kubernetes/tree/v1.24.3
- https://github.com/cby-chen/Kubernetes/tree/v1.25.0
- https://github.com/cby-chen/Kubernetes/tree/v1.25.4
- https://github.com/cby-chen/Kubernetes/tree/v1.26.0
- https://github.com/cby-chen/Kubernetes/tree/v1.26.1
- https://github.com/cby-chen/Kubernetes/tree/v1.27.1
- https://github.com/cby-chen/Kubernetes/tree/v1.27.3
- https://github.com/cby-chen/Kubernetes/tree/v1.28.0
- https://github.com/cby-chen/Kubernetes/tree/v1.28.3
- https://github.com/cby-chen/Kubernetes/tree/v1.29.2
- https://github.com/cby-chen/Kubernetes/tree/v1.30.1

# 八、常见异常

-  注意hosts配置文件中主机名和IP地址对应

-  在文档7.2，却记别忘记执行`kubectl create -f bootstrap.secret.yaml`命令

-  重启服务器之后出现异常，可以查看`systemctl status kubelet.service`服务是否正常

-  在 centos7 环境下需要升级 runc 和 libseccomp 
详见 https://github.com/cby-chen/Kubernetes/blob/main/doc/v1.25.0-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md#9%E5%AE%89%E8%A3%85%E7%BD%91%E7%BB%9C%E6%8F%92%E4%BB%B6

- 安装会出现kubelet异常，无法识别 `--node-labels` 字段问题，原因如下。
将 `--node-labels=node.kubernetes.io/node=''` 替换为 `--node-labels=node.kubernetes.io/node=`  将 `''` 删除即可。

-  IPv6无法正常访问，kubelet服务需要添加`--node-ip=`参数，若动态获取IP地址变动之后需要重新配置，详细查看文档 https://github.com/cby-chen/Kubernetes/blob/main/doc/v1.28.3-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves-Offline.md#82kubelet%E9%85%8D%E7%BD%AE

# 九、其他

## 生产环境推荐配置

###	Master节点：
- 三个节点实现高可用（必须）
- 节点数：0-100    8核16+
- 节点数：100-250  8核32G+
- 节点数：250-500  16核32G+
  
###	etcd节点：
- 三个节点实现高可用（必须），有条件存储分区必须高性能SSD硬盘，没有SSD也要有高效独立磁盘
- 节点数：0-50    2核8G+   50G SSD存储
- 节点数：50-250  4核16G+  150G SSD存储
- 节点数：250-1000  8核32G+ 250G SSD存储
  
###	Node节点：
- 无特殊要求，主要是Docker数据分区、系统分区需要单独使用，不可以使用同一个磁盘，系统分区100G+、Docker数据分区200G+，有条件使用SSD硬盘，必须独立于系统盘

###	其他：
- 集群规模不大可以将etcd和master放置于同一个宿主机，
- 也就是每个master节点部署k8s组件和etcd服务，但是etcd的数据目录一定要独立，并且使用SSD，
- 两者部署在一起需要相对增加宿主机的资源，个人建议生产环境把master节点的资源一次性给够，
- 此处的费用不应该节省，可以直接使用16核32G或者64G的机器，之后集群扩容就无需扩容master节点的资源，减少风险。
- 其中master节点和etcd节点的系统分区100G即可。

### 添加好友
<img src=./images/1.jpg width=30% />

### 打赏
<img src=./images/3.jpg width=30% />

- 建议在 [Kubernetes](https://github.com/cby-chen/Kubernetes) 查看文档，后续会陆续更新文档
- 小陈网站：

> https://www.oiox.cn/
>
> https://www.oiox.cn/index.php/start-page.html
>
> **CSDN、GitHub、51CTO、知乎、开源中国、思否、掘金、简书、华为云、阿里云、腾讯云、哔哩哔哩、今日头条、新浪微博、个人博客**
>
> **全网可搜《小陈运维》**
>
> **文章主要发布于微信公众号**


## Stargazers over time

[![Stargazers over time](https://starchart.cc/cby-chen/Kubernetes.svg)](https://starchart.cc/cby-chen/Kubernetes)
