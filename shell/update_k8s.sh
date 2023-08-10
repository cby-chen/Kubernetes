#!/bin/bash

###
#   作者：陈步云
#   微信：15648907522
#   更新k8s集群，目前脚本支持小版本之间的更新
# 
# 
#   注意！！！！
#   更新时候服务会重启

# 升级小版本
export k8s='1.27.4'

# 服务器地址
export All="192.168.0.31 192.168.0.32 192.168.0.33 192.168.0.34 192.168.0.35"
export Master='192.168.0.31 192.168.0.32 192.168.0.33'
export Work='192.168.0.34 192.168.0.35'

# 服务器的密码
export SSHPASS=123123


echo '开始安装免密工具'

# 判断系统类型并进行安装
os=$(cat /etc/os-release 2>/dev/null | grep ^ID= | awk -F= '{print $2}')
if [ "$os" = "\"centos\"" ]; then
   yum update -y ; yum install -y sshpass
fi
if [ "$os" = "ubuntu" ]; then
   apt update -y ; apt install -y sshpass
fi

# 配置免密登录
ssh-keygen -f /root/.ssh/id_rsa -P '' -y
for HOST in ${All};do
     sshpass -f  -e ssh-copy-id -o StrictHostKeyChecking=no $HOST
done


echo '开始下载所需包'

# 创建工作目录
mkdir -p update_k8s && cd update_k8s

# 下载所需版本
if [ -e "kubernetes-server-linux-amd64.tar.gz" ]; then
    echo "文件存在"
else
    echo "文件不存在"
    wget https://dl.k8s.io/v${k8s}/kubernetes-server-linux-amd64.tar.gz && tar xf kubernetes-server-linux-amd64.tar.gz
fi

echo '开始更新集群'


# 拷贝所需安装包并重启
for master in ${Master}; do
    # 停止服务...
    ssh ${master} "systemctl stop kube-apiserver kube-controller-manager kube-scheduler kubelet kube-proxy"
    # 分发安装包...
    scp kubernetes/server/bin/kube{let,ctl,-apiserver,-controller-manager,-scheduler,-proxy} ${master}:/usr/local/bin/
    # 启动服务...
    ssh ${master} "systemctl restart kube-apiserver kube-controller-manager kube-scheduler kubelet kube-proxy"
done

# 拷贝所需安装包并重启
for work in ${Work}; do
    # 停止服务...
    ssh ${work} "systemctl stop kubelet kube-proxy"
    # 分发安装包...
    scp kubernetes/server/bin/kube{let,-proxy} ${work}:/usr/local/bin/
    # 启动服务...
    ssh ${work} "systemctl restart kubelet kube-proxy"
done

echo '更新完成，`kubectl get node`看一下结果吧！'
