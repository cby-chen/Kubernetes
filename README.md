# Kubernetes (K8s) 二进制高可用安装指南

> 📌 **项目地址**: [GitHub](https://github.com/cby-chen/Kubernetes) | [Gitee](https://gitee.com/cby-inc/Kubernetes)
>
> ⭐ 开源不易,如果本文对您有帮助,请给个 Star 支持一下! 🌹

---

## ⚠️ 重要提示

> **中国大陆地区镜像封锁警告**
> 
> - Docker 及其他仓库镜像已被 GFW 完全封锁
> - 现有镜像已无法直接拉取,需要通过特殊方式访问
> - 建议使用国内镜像源或代理方案

---

## 📖 目录

- [一、写在前面](#一写在前面)
- [二、项目介绍](#二项目介绍)
  - [容器运行时兼容性说明](#容器运行时兼容性说明)
- [三、支持的版本](#三支持的版本)
- [四、项目地址](#四项目地址)
- [五、文档索引](#五文档索引)
  - [最新版本文档](#最新版本文档)
  - [历史版本文档](#历史版本文档)
  - [其他技术文档](#其他技术文档)
- [六、安装包下载](#六安装包下载)
- [七、常见异常处理](#七常见异常处理)
- [八、生产环境推荐配置](#八生产环境推荐配置)
- [九、联系方式与资源](#九联系方式与资源)

---

## 一、写在前面

### 💡 部署建议

1. **快速上手**: 打开文档后,使用全文替换功能,将示例 IP 替换为您的实际主机 IP
2. **自动化优先**: 手动部署较为复杂,推荐以下自动化方案:
   - [kubeasz](https://github.com/easzlab/kubeasz) - 自动化部署工具
   - [kubeadm 安装指南](./doc/kubeadm-install-V1.32.md) - 官方推荐方式

> ⚡ **建议**: 能用自动部署就用自动部署,避免不必要的手动操作复杂度

## 二、项目介绍

### 容器运行时兼容性说明

#### 🔧 关于 Docker 运行时的已知问题

> **重要提醒**: 在最新的 IPv4/IPv6 双栈网络环境中,若使用 Docker 作为容器运行时(Runtime),可能会导致以下问题:
> - `kubectl exec` 进入容器失败
> - 网络连接异常
> 
> **根本原因**: cri-dockerd 组件对双栈网络的兼容性存在缺陷
> 
> **解决方案**: Kubernetes 官方已正式弃用 Docker Shim,**强烈建议生产环境使用 Containerd 作为默认容器运行时**,以获得更稳定的支持和性能。

#### 🌐 关于 IPv6 配置

- 最新文档已对 IPv6 双栈配置进行详细说明
- 若不需要 IPv6 支持,请查阅文档中的**"纯 IPv4 配置"**或**"禁用 IPv6"**相关章节
- 避免不必要的网络配置复杂性

## 三、支持的版本

本文档支持以下 Kubernetes 版本,大版本之间通用(例如:使用 1.26.0 的文档可安装 1.26.x 系列各版本,只需下载对应版本的安装包即可):

| 版本系列 | 状态 | 备注 |
|---------|------|------|
| 1.36.x | ✅ 最新 | 推荐使用 |
| 1.35.x | ✅ 稳定 | 推荐使用 |
| 1.34.x | ✅ 稳定 | - |
| 1.33.x | ✅ 稳定 | - |
| 1.32.x | ✅ 稳定 | - |
| 1.31.x | ✅ 稳定 | - |
| 1.30.x | ✅ 稳定 | - |
| 1.29.x | ✅ 稳定 | - |
| 1.28.x | ✅ 稳定 | - |
| 1.27.x | ✅ 稳定 | - |
| 1.26.x | ✅ 稳定 | - |
| 1.25.x | ✅ 稳定 | - |
| 1.24.x | ⚠️ 维护 | Docker Shim 已移除 |
| 1.23.x | ⚠️ 维护 | - |
| 1.22.x | ⚠️ 维护 | - |
| 1.21.x | ⚠️ 维护 | - |

## 四、项目地址

### 📦 代码仓库

- **手动部署项目**: [GitHub - cby-chen/Kubernetes](https://github.com/cby-chen/Kubernetes)
- **脚本项目**(已停更):
  - [Binary_installation_of_Kubernetes](https://github.com/cby-chen/Binary_installation_of_Kubernetes)
  - [kube_ansible](https://github.com/cby-chen/kube_ansible)

## 五、文档索引

### 📚 最新版本文档

| 文档名称 | 链接 |
|---------|------|
| kubeadm 安装指南(V1.32) | [kubeadm-install.md](./doc/kubeadm-install-V1.32.md) |
| v1.36.0 CentOS 二进制安装(离线) | [v1.36.0-CentOS-binary-install.md](./doc/v1.36.0-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves-Offline.md) |
| v1.35.0 CentOS 二进制安装(离线) | [v1.35.0-CentOS-binary-install.md](./doc/v1.35.0-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves-Offline.md) |

### 📖 历史版本文档

#### 1.36.x 版本
- [v1.36.0 CentOS 二进制安装(离线)](./doc/v1.36.0-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves-Offline.md)

#### 1.35.x 版本
- [v1.35.0 CentOS 二进制安装(离线)](./doc/v1.35.0-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves-Offline.md)

#### 1.34.x 版本
- [v1.34.0 CentOS 二进制安装(离线)](./doc/v1.34.0-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves-Offline.md)

#### 1.33.x 版本
- [v1.33.0 CentOS 二进制安装(离线)](./doc/v1.33.0-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves-Offline.md)

#### 1.32.x 版本
- [v1.32.0 CentOS 二进制安装(离线)](./doc/v1.32.0-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves-Offline.md)

#### 1.31.x 版本
- [v1.31.1 CentOS 二进制安装(离线)](./doc/v1.31.1-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves-Offline.md)

#### 1.30.x 版本
- [v1.30.1 CentOS 二进制安装(离线)](./doc/v1.30.1-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves-Offline.md)
- [v1.30.2 CentOS 二进制安装(离线)](./doc/v1.30.2-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves-Offline.md)

#### 1.29.x 版本
- [v1.29.2 CentOS 二进制安装(离线)](./doc/v1.29.2-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves-Offline.md)

#### 1.28.x 版本
- [v1.28.0 CentOS 二进制安装(离线)](./doc/v1.28.0-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves-Offline.md)
- [v1.28.3 CentOS 二进制安装(离线)](./doc/v1.28.3-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves-Offline.md)

#### 1.27.x 版本
- [v1.27.1 CentOS 二进制安装(离线)](./doc/v1.27.1-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves-Offline.md)
- [v1.27.3 CentOS 二进制安装(离线)](./doc/v1.27.3-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves-Offline.md)

#### 1.26.x 版本
- [v1.26.0 CentOS 二进制安装](./doc/v1.26.0-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md)
- [v1.26.1 CentOS 二进制安装(离线)](./doc/v1.26.1-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves-Offline.md)

#### 1.25.x 版本
- [v1.25.0 CentOS 二进制安装](./doc/v1.25.0-CentOS-binary-install-IPv6-IPv4.md)
- [v1.25.4 CentOS 二进制安装](./doc/v1.25.4-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md)

#### 1.24.x 版本
- [v1.24.0 CentOS 二进制安装](./doc/v1.24.0-CentOS-binary-install-IPv6-IPv4.md)
- [v1.24.1 CentOS 二进制安装](./doc/v1.24.1-CentOS-binary-install-IPv6-IPv4.md)
- [v1.24.2 CentOS 二进制安装](./doc/v1.24.2-CentOS-binary-install-IPv6-IPv4.md)
- [v1.24.3 CentOS 二进制安装](./doc/v1.24.3-CentOS-binary-install-IPv6-IPv4.md)

#### 1.23.x 版本
- [v1.23.3 CentOS 二进制安装](./doc/v1.23.3-CentOS-binary-install.md)
- [v1.23.4 CentOS 二进制安装](./doc/v1.23.4-CentOS-binary-install.md)
- [v1.23.5 CentOS 二进制安装](./doc/v1.23.5-CentOS-binary-install.md)
- [v1.23.6 CentOS 二进制安装](./doc/v1.23.6-CentOS-binary-install.md)

> ⚠️ **注意**: v1.23.3 版本命名不规范,后续版本已修正

#### 1.22.x 版本
- [v1.22.10 CentOS 二进制安装](./doc/v1.22.10-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md)

#### 1.21.x 版本
- [v1.21.13 CentOS 二进制安装](./doc/v1.21.13-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md)

### 🛠️ 其他技术文档

| 文档主题 | 链接 |
|---------|------|
| kube-proxy 证书权限修复 | [kube-proxy_permissions.md](./doc/kube-proxy_permissions.md) |
| kubeadm 初始化 IPv4/IPv6 集群 | [kubeadm-install-IPV6-IPV4.md](./doc/kubeadm-install-IPV6-IPV4.md) |
| IPv4 集群启用 IPv6 / 关闭 IPv6 | [Enable-implement-IPv4-IPv6.md](./doc/Enable-implement-IPv4-IPv6.md) |
| Kubernetes 集群升级指南 | [Upgrade_Kubernetes.md](./doc/Upgrade_Kubernetes.md) |
| Minikube 初始化集群 | [Minikube_init.md](./doc/Minikube_init.md) |
| K8s 1.24/1.25 使用 Docker 运行时 | [Kubernetes_docker.md](./doc/Kubernetes_docker.md) |
| Kubernetes 安装 Cilium | [kubernetes_install_cilium.md](./doc/kubernetes_install_cilium.md) |

## 六、安装包下载

### 📥 下载地址

| 来源 | 链接 |
|------|------|
| 123云盘 | [https://www.123pan.com/s/Z8ArVv-PG60d](https://www.123pan.com/s/Z8ArVv-PG60d) |
| GitHub Releases | [https://github.com/cby-chen/Kubernetes/releases](https://github.com/cby-chen/Kubernetes/releases) |

> ⚠️ **注意**: v1.23.3 版本当时未考虑到后续更新,命名不太规范,后续版本已修正

## 七、常见异常处理

### ❗ 常见问题清单

#### 1. Hosts 配置问题
> **症状**: 节点间通信失败
> 
> **解决**: 检查 `/etc/hosts` 配置文件,确保主机名和 IP 地址正确对应

#### 2. Bootstrap Secret 未创建
> **症状**: 节点加入集群失败
> 
> **解决**: 在文档第 7.2 节,**切记不要忘记**执行以下命令:
> ```bash
> kubectl create -f bootstrap.secret.yaml
> ```

#### 3. Kubelet 服务异常
> **症状**: 重启服务器后集群异常
> 
> **解决**: 检查 kubelet 服务状态:
> ```bash
> systemctl status kubelet.service
> ```

#### 4. CentOS 7 兼容性问题
> **症状**: 容器运行时异常
> 
> **解决**: 需要升级 runc 和 libseccomp
> 
> **参考**: [v1.25.0 安装文档 - 网络插件章节](https://github.com/cby-chen/Kubernetes/blob/main/doc/v1.25.0-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves.md#9%E5%AE%89%E8%A3%85%E7%BD%91%E7%BB%9C%E6%8F%92%E4%BB%B6)

#### 5. Node Labels 参数错误
> **症状**: kubelet 无法识别 `--node-labels` 字段
> 
> **原因**: 参数格式不正确
> 
> **解决**: 将 `--node-labels=node.kubernetes.io/node=''` 替换为 `--node-labels=node.kubernetes.io/node=` (删除末尾的 `''`)

#### 6. IPv6 访问异常
> **症状**: IPv6 无法正常访问
> 
> **解决**: kubelet 服务需要添加 `--node-ip=` 参数
> 
> **注意**: 若动态获取 IP 地址发生变动,需要重新配置
> 
> **参考**: [v1.28.3 安装文档 - Kubelet 配置章节](https://github.com/cby-chen/Kubernetes/blob/main/doc/v1.28.3-CentOS-binary-install-IPv6-IPv4-Three-Masters-Two-Slaves-Offline.md#82kubelet%E9%85%8D%E7%BD%AE)

## 八、生产环境推荐配置

### 🖥️ Master 节点配置

> **高可用要求**: 必须部署 3 个节点实现高可用

| 节点规模 | CPU | 内存 | 备注 |
|---------|-----|------|------|
| 0-100 节点 | 8 核 | 16 GB+ | 基础配置 |
| 100-250 节点 | 8 核 | 32 GB+ | 推荐配置 |
| 250-500 节点 | 16 核 | 32 GB+ | 高性能配置 |

### 💾 etcd 节点配置

> **高可用要求**: 必须部署 3 个节点实现高可用  
> **存储要求**: 有条件必须使用高性能 SSD 硬盘,至少需要高效独立磁盘

| 节点规模 | CPU | 内存 | SSD 存储 |
|---------|-----|------|----------|
| 0-50 节点 | 2 核 | 8 GB+ | 50 GB |
| 50-250 节点 | 4 核 | 16 GB+ | 150 GB |
| 250-1000 节点 | 8 核 | 32 GB+ | 250 GB |

### 🐳 Node 节点配置

> **磁盘要求**: 
> - Docker 数据分区和系统分区必须单独使用,不可共用同一磁盘
> - 系统分区: 100 GB+
> - Docker 数据分区: 200 GB+
> - 有条件使用 SSD 硬盘,必须独立于系统盘

### 💡 其他建议

#### 小规模集群部署方案

对于集群规模不大的场景,可以将 etcd 和 master 部署在同一宿主机上:

- **部署方式**: 每个 master 节点同时部署 K8s 组件和 etcd 服务
- **关键要求**: etcd 数据目录必须独立,并使用 SSD
- **资源考虑**: 两者部署在一起需要相对增加宿主机资源

#### 资源配置建议

> ⚡ **个人建议**: 生产环境把 master 节点的资源一次性给够,此处费用不应节省
> 
> - **推荐配置**: 16 核 32 GB 或 64 GB
> - **优势**: 后续集群扩容无需再扩容 master 节点资源,降低风险
> - **系统分区**: master 节点和 etcd 节点的系统分区 100 GB 即可

## 九、联系方式与资源

### 📱 添加好友

<img src="./images/1.jpg" width="30%" alt="添加好友二维码" />

### 💰 打赏支持

<img src="./images/3.jpg" width="30%" alt="打赏二维码" />

### 🌐 更多资源

> 📖 **建议在 [GitHub 主仓库](https://github.com/cby-chen/Kubernetes) 查看最新文档,后续会持续更新**

#### 小陈运维网站

- [主页](https://www.oiox.cn/)
- [导航页](https://www.oiox.cn/index.php/start-page.html)

#### 全平台搜索

> **全网可搜《小陈运维》**
> 
> 文章主要发布于**微信公众号**
> 
> 同步发布至:
> - CSDN、GitHub、51CTO、知乎
> - 开源中国、思否、掘金、简书
> - 华为云、阿里云、腾讯云
> - 哔哩哔哩、今日头条
> - 新浪微博、个人博客

---

## 📊 Stargazers over time

[![Stargazers over time](https://starchart.cc/cby-chen/Kubernetes.svg)](https://starchart.cc/cby-chen/Kubernetes)

---

> 📝 **文档最后更新时间**: 2026-05-11  
> 👤 **作者**: 小陈运维  
