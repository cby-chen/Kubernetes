# 二进制安装 Kubernetes（k8s）

[Kubernetes](https://github.com/cby-chen/Kubernetes) 开源不易，帮忙点个star，谢谢了🌹

不推荐使用CentOS7安装kubernetes集群，建议使用CentOS8安装！

CentOS7安装会出现kubelet异常，无法识别 `--node-labels` 字段问题，原因如下。

注意若是CentOS7，将 `--node-labels=node.kubernetes.io/node=''` 替换为 `--node-labels=node.kubernetes.io/node=` 
将 `''` 删除

# 介绍

kubernetes二进制安装

后续尽可能第一时间更新新版本文档，更新后内容在GitHub。

本文是使用的是Ubuntu作为基底，其他文档请在GitHub上查看。

1.23.3 和 1.23.4 和 1.23.5 和 1.23.6 和 1.24.0 和1.24.1 文档以及安装包已生成。

我使用IPV6的目的是在公网进行访问，所以我配置了IPV6静态地址。

若您没有IPV6环境，或者不想使用IPv6，不对主机进行配置IPv6地址即可。

不配置IPV6，不影响后续，不过集群依旧是支持IPv6的。为后期留有扩展可能性。

https://github.com/cby-chen/Kubernetes/

手动项目地址：https://github.com/cby-chen/Kubernetes

脚本项目地址：https://github.com/cby-chen/Binary_installation_of_Kubernetes

kubernetes 1.24 变化较大，详细见：https://kubernetes.io/zh/blog/2022/04/07/upcoming-changes-in-kubernetes-1-24/

# 文档

每个版本文档如下链接

v1.23.3

https://github.com/cby-chen/Kubernetes/blob/main/v1.23.3-CentOS-binary-install.md

v1.23.4

https://github.com/cby-chen/Kubernetes/blob/main/v1.23.4-CentOS-binary-install.md

v1.23.5

https://github.com/cby-chen/Kubernetes/blob/main/v1.23.5-CentOS-binary-install.md

v1.23.6

https://github.com/cby-chen/Kubernetes/blob/main/v1.23.6-CentOS-binary-install.md

v1.24.0

https://github.com/cby-chen/Kubernetes/blob/main/v1.24.0-CentOS-binary-install-IPv6-IPv4.md

v1.24.1

https://github.com/cby-chen/Kubernetes/blob/main/v1.24.1-CentOS-binary-install-IPv6-IPv4.md

v1.23.7

https://github.com/cby-chen/Kubernetes/blob/main/v1.23.7-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md

v1.24.0

https://github.com/cby-chen/Kubernetes/blob/main/v1.24.0-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md

v1.24.1
https://github.com/cby-chen/Kubernetes/blob/main/v1.24.1-Ubuntu-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md

# 安装包

（下载更快）我自己的网盘：https://pan.oiox.cn/s/PetV

每个初始版本会打上releases，安装包在releases页面

https://github.com/cby-chen/Kubernetes/releases

注意：1.23.3 版本当时没想到会后续更新，所以当时命名不太规范。

wget https://github.com/cby-chen/Kubernetes/releases/download/cby/Kubernetes.tar

wget https://github.com/cby-chen/Kubernetes/releases/download/v1.23.4/kubernetes-v1.23.4.tar

wget https://github.com/cby-chen/Kubernetes/releases/download/v1.23.5/kubernetes-v1.24.5.tar

wget https://github.com/cby-chen/Kubernetes/releases/download/v1.23.6/kubernetes-v1.23.6.tar

wget https://github.com/cby-chen/Kubernetes/releases/download/v1.24.0/kubernetes-v1.24.0.tar

wget https://github.com/cby-chen/Kubernetes/releases/download/v1.24.1/kubernetes-v1.24.1.tar

# 旧版本地址

建议查看main版本中的文档。https://github.com/cby-chen/Kubernetes/

若找对应版本文档中的安装包，可以在上方下载安装包，可以在在下方地址中查找。

https://github.com/cby-chen/Kubernetes/tree/cby

https://github.com/cby-chen/Kubernetes/tree/v1.23.4

https://github.com/cby-chen/Kubernetes/tree/v1.23.5

https://github.com/cby-chen/Kubernetes/tree/v1.23.6

https://github.com/cby-chen/Kubernetes/tree/v1.24.0

https://github.com/cby-chen/Kubernetes/tree/v1.24.1

# 其他

- 建议在 [Kubernetes](https://github.com/cby-chen/Kubernetes) 查看文档，后续会陆续更新文档
- 小陈网站：

1. https://blog.oiox.cn/
2. https://www.oiox.cn/
3. https://www.chenby.cn/
4. https://cby-chen.github.io/

- 关于小陈：https://www.oiox.cn/index.php/start-page.html

# 技术交流

作者:  

![avatar](https://www.oiox.cn/about/2.png)  

加群:  

![avatar](https://www.oiox.cn/about/1.png)  

</br>
</br>

其他文档请查看如下，欢迎关注微信公众号《Linux运维交流社区》：

> https://www.oiox.cn/  
> https://blog.oiox.cn/  
> https://www.chenby.cn/  
> https://cby-chen.github.io/  
> https://my.oschina.net/u/3981543/  
> https://blog.csdn.net/qq_33921750/  
> https://www.jianshu.com/u/0f894314ae2c/  
> https://juejin.cn/user/3315782802482007/  
> https://www.zhihu.com/people/chen-bu-yun-2/  
> https://segmentfault.com/u/hppyvyv6/articles/  
> https://space.bilibili.com/352476552/article/  
> https://cloud.tencent.com/developer/column/93230  
> https://developer.aliyun.com/profile/nghinjk6dyidw/  
> https://bbs.huaweicloud.com/community/usersnew/id_1576987520942284/  
> https://www.toutiao.com/c/user/token/MS4wLjABAAAAeqOrhjsoRZSj7iBJbjLJyMwYT5D0mLOgCoo4pEmpr4A/  

CSDN、GitHub、知乎、开源中国、思否、掘金、简书、华为云、阿里云、腾讯云、哔哩哔哩、今日头条、新浪微博、个人博客  

全网可搜《小陈运维》  

文章主要发布于微信公众号
