## Kubernetes 1.24 1.25 集群使用docker作为容器

### 背景

在新版本Kubernetes环境（1.24以及以上版本）下官方不在支持docker作为容器运行时了，若要继续使用docker 需要对docker进行配置一番。需要安装cri-docker作为Kubernetes容器



### 查看当前容器运行时

```shell
# 查看指定节点容器运行时
kubectl  describe node k8s-node05  | grep Container
  Container Runtime Version:  containerd://1.6.8

# 查看所有节点容器运行时
kubectl  describe node  | grep Container
  Container Runtime Version:  containerd://1.6.8
  Container Runtime Version:  containerd://1.6.8
  Container Runtime Version:  containerd://1.6.8
  Container Runtime Version:  containerd://1.6.8
  Container Runtime Version:  containerd://1.6.8
  Container Runtime Version:  containerd://1.6.8
  Container Runtime Version:  containerd://1.6.8
  Container Runtime Version:  containerd://1.6.8
```



### 安装docker

```shell
# 更新源信息
yum update
# 安装必要软件
yum install -y yum-utils   device-mapper-persistent-data   lvm2

# 写入docker源信息
sudo yum-config-manager \
    --add-repo \
    https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/docker-ce.repo

# 更新源信息并进行安装
yum update
yum install docker-ce docker-ce-cli containerd.io


# 配置加速器
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://hub-mirror.c.163.com"],
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
```



### 安装cri-docker

```shell
# 由于1.24以及更高版本不支持docker所以安装cri-docker
# 下载cri-docker 
wget  https://ghproxy.com/https://github.com/Mirantis/cri-dockerd/releases/download/v0.2.5/cri-dockerd-0.2.5.amd64.tgz

# 解压cri-docker
tar xvf cri-dockerd-0.2.5.amd64.tgz 
cp cri-dockerd/cri-dockerd  /usr/bin/

# 写入启动配置文件
cat >  /usr/lib/systemd/system/cri-docker.service <<EOF
[Unit]
Description=CRI Interface for Docker Application Container Engine
Documentation=https://docs.mirantis.com
After=network-online.target firewalld.service docker.service
Wants=network-online.target
Requires=cri-docker.socket

[Service]
Type=notify
ExecStart=/usr/bin/cri-dockerd --network-plugin=cni --pod-infra-container-image=registry.aliyuncs.com/google_containers/pause:3.7
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutSec=0
RestartSec=2
Restart=always

StartLimitBurst=3

StartLimitInterval=60s

LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity

TasksMax=infinity
Delegate=yes
KillMode=process

[Install]
WantedBy=multi-user.target
EOF

# 写入socket配置文件
cat > /usr/lib/systemd/system/cri-docker.socket <<EOF
[Unit]
Description=CRI Docker Socket for the API
PartOf=cri-docker.service

[Socket]
ListenStream=%t/cri-dockerd.sock
SocketMode=0660
SocketUser=root
SocketGroup=docker

[Install]
WantedBy=sockets.target
EOF

# 进行启动cri-docker
systemctl daemon-reload ; systemctl enable cri-docker --now
```



### 为kubelet配置容器运行时

```shell
# 1.25 版本下 所有k8s节点配置kubelet service
cat > /usr/lib/systemd/system/kubelet.service << EOF

[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=containerd.service
Requires=containerd.service

[Service]
ExecStart=/usr/local/bin/kubelet \\
    --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.kubeconfig  \\
    --kubeconfig=/etc/kubernetes/kubelet.kubeconfig \\
    --config=/etc/kubernetes/kubelet-conf.yml \\
    --container-runtime-endpoint=unix:///run/cri-dockerd.sock  \\
    --node-labels=node.kubernetes.io/node=

[Install]
WantedBy=multi-user.target
EOF


# 1.24 版本下 所有k8s节点配置kubelet service
cat > /usr/lib/systemd/system/kubelet.service << EOF

[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=containerd.service
Requires=containerd.service

[Service]
ExecStart=/usr/local/bin/kubelet \\
    --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.kubeconfig  \\
    --kubeconfig=/etc/kubernetes/kubelet.kubeconfig \\
    --config=/etc/kubernetes/kubelet-conf.yml \\
    --container-runtime=remote  \\
    --runtime-request-timeout=15m  \\
    --container-runtime-endpoint=unix:///run/cri-dockerd.sock  \\
    --cgroup-driver=systemd \\
    --node-labels=node.kubernetes.io/node= \\
    --feature-gates=IPv6DualStack=true

[Install]
WantedBy=multi-user.target
EOF



# 重启
systemctl daemon-reload
systemctl restart kubelet
systemctl enable --now kubelet
```



### 验证

```shell
# 查看指定节点容器运行时
kubectl  describe node k8s-node05  | grep Container
  Container Runtime Version:  docker://20.10.17

# 查看所有节点容器运行时
kubectl  describe node  | grep Container
  Container Runtime Version:  containerd://1.6.8
  Container Runtime Version:  containerd://1.6.8
  Container Runtime Version:  containerd://1.6.8
  Container Runtime Version:  containerd://1.6.8
  Container Runtime Version:  containerd://1.6.8
  Container Runtime Version:  containerd://1.6.8
  Container Runtime Version:  containerd://1.6.8
  Container Runtime Version:  docker://20.10.17
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