## 安装Minikube并启动一个Kubernetes环境
Minikube 是一种轻量级的Kubernetes 实现，可在本地计算机上创建VM 并部署仅包含一个节点的简单集群。Minikube 可用于Linux ， macOS 和Windows 系统。Minikube CLI 提供了用于引导集群工作的多种操作，包括启动、停止、查看状态和删除。

### 安装docker

```shell
# 更新源信息
sudo apt-get update

# 安装必要软件
sudo apt-get install ca-certificates curl gnupg lsb-release
    
# 创建key
sudo mkdir -p /etc/apt/keyrings

# 导入key证书
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# 写入docker源信息
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 设置为国内源
sed -i s#download.docker.com#mirrors.ustc.edu.cn/docker-ce#g /etc/apt/sources.list.d/docker.list

# 更新源信息并进行安装
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

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

### 安装nimikuber
```shell
# 下载最新版本kuberctl
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl

# 下载指定版本kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.16.0/bin/linux/amd64/kubectl

# 设置执行权限
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

# 查看版本
kubectl version

# 下载安装 minikuber
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube

# 安装nimikuber
sudo mkdir -p /usr/local/bin/
sudo install minikube /usr/local/bin/

# 配置免密
ssh-keygen -t rsa
ssh-copy-id 192.168.1.94

# 启动minikube

root@cby:~# minikube start --driver=docker --container-runtime=containerd --image-mirror-country=cn --force
* minikube v1.26.1 on Ubuntu 22.04
! minikube skips various validations when --force is supplied; this may lead to unexpected behavior
* Using the docker driver based on user configuration
* The "docker" driver should not be used with root privileges. If you wish to continue as root, use --force.
* If you are running minikube within a VM, consider using --driver=none:
*   https://minikube.sigs.k8s.io/docs/reference/drivers/none/
* Using image repository registry.cn-hangzhou.aliyuncs.com/google_containers
* Using Docker driver with root privileges
* Starting control plane node minikube in cluster minikube
* Pulling base image ...
    > registry.cn-hangzhou.aliyun...:  386.60 MiB / 386.61 MiB  100.00% 1.37 Mi
    > registry.cn-hangzhou.aliyun...:  0 B [____________________] ?% ? p/s 4m9s
* Creating docker container (CPUs=2, Memory=2200MB) ...
* Preparing Kubernetes v1.24.3 on containerd 1.6.6 ...
    > kubelet.sha256:  64 B / 64 B [-------------------------] 100.00% ? p/s 0s
    > kubectl.sha256:  64 B / 64 B [-------------------------] 100.00% ? p/s 0s
    > kubeadm.sha256:  64 B / 64 B [-------------------------] 100.00% ? p/s 0s
    > kubeadm:  42.32 MiB / 42.32 MiB [--------------] 100.00% 1.36 MiB p/s 31s
    > kubectl:  43.59 MiB / 43.59 MiB [--------------] 100.00% 1.02 MiB p/s 43s
    > kubelet:  110.64 MiB / 110.64 MiB [----------] 100.00% 1.36 MiB p/s 1m22s
  - Generating certificates and keys ...
  - Booting up control plane ...
  - Configuring RBAC rules ...
* Configuring CNI (Container Networking Interface) ...
* Verifying Kubernetes components...
  - Using image registry.cn-hangzhou.aliyuncs.com/google_containers/storage-provisioner:v5
* Enabled addons: storage-provisioner, default-storageclass
* Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
root@cby:~# 
```

### 验证
```shell
root@cby:~# kubectl get node
NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   43s   v1.24.3
root@cby:~# 
root@cby:~# kubectl get pod -A
NAMESPACE     NAME                               READY   STATUS    RESTARTS   AGE
kube-system   coredns-7f74c56694-znvr4           1/1     Running   0          31s
kube-system   etcd-minikube                      1/1     Running   0          43s
kube-system   kindnet-nt8nf                      1/1     Running   0          31s
kube-system   kube-apiserver-minikube            1/1     Running   0          43s
kube-system   kube-controller-manager-minikube   1/1     Running   0          43s
kube-system   kube-proxy-ztq87                   1/1     Running   0          31s
kube-system   kube-scheduler-minikube            1/1     Running   0          43s
kube-system   storage-provisioner                1/1     Running   0          41s
root@cby:~# 
```

### 附录

```
# 若出现错误可以做如下操作
minikube delete
rm -rf .minikube/
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
