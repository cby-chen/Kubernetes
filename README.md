# kubernetes (k8s) 二进制高可用安装

[Kubernetes](https://github.com/cby-chen/Kubernetes) 开源不易，帮忙点个star，谢谢了🌹

GitHub访问不通畅可以访问国内GitEE https://gitee.com/cby-inc/Kubernetes

# 介绍

我使用IPV6的目的是在公网进行访问，所以我配置了IPV6静态地址。

若您没有IPV6环境，或者不想使用IPv6，不对主机进行配置IPv6地址即可。

不配置IPV6，不影响后续，不过集群依旧是支持IPv6的。为后期留有扩展可能性。

如果本地没有IPv6，那么Calico需要使用IPv4的yaml配置文件。

后续尽可能第一时间更新新版本文档，更新后内容在GitHub。

# 当前文档版本

- 1.21.x
- 1.22.x
- 1.23.x
- 1.24.x
- 1.25.x

大版本之间是通用的，比如使用 1.25.0 的文档可以安装 1.25.x 各种版本，只是安装过程中的下载新的包即可。

# 访问地址

手动项目地址：  
https://github.com/cby-chen/Kubernetes

脚本项目地址：  
https://github.com/cby-chen/Binary_installation_of_Kubernetes  
https://github.com/cby-chen/kube_ansible  

# 文档

### 最新版本文档
- [v1.25.0-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves](./doc/v1.25.0-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md)

## 安装文档

###  1.21.x版本
- [v1.21.13-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md](./doc/v1.21.13-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md)
###  1.22.x版本
- [v1.22.10-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md](./doc/v1.22.10-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md)

###  1.23.x版本
- [v1.23.3-CentOS-binary-install](./doc/v1.23.3-CentOS-binary-install.md)
- [v1.23.4-CentOS-binary-install](./doc/v1.23.4-CentOS-binary-install.md)
- [v1.23.5-CentOS-binary-install](./doc/v1.23.5-CentOS-binary-install.md)
- [v1.23.6-CentOS-binary-install](./doc/v1.23.6-CentOS-binary-install.md)

###  1.24.x版本
- [v1.24.0-CentOS-binary-install-IPv6-IPv4.md](./doc/v1.24.0-CentOS-binary-install-IPv6-IPv4.md)
- [v1.24.1-CentOS-binary-install-IPv6-IPv4.md](./doc/v1.24.1-CentOS-binary-install-IPv6-IPv4.md)
- [v1.24.2-CentOS-binary-install-IPv6-IPv4.md](./doc/v1.24.2-CentOS-binary-install-IPv6-IPv4.md)
- [v1.24.3-CentOS-binary-install-IPv6-IPv4.md](./doc/v1.24.3-CentOS-binary-install-IPv6-IPv4.md)

###  1.25.x版本
- [v1.25.0-CentOS-binary-install-IPv6-IPv4.md](./doc/v1.25.0-CentOS-binary-install-IPv6-IPv4.md)

###  三主俩从版本
- [v1.21.13-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md](./doc/v1.21.13-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md)
- [v1.22.10-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md](./doc/v1.22.10-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md)
- [v1.23.7-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md](./doc/v1.23.7-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md)
- [v1.24.0-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md](./doc/v1.24.0-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md)
- [v1.24.1-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md](./doc/v1.24.1-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md)
- [v1.24.1-Ubuntu-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md](./doc/v1.24.1-Ubuntu-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md)
- [v1.25.0-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md](./doc/v1.25.0-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md)

## 其他文档
-  修复kube-proxy证书权限过大问题 [kube-proxy_permissions.md](./doc/kube-proxy_permissions.md)
-  使用kubeadm初始化IPV4/IPV6集群 [kubeadm-install-IPV6-IPV4.md](./doc/kubeadm-install-IPV6-IPV4.md)
-  IPv4集群启用IPv6功能，关闭IPv6则反之 [Enable-implement-IPv4-IPv6.md](./doc/Enable-implement-IPv4-IPv6.md)
-  升级kubernetes集群 [Upgrade_Kubernetes.md](./doc/Upgrade_Kubernetes.md)  
-  Minikube初始化集群 [Minikube_init.md](./doc/Minikube_init.md)  
-  Kubernetes 1.24 1.25 集群使用docker作为容器 [Kubernetes_docker](./doc/Kubernetes_docker.md)
-  kubernetes 安装cilium [kubernetes_install_cilium](./doc/kubernetes_install_cilium.md)
-  二进制安装每个版本文档

# 安装包

- （下载更快）https://www.123pan.com/s/Z8ArVv-PG60d

- https://github.com/cby-chen/Kubernetes/releases

- wget https://ghproxy.com/https://github.com/cby-chen/Kubernetes/releases/download/cby/Kubernetes.tar
- wget https://ghproxy.com/https://github.com/cby-chen/Kubernetes/releases/download/v1.23.4/kubernetes-v1.23.4.tar
- wget https://ghproxy.com/https://github.com/cby-chen/Kubernetes/releases/download/v1.23.5/kubernetes-v1.24.5.tar
- wget https://ghproxy.com/https://github.com/cby-chen/Kubernetes/releases/download/v1.23.6/kubernetes-v1.23.6.tar
- wget https://ghproxy.com/https://github.com/cby-chen/Kubernetes/releases/download/v1.23.7/kubernetes-v1.23.7.tar
- wget https://ghproxy.com/https://github.com/cby-chen/Kubernetes/releases/download/v1.24.0/kubernetes-v1.24.0.tar
- wget https://ghproxy.com/https://github.com/cby-chen/Kubernetes/releases/download/v1.24.1/kubernetes-v1.24.1.tar
- wget https://ghproxy.com/https://github.com/cby-chen/Kubernetes/releases/download/v1.24.2/kubernetes-v1.24.2.tar
- wget https://ghproxy.com/https://github.com/cby-chen/Kubernetes/releases/download/v1.24.3/kubernetes-v1.24.3.tar
- wget https://ghproxy.com/https://github.com/cby-chen/Kubernetes/releases/download/v1.25.0/kubernetes-v1.25.0.tar
- wget https://ghproxy.com/https://github.com/cby-chen/Kubernetes/releases/download/v1.22.10/kubernetes-v1.22.10.tar
- wget https://ghproxy.com/https://github.com/cby-chen/Kubernetes/releases/download/v1.21.13/kubernetes-v1.21.13.tar  

*注意：1.23.3 版本当时没想到会后续更新，所以当时命名不太规范。

# 旧版本地址

建议查看main版本中的文档。  
https://github.com/cby-chen/Kubernetes/  
若找对应版本文档中的安装包，可以在上方下载安装包，可以在在下方地址中查找。

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
- https://github.com/cby-chen/Kubernetes/tree/v1.22.10
- https://github.com/cby-chen/Kubernetes/tree/v1.21.13

# 常见异常

-  安装会出现kubelet异常，无法识别 `--node-labels` 字段问题，原因如下。

将 `--node-labels=node.kubernetes.io/node=''` 替换为 `--node-labels=node.kubernetes.io/node=`  将 `''` 删除即可。

-  注意hosts配置文件中主机名和IP地址对应

-  在文档7.2，却记别忘记执行`kubectl create -f bootstrap.secret.yaml`命令


# 其他

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

# 技术交流

作者:  

![avatar](https://www.oiox.cn/about/2.png)  

加群:  

![avatar](https://www.oiox.cn/about/1.png)  

</br>
</br>


## Stargazers over time

[![Stargazers over time](https://starchart.cc/cby-chen/Kubernetes.svg)](https://starchart.cc/cby-chen/Kubernetes)

