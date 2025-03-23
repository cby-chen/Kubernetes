# 使用kubeadm部署高可用IPV4/IPV6集群

https://github.com/cby-chen/Kubernetes 开源不易，帮忙点个star，谢谢了

## k8s基础系统环境配置

### 配置IP

```shell
# 注意！
# 若虚拟机是进行克隆的那么网卡的UUID和MachineID会重复
# 需要重新生成新的UUIDUUID和MachineID
# UUID和MachineID重复无法DHCP获取到IPV6地址
ssh root@192.168.1.189 "rm -rf /etc/machine-id; systemd-machine-id-setup;reboot"
ssh root@192.168.1.190 "rm -rf /etc/machine-id; systemd-machine-id-setup;reboot"
ssh root@192.168.1.191 "rm -rf /etc/machine-id; systemd-machine-id-setup;reboot"
ssh root@192.168.1.192 "rm -rf /etc/machine-id; systemd-machine-id-setup;reboot"
ssh root@192.168.1.193 "rm -rf /etc/machine-id; systemd-machine-id-setup;reboot"
# 
# 查看当前的网卡列表和 UUID：
# nmcli con show
# 删除要更改 UUID 的网络连接：
# nmcli con delete uuid <原 UUID>
# 重新生成 UUID：
# nmcli con add type ethernet ifname <接口名称> con-name <新名称>
# 重新启用网络连接：
# nmcli con up <新名称>

# 更改网卡的UUID
# 先配置静态IP之后使用ssh方式配置不断连
ssh root@192.168.1.189 "nmcli con delete uuid d1141403-18c6-3149-907c-ed5f09663a7f;nmcli con add type ethernet ifname ens160 con-name ens160;nmcli con up ens160"
ssh root@192.168.1.190 "nmcli con delete uuid d1141403-18c6-3149-907c-ed5f09663a7f;nmcli con add type ethernet ifname ens160 con-name ens160;nmcli con up ens160"
ssh root@192.168.1.191 "nmcli con delete uuid d1141403-18c6-3149-907c-ed5f09663a7f;nmcli con add type ethernet ifname ens160 con-name ens160;nmcli con up ens160"
ssh root@192.168.1.192 "nmcli con delete uuid d1141403-18c6-3149-907c-ed5f09663a7f;nmcli con add type ethernet ifname ens160 con-name ens160;nmcli con up ens160"
ssh root@192.168.1.193 "nmcli con delete uuid d1141403-18c6-3149-907c-ed5f09663a7f;nmcli con add type ethernet ifname ens160 con-name ens160;nmcli con up ens160"

# 参数解释
# 
# ssh ssh root@192.168.1.21
# 使用SSH登录到IP为192.168.1.21的主机，使用root用户身份。
# 
# nmcli con delete uuid 708a1497-2192-43a5-9f03-2ab936fb3c44
# 删除 UUID 为 708a1497-2192-43a5-9f03-2ab936fb3c44 的网络连接，这是 NetworkManager 中一种特定网络配置的唯一标识符。
# 
# nmcli con add type ethernet ifname ens160 con-name ens160
# 添加一种以太网连接类型，并指定接口名为 ens160，连接名称也为 ens160。
# 
# nmcli con up ens160
# 开启 ens160 这个网络连接。
# 
# 简单来说，这个命令的作用是删除一个特定的网络连接配置，并添加一个名为 ens160 的以太网连接，然后启用这个新的连接。

# 修改静态的IPv4地址
ssh root@192.168.1.189 "nmcli con mod ens160 ipv4.addresses 192.168.1.21/24; nmcli con mod ens160 ipv4.gateway  192.168.1.1; nmcli con mod ens160 ipv4.method manual; nmcli con mod ens160 ipv4.dns "8.8.8.8"; nmcli con up ens160"
ssh root@192.168.1.190 "nmcli con mod ens160 ipv4.addresses 192.168.1.22/24; nmcli con mod ens160 ipv4.gateway  192.168.1.1; nmcli con mod ens160 ipv4.method manual; nmcli con mod ens160 ipv4.dns "8.8.8.8"; nmcli con up ens160"
ssh root@192.168.1.191 "nmcli con mod ens160 ipv4.addresses 192.168.1.23/24; nmcli con mod ens160 ipv4.gateway  192.168.1.1; nmcli con mod ens160 ipv4.method manual; nmcli con mod ens160 ipv4.dns "8.8.8.8"; nmcli con up ens160"
ssh root@192.168.1.192 "nmcli con mod ens160 ipv4.addresses 192.168.1.24/24; nmcli con mod ens160 ipv4.gateway  192.168.1.1; nmcli con mod ens160 ipv4.method manual; nmcli con mod ens160 ipv4.dns "8.8.8.8"; nmcli con up ens160"
ssh root@192.168.1.193 "nmcli con mod ens160 ipv4.addresses 192.168.1.25/24; nmcli con mod ens160 ipv4.gateway  192.168.1.1; nmcli con mod ens160 ipv4.method manual; nmcli con mod ens160 ipv4.dns "8.8.8.8"; nmcli con up ens160"


# 参数解释
# 
# ssh root@192.168.1.189
# 使用SSH登录到IP为192.168.1.189的主机，使用root用户身份。
# 
# "nmcli con mod ens160 ipv4.addresses 192.168.1.21/24"
# 修改ens160网络连接的IPv4地址为192.168.1.21，子网掩码为 24。
# 
# "nmcli con mod ens160 ipv4.gateway 192.168.1.1"
# 修改ens160网络连接的IPv4网关为192.168.1.1。
# 
# "nmcli con mod ens160 ipv4.method manual"
# 将ens160网络连接的IPv4配置方法设置为手动。
# 
# "nmcli con mod ens160 ipv4.dns "8.8.8.8"
# 将ens160网络连接的IPv4 DNS服务器设置为 8.8.8.8。
# 
# "nmcli con up ens160"
# 启动ens160网络连接。
# 
# 总体来说，这条命令是通过SSH远程登录到指定的主机，并使用网络管理命令 (nmcli) 修改ens160网络连接的配置，包括IP地址、网关、配置方法和DNS服务器，并启动该网络连接。

# 我这里有公网的IPv6的地址，但是是DHCP动态的，无法固定，使用不方便
# 所以我配置了内网的IPv6地址，可以实现固定的访问地址

# 我使用的方式。只配置IPv6地址不配置网关DNS
ssh root@192.168.1.21 "nmcli con mod ens160 ipv6.addresses fc00::21/8; nmcli con up ens160"
ssh root@192.168.1.22 "nmcli con mod ens160 ipv6.addresses fc00::22/8; nmcli con up ens160"
ssh root@192.168.1.23 "nmcli con mod ens160 ipv6.addresses fc00::23/8; nmcli con up ens160"
ssh root@192.168.1.24 "nmcli con mod ens160 ipv6.addresses fc00::24/8; nmcli con up ens160"
ssh root@192.168.1.25 "nmcli con mod ens160 ipv6.addresses fc00::25/8; nmcli con up ens160"

# IPv6地址路由DNS，样例
ssh root@192.168.1.21 "nmcli con mod ens160 ipv6.addresses fc00:43f4:1eea:1::10; nmcli con mod ens160 ipv6.gateway fc00:43f4:1eea:1::1; nmcli con mod ens160 ipv6.method manual; nmcli con mod ens160 ipv6.dns "2400:3200::1"; nmcli con up ens160"
ssh root@192.168.1.22 "nmcli con mod ens160 ipv6.addresses fc00:43f4:1eea:1::20; nmcli con mod ens160 ipv6.gateway fc00:43f4:1eea:1::1; nmcli con mod ens160 ipv6.method manual; nmcli con mod ens160 ipv6.dns "2400:3200::1"; nmcli con up ens160"
ssh root@192.168.1.23 "nmcli con mod ens160 ipv6.addresses fc00:43f4:1eea:1::30; nmcli con mod ens160 ipv6.gateway fc00:43f4:1eea:1::1; nmcli con mod ens160 ipv6.method manual; nmcli con mod ens160 ipv6.dns "2400:3200::1"; nmcli con up ens160"
ssh root@192.168.1.24 "nmcli con mod ens160 ipv6.addresses fc00:43f4:1eea:1::40; nmcli con mod ens160 ipv6.gateway fc00:43f4:1eea:1::1; nmcli con mod ens160 ipv6.method manual; nmcli con mod ens160 ipv6.dns "2400:3200::1"; nmcli con up ens160"
ssh root@192.168.1.25 "nmcli con mod ens160 ipv6.addresses fc00:43f4:1eea:1::50; nmcli con mod ens160 ipv6.gateway fc00:43f4:1eea:1::1; nmcli con mod ens160 ipv6.method manual; nmcli con mod ens160 ipv6.dns "2400:3200::1"; nmcli con up ens160"

# 参数解释
# 
# ssh root@192.168.1.21
# 通过SSH连接到IP地址为192.168.1.21的远程主机，使用root用户进行登录。
# 
# "nmcli con mod ens160 ipv6.addresses fc00:43f4:1eea:1::10"
# 使用nmcli命令修改ens160接口的IPv6地址为fc00:43f4:1eea:1::10。
# 
# "nmcli con mod ens160 ipv6.gateway fc00:43f4:1eea:1::1"
# 使用nmcli命令修改ens160接口的IPv6网关为fc00:43f4:1eea:1::1。
# 
# "nmcli con mod ens160 ipv6.method manual"
# 使用nmcli命令将ens160接口的IPv6配置方法修改为手动配置。
# 
# "nmcli con mod ens160 ipv6.dns "2400:3200::1"
# 使用nmcli命令设置ens160接口的IPv6 DNS服务器为2400:3200::1。
# 
# "nmcli con up ens160"
# 使用nmcli命令启动ens160接口。
# 
# 这个命令的目的是在远程主机上配置ens160接口的IPv6地址、网关、配置方法和DNS服务器，并启动ens160接口。

# 查看网卡配置
# nmcli device show ens160
# nmcli con show ens160
[root@localhost ~]#  cat /etc/NetworkManager/system-connections/ens160.nmconnection 
[connection]
id=ens160
uuid=d199c6e0-4212-4bf8-9a7b-a2da247ca759
type=ethernet
interface-name=ens160
timestamp=1742703386

[ethernet]

[ipv4]
address1=192.168.1.21/24,192.168.1.1
dns=192.168.1.99;
method=manual

[ipv6]
addr-gen-mode=default
address1=fc00::21/8
method=auto

[proxy]


```

### 设置主机名

```shell
hostnamectl set-hostname k8s-master01
hostnamectl set-hostname k8s-master02
hostnamectl set-hostname k8s-master03
hostnamectl set-hostname k8s-node01
hostnamectl set-hostname k8s-node02
```

### 配置yum源

```shell
# 其他系统的源地址
# https://help.mirrors.cernet.edu.cn/

# 对于私有仓库
sed -e 's|^mirrorlist=|#mirrorlist=|g' -e 's|^#baseurl=http://mirror.centos.org/\$contentdir|baseurl=http://192.168.1.123/centos|g' -i.bak  /etc/yum.repos.d/CentOS-*.repo

# 对于 Ubuntu
sed -i 's/cn.archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

# epel扩展源
sudo yum install -y epel-release
sudo sed -e 's!^metalink=!#metalink=!g' \
    -e 's!^#baseurl=!baseurl=!g' \
    -e 's!https\?://download\.fedoraproject\.org/pub/epel!https://mirror.nju.edu.cn/epel!g' \
    -e 's!https\?://download\.example/pub/epel!https://mirror.nju.edu.cn/epel!g' \
    -i /etc/yum.repos.d/epel{,-testing}.repo

# 对于 CentOS 7
sudo sed -e 's|^mirrorlist=|#mirrorlist=|g' \
         -e 's|^#baseurl=http://mirror.centos.org/centos|baseurl=https://mirror.nju.edu.cn/centos|g' \
         -i.bak \
         /etc/yum.repos.d/CentOS-*.repo

# 对于 CentOS 8
sudo sed -e 's|^mirrorlist=|#mirrorlist=|g' \
         -e 's|^#baseurl=http://mirror.centos.org/$contentdir|baseurl=https://mirror.nju.edu.cn/centos|g' \
         -i.bak \
         /etc/yum.repos.d/CentOS-*.repo

# 对于CentOS 9
cat <<'EOF' > /etc/yum.repos.d/centos.repo
[baseos]
name=CentOS Stream $releasever - BaseOS
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-stream/$releasever-stream/BaseOS/$basearch/os
# metalink=https://mirrors.centos.org/metalink?repo=centos-baseos-$stream&arch=$basearch&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
countme=1
enabled=1

[baseos-debuginfo]
name=CentOS Stream $releasever - BaseOS - Debug
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-stream/$releasever-stream/BaseOS/$basearch/debug/tree/
# metalink=https://mirrors.centos.org/metalink?repo=centos-baseos-debug-$stream&arch=$basearch&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
enabled=0

[baseos-source]
name=CentOS Stream $releasever - BaseOS - Source
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-stream/$releasever-stream/BaseOS/source/tree/
# metalink=https://mirrors.centos.org/metalink?repo=centos-baseos-source-$stream&arch=source&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
enabled=0

[appstream]
name=CentOS Stream $releasever - AppStream
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-stream/$releasever-stream/AppStream/$basearch/os
# metalink=https://mirrors.centos.org/metalink?repo=centos-appstream-$stream&arch=$basearch&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
countme=1
enabled=1

[appstream-debuginfo]
name=CentOS Stream $releasever - AppStream - Debug
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-stream/$releasever-stream/AppStream/$basearch/debug/tree/
# metalink=https://mirrors.centos.org/metalink?repo=centos-appstream-debug-$stream&arch=$basearch&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
enabled=0

[appstream-source]
name=CentOS Stream $releasever - AppStream - Source
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-stream/$releasever-stream/AppStream/source/tree/
# metalink=https://mirrors.centos.org/metalink?repo=centos-appstream-source-$stream&arch=source&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
enabled=0

[crb]
name=CentOS Stream $releasever - CRB
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-stream/$releasever-stream/CRB/$basearch/os
# metalink=https://mirrors.centos.org/metalink?repo=centos-crb-$stream&arch=$basearch&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
countme=1
enabled=1

[crb-debuginfo]
name=CentOS Stream $releasever - CRB - Debug
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-stream/$releasever-stream/CRB/$basearch/debug/tree/
# metalink=https://mirrors.centos.org/metalink?repo=centos-crb-debug-$stream&arch=$basearch&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
enabled=0

[crb-source]
name=CentOS Stream $releasever - CRB - Source
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-stream/$releasever-stream/CRB/source/tree/
# metalink=https://mirrors.centos.org/metalink?repo=centos-crb-source-$stream&arch=source&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
enabled=0
EOF

cat <<'EOF' > /etc/yum.repos.d/centos-addons.repo
[highavailability]
name=CentOS Stream $releasever - HighAvailability
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-stream/$releasever-stream/HighAvailability/$basearch/os
# metalink=https://mirrors.centos.org/metalink?repo=centos-highavailability-$stream&arch=$basearch&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
countme=1
enabled=0

[highavailability-debuginfo]
name=CentOS Stream $releasever - HighAvailability - Debug
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-stream/$releasever-stream/HighAvailability/$basearch/debug/tree/
# metalink=https://mirrors.centos.org/metalink?repo=centos-highavailability-debug-$stream&arch=$basearch&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
enabled=0

[highavailability-source]
name=CentOS Stream $releasever - HighAvailability - Source
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-stream/$releasever-stream/HighAvailability/source/tree/
# metalink=https://mirrors.centos.org/metalink?repo=centos-highavailability-source-$stream&arch=source&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
enabled=0

[nfv]
name=CentOS Stream $releasever - NFV
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-stream/$releasever-stream/NFV/$basearch/os
# metalink=https://mirrors.centos.org/metalink?repo=centos-nfv-$stream&arch=$basearch&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
countme=1
enabled=0

[nfv-debuginfo]
name=CentOS Stream $releasever - NFV - Debug
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-stream/$releasever-stream/NFV/$basearch/debug/tree/
# metalink=https://mirrors.centos.org/metalink?repo=centos-nfv-debug-$stream&arch=$basearch&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
enabled=0

[nfv-source]
name=CentOS Stream $releasever - NFV - Source
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-stream/$releasever-stream/NFV/source/tree/
# metalink=https://mirrors.centos.org/metalink?repo=centos-nfv-source-$stream&arch=source&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
enabled=0

[rt]
name=CentOS Stream $releasever - RT
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-stream/$releasever-stream/RT/$basearch/os
# metalink=https://mirrors.centos.org/metalink?repo=centos-rt-$stream&arch=$basearch&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
countme=1
enabled=0

[rt-debuginfo]
name=CentOS Stream $releasever - RT - Debug
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-stream/$releasever-stream/RT/$basearch/debug/tree/
# metalink=https://mirrors.centos.org/metalink?repo=centos-rt-debug-$stream&arch=$basearch&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
enabled=0

[rt-source]
name=CentOS Stream $releasever - RT - Source
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-stream/$releasever-stream/RT/source/tree/
# metalink=https://mirrors.centos.org/metalink?repo=centos-rt-source-$stream&arch=source&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
enabled=0

[resilientstorage]
name=CentOS Stream $releasever - ResilientStorage
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-stream/$releasever-stream/ResilientStorage/$basearch/os
# metalink=https://mirrors.centos.org/metalink?repo=centos-resilientstorage-$stream&arch=$basearch&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
countme=1
enabled=0

[resilientstorage-debuginfo]
name=CentOS Stream $releasever - ResilientStorage - Debug
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-stream/$releasever-stream/ResilientStorage/$basearch/debug/tree/
# metalink=https://mirrors.centos.org/metalink?repo=centos-resilientstorage-debug-$stream&arch=$basearch&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
enabled=0

[resilientstorage-source]
name=CentOS Stream $releasever - ResilientStorage - Source
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-stream/$releasever-stream/ResilientStorage/source/tree/
# metalink=https://mirrors.centos.org/metalink?repo=centos-resilientstorage-source-$stream&arch=source&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
enabled=0

[extras-common]
name=CentOS Stream $releasever - Extras packages
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-stream/SIGs/$releasever-stream/extras/$basearch/extras-common
# metalink=https://mirrors.centos.org/metalink?repo=centos-extras-sig-extras-common-$stream&arch=$basearch&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Extras-SHA512
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
countme=1
enabled=1

[extras-common-source]
name=CentOS Stream $releasever - Extras packages - Source
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-stream/SIGs/$releasever-stream/extras/source/extras-common
# metalink=https://mirrors.centos.org/metalink?repo=centos-extras-sig-extras-common-source-$stream&arch=source&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Extras-SHA512
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
enabled=0
EOF
```

### 安装一些必备工具

```shell
# 对于 Ubuntu
apt update && apt upgrade -y && apt install -y wget psmisc vim net-tools nfs-kernel-server telnet lvm2 git tar curl

# 对于 CentOS 7
yum update -y && yum -y install  wget psmisc vim net-tools nfs-utils telnet yum-utils device-mapper-persistent-data lvm2 git tar curl

# 对于 CentOS 8
yum update -y && yum -y install wget psmisc vim net-tools nfs-utils telnet yum-utils device-mapper-persistent-data lvm2 git network-scripts tar curl

# 对于 CentOS 9
yum update -y && yum -y install wget psmisc vim net-tools nfs-utils telnet yum-utils device-mapper-persistent-data lvm2 git tar curl
```

### 关闭防火墙

```shell
# Ubuntu忽略，CentOS执行
systemctl disable --now firewalld
```

### 关闭SELinux

```shell
# Ubuntu忽略，CentOS执行
setenforce 0
sed -i 's#SELINUX=enforcing#SELINUX=disabled#g' /etc/selinux/config
```

### 关闭交换分区

```shell
sed -ri 's/.*swap.*/#&/' /etc/fstab
swapoff -a && sysctl -w vm.swappiness=0

cat /etc/fstab
# /dev/mapper/centos-swap swap                    swap    defaults        0 0
```

### 网络配置（俩种方式二选一）

```shell
# Ubuntu忽略，CentOS执行，CentOS9不支持方式一

# 方式一
# systemctl disable --now NetworkManager
# systemctl start network && systemctl enable network

# 方式二
cat > /etc/NetworkManager/conf.d/calico.conf << EOF 
[keyfile]
unmanaged-devices=interface-name:cali*;interface-name:tunl*
EOF
systemctl restart NetworkManager

# 参数解释
#
# 这个参数用于指定不由 NetworkManager 管理的设备。它由以下两个部分组成
# 
# interface-name:cali*
# 表示以 "cali" 开头的接口名称被排除在 NetworkManager 管理之外。例如，"cali0", "cali1" 等接口不受 NetworkManager 管理。
# 
# interface-name:tunl*
# 表示以 "tunl" 开头的接口名称被排除在 NetworkManager 管理之外。例如，"tunl0", "tunl1" 等接口不受 NetworkManager 管理。
# 
# 通过使用这个参数，可以将特定的接口排除在 NetworkManager 的管理范围之外，以便其他工具或进程可以独立地管理和配置这些接口。
```


### 进行时间同步

```shell
# 服务端
# apt install chrony -y
yum install chrony -y
cat > /etc/chrony.conf << EOF 
pool ntp.aliyun.com iburst
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
allow 192.168.1.0/24
local stratum 10
keyfile /etc/chrony.keys
leapsectz right/UTC
logdir /var/log/chrony
EOF

systemctl restart chronyd ; systemctl enable chronyd

# 客户端
# apt install chrony -y
yum install chrony -y
cat > /etc/chrony.conf << EOF 
pool 192.168.1.21 iburst
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
keyfile /etc/chrony.keys
leapsectz right/UTC
logdir /var/log/chrony
EOF

systemctl restart chronyd ; systemctl enable chronyd

#使用客户端进行验证
chronyc sources -v

# 参数解释
#
# pool ntp.aliyun.com iburst
# 指定使用ntp.aliyun.com作为时间服务器池，iburst选项表示在初始同步时会发送多个请求以加快同步速度。
# 
# driftfile /var/lib/chrony/drift
# 指定用于保存时钟漂移信息的文件路径。
# 
# makestep 1.0 3
# 设置当系统时间与服务器时间偏差大于1秒时，会以1秒的步长进行调整。如果偏差超过3秒，则立即进行时间调整。
# 
# rtcsync
# 启用硬件时钟同步功能，可以提高时钟的准确性。
# 
# allow 192.168.0.0/24
# 允许192.168.0.0/24网段范围内的主机与chrony进行时间同步。
# 
# local stratum 10
# 将本地时钟设为stratum 10，stratum值表示时钟的准确度，值越小表示准确度越高。
# 
# keyfile /etc/chrony.keys
# 指定使用的密钥文件路径，用于对时间同步进行身份验证。
# 
# leapsectz right/UTC
# 指定时区为UTC。
# 
# logdir /var/log/chrony
# 指定日志文件存放目录。
```

### 配置ulimit

```shell
ulimit -SHn 65535
cat >> /etc/security/limits.conf <<EOF
* soft nofile 655360
* hard nofile 131072
* soft nproc 655350
* hard nproc 655350
* seft memlock unlimited
* hard memlock unlimitedd
EOF

# 参数解释
#
# soft nofile 655360
# soft表示软限制，nofile表示一个进程可打开的最大文件数，默认值为1024。这里的软限制设置为655360，即一个进程可打开的最大文件数为655360。
#
# hard nofile 131072
# hard表示硬限制，即系统设置的最大值。nofile表示一个进程可打开的最大文件数，默认值为4096。这里的硬限制设置为131072，即系统设置的最大文件数为131072。
#
# soft nproc 655350
# soft表示软限制，nproc表示一个用户可创建的最大进程数，默认值为30720。这里的软限制设置为655350，即一个用户可创建的最大进程数为655350。
#
# hard nproc 655350
# hard表示硬限制，即系统设置的最大值。nproc表示一个用户可创建的最大进程数，默认值为4096。这里的硬限制设置为655350，即系统设置的最大进程数为655350。
#
# seft memlock unlimited
# seft表示软限制，memlock表示一个进程可锁定在RAM中的最大内存，默认值为64 KB。这里的软限制设置为unlimited，即一个进程可锁定的最大内存为无限制。
#
# hard memlock unlimited
# hard表示硬限制，即系统设置的最大值。memlock表示一个进程可锁定在RAM中的最大内存，默认值为64 KB。这里的硬限制设置为unlimited，即系统设置的最大内存锁定为无限制。
```


### 配置免密登录

```shell
# apt install -y sshpass
yum install -y sshpass
ssh-keygen -f /root/.ssh/id_rsa -P ''
export IP="192.168.1.21 192.168.1.22 192.168.1.23 192.168.1.24 192.168.1.25"
export SSHPASS=123123
for HOST in $IP;do
     sshpass -e ssh-copy-id -o StrictHostKeyChecking=no $HOST
done

# 这段脚本的作用是在一台机器上安装sshpass工具，并通过sshpass自动将本机的SSH公钥复制到多个远程主机上，以实现无需手动输入密码的SSH登录。
# 
# 具体解释如下：
# 
# 1. `apt install -y sshpass` 或 `yum install -y sshpass`：通过包管理器（apt或yum）安装sshpass工具，使得后续可以使用sshpass命令。
# 
# 2. `ssh-keygen -f /root/.ssh/id_rsa -P ''`：生成SSH密钥对。该命令会在/root/.ssh目录下生成私钥文件id_rsa和公钥文件id_rsa.pub，同时不设置密码（即-P参数后面为空），方便后续通过ssh-copy-id命令自动复制公钥。
# 
# 3. `export IP="192.168.1.21 192.168.1.22 192.168.1.23 192.168.1.24 192.168.1.25"`：设置一个包含多个远程主机IP地址的环境变量IP，用空格分隔开，表示要将SSH公钥复制到这些远程主机上。
# 
# 4. `export SSHPASS=123123`：设置环境变量SSHPASS，将sshpass所需的SSH密码（在这里是"123123"）赋值给它，这样sshpass命令可以自动使用这个密码进行登录。
# 
# 5. `for HOST in $IP;do`：遍历环境变量IP中的每个IP地址，并将当前IP地址赋值给变量HOST。
# 
# 6. `sshpass -e ssh-copy-id -o StrictHostKeyChecking=no $HOST`：使用sshpass工具复制本机的SSH公钥到远程主机。其中，-e选项表示使用环境变量中的密码（即SSHPASS）进行登录，-o StrictHostKeyChecking=no选项表示连接时不检查远程主机的公钥，以避免交互式确认。
# 
# 通过这段脚本，可以方便地将本机的SSH公钥复制到多个远程主机上，实现无需手动输入密码的SSH登录。
```

### 添加启用源

```shell
# Ubuntu忽略，CentOS执行

# 为 RHEL-9 SL-9 或 CentOS-9 安装 ELRepo 
yum install https://www.elrepo.org/elrepo-release-9.el9.elrepo.noarch.rpm -y 
sed -i "s@mirrorlist@#mirrorlist@g" /etc/yum.repos.d/elrepo.repo 
sed -i "s@elrepo.org/linux@mirrors.tuna.tsinghua.edu.cn/elrepo@g" /etc/yum.repos.d/elrepo.repo 

# 为 RHEL-8或 CentOS-8配置源
yum install https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm -y 
sed -i "s@mirrorlist@#mirrorlist@g" /etc/yum.repos.d/elrepo.repo 
sed -i "s@elrepo.org/linux@mirrors.tuna.tsinghua.edu.cn/elrepo@g" /etc/yum.repos.d/elrepo.repo 

# 为 RHEL-7 SL-7 或 CentOS-7 安装 ELRepo 
yum install https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm -y 
sed -i "s@mirrorlist@#mirrorlist@g" /etc/yum.repos.d/elrepo.repo 
sed -i "s@elrepo.org/linux@mirrors.tuna.tsinghua.edu.cn/elrepo@g" /etc/yum.repos.d/elrepo.repo 

# 查看可用安装包
yum  --disablerepo="*"  --enablerepo="elrepo-kernel"  list  available
```

### 升级内核至4.18版本以上

```shell
# Ubuntu忽略，CentOS执行

# 安装最新的内核
# 我这里选择的是稳定版kernel-ml   如需更新长期维护版本kernel-lt  
yum -y --enablerepo=elrepo-kernel  install  kernel-ml

# 查看已安装那些内核
rpm -qa | grep kernel

# 查看默认内核
grubby --default-kernel

# 若不是最新的使用命令设置
grubby --set-default $(ls /boot/vmlinuz-* | grep elrepo)

# 重启生效
reboot

# v8 整合命令为：
yum install https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm -y ; sed -i "s@mirrorlist@#mirrorlist@g" /etc/yum.repos.d/elrepo.repo ; sed -i "s@elrepo.org/linux@mirrors.tuna.tsinghua.edu.cn/elrepo@g" /etc/yum.repos.d/elrepo.repo ; yum  --disablerepo="*"  --enablerepo="elrepo-kernel"  list  available -y ; yum  --enablerepo=elrepo-kernel  install kernel-lt -y ; grubby --default-kernel ; reboot 

# v7 整合命令为：
yum install https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm -y ; sed -i "s@mirrorlist@#mirrorlist@g" /etc/yum.repos.d/elrepo.repo ; sed -i "s@elrepo.org/linux@mirrors.tuna.tsinghua.edu.cn/elrepo@g" /etc/yum.repos.d/elrepo.repo ; yum  --disablerepo="*"  --enablerepo="elrepo-kernel"  list  available -y ; yum  --enablerepo=elrepo-kernel  install  kernel-lt -y ; grubby --set-default $(ls /boot/vmlinuz-* | grep elrepo) ; grubby --default-kernel ; reboot 

# 离线版本 
yum install -y /root/cby/kernel-lt-*-1.el7.elrepo.x86_64.rpm ; grubby --set-default $(ls /boot/vmlinuz-* | grep elrepo) ; grubby --default-kernel ; reboot 
```



### 安装ipvsadm

```shell
# 对于CentOS7离线安装
# yum install /root/centos7/ipset-*.el7.x86_64.rpm /root/centos7/lm_sensors-libs-*.el7.x86_64.rpm  /root/centos7/ipset-libs-*.el7.x86_64.rpm /root/centos7/sysstat-*.el7_9.x86_64.rpm  /root/centos7/ipvsadm-*.el7.x86_64.rpm  -y

# 对于 Ubuntu
# apt install ipvsadm ipset sysstat conntrack -y

# 对于 CentOS
yum install ipvsadm ipset sysstat conntrack libseccomp -y
cat >> /etc/modules-load.d/ipvs.conf <<EOF 
ip_vs
ip_vs_rr
ip_vs_wrr
ip_vs_sh
nf_conntrack
ip_tables
ip_set
xt_set
ipt_set
ipt_rpfilter
ipt_REJECT
ipip
EOF

systemctl restart systemd-modules-load.service

lsmod | grep -e ip_vs -e nf_conntrack
ip_vs_sh               16384  0
ip_vs_wrr              16384  0
ip_vs_rr               16384  0
ip_vs                 237568  6 ip_vs_rr,ip_vs_sh,ip_vs_wrr
nf_conntrack          217088  3 nf_nat,nft_ct,ip_vs
nf_defrag_ipv6         24576  2 nf_conntrack,ip_vs
nf_defrag_ipv4         16384  1 nf_conntrack
libcrc32c              16384  5 nf_conntrack,nf_nat,nf_tables,xfs,ip_vs

# 参数解释
#
# ip_vs
# IPVS 是 Linux 内核中的一个模块，用于实现负载均衡和高可用性。它通过在前端代理服务器上分发传入请求到后端实际服务器上，提供了高性能和可扩展的网络服务。
#
# ip_vs_rr
# IPVS 的一种调度算法之一，使用轮询方式分发请求到后端服务器，每个请求按顺序依次分发。
#
# ip_vs_wrr
# IPVS 的一种调度算法之一，使用加权轮询方式分发请求到后端服务器，每个请求按照指定的权重比例分发。
#
# ip_vs_sh
# IPVS 的一种调度算法之一，使用哈希方式根据源 IP 地址和目标 IP 地址来分发请求。
#
# nf_conntrack
# 这是一个内核模块，用于跟踪和管理网络连接，包括 TCP、UDP 和 ICMP 等协议。它是实现防火墙状态跟踪的基础。
#
# ip_tables
# 这是一个内核模块，提供了对 Linux 系统 IP 数据包过滤和网络地址转换（NAT）功能的支持。
#
# ip_set
# 这是一个内核模块，扩展了 iptables 的功能，支持更高效的 IP 地址集合操作。
#
# xt_set
# 这是一个内核模块，扩展了 iptables 的功能，支持更高效的数据包匹配和操作。
#
# ipt_set
# 这是一个用户空间工具，用于配置和管理 xt_set 内核模块。
#
# ipt_rpfilter
# 这是一个内核模块，用于实现反向路径过滤，用于防止 IP 欺骗和 DDoS 攻击。
#
# ipt_REJECT
# 这是一个 iptables 目标，用于拒绝 IP 数据包，并向发送方发送响应，指示数据包被拒绝。
#
# ipip
# 这是一个内核模块，用于实现 IP 封装在 IP（IP-over-IP）的隧道功能。它可以在不同网络之间创建虚拟隧道来传输 IP 数据包。
```

### 修改内核参数

```shell
cat <<EOF > /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
fs.may_detach_mounts = 1
vm.overcommit_memory=1
vm.panic_on_oom=0
fs.inotify.max_user_watches=89100
fs.file-max=52706963
fs.nr_open=52706963
net.netfilter.nf_conntrack_max=2310720

net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.tcp_keepalive_intvl =15
net.ipv4.tcp_max_tw_buckets = 36000
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_max_orphans = 327680
net.ipv4.tcp_orphan_retries = 3
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.ip_conntrack_max = 65536
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_timestamps = 0
net.core.somaxconn = 16384

net.ipv6.conf.all.disable_ipv6 = 0
net.ipv6.conf.default.disable_ipv6 = 0
net.ipv6.conf.lo.disable_ipv6 = 0
net.ipv6.conf.all.forwarding = 1
EOF

sysctl --system

# 这些是Linux系统的一些参数设置，用于配置和优化网络、文件系统和虚拟内存等方面的功能。以下是每个参数的详细解释：
# 
# 1. net.ipv4.ip_forward = 1
#    - 这个参数启用了IPv4的IP转发功能，允许服务器作为网络路由器转发数据包。
# 
# 2. net.bridge.bridge-nf-call-iptables = 1
#    - 当使用网络桥接技术时，将数据包传递到iptables进行处理。
#   
# 3. fs.may_detach_mounts = 1
#    - 允许在挂载文件系统时，允许被其他进程使用。
#   
# 4. vm.overcommit_memory=1
#    - 该设置允许原始的内存过量分配策略，当系统的内存已经被完全使用时，系统仍然会分配额外的内存。
# 
# 5. vm.panic_on_oom=0
#    - 当系统内存不足（OOM）时，禁用系统崩溃和重启。
# 
# 6. fs.inotify.max_user_watches=89100
#    - 设置系统允许一个用户的inotify实例可以监控的文件数目的上限。
# 
# 7. fs.file-max=52706963
#    - 设置系统同时打开的文件数的上限。
# 
# 8. fs.nr_open=52706963
#    - 设置系统同时打开的文件描述符数的上限。
# 
# 9. net.netfilter.nf_conntrack_max=2310720
#    - 设置系统可以创建的网络连接跟踪表项的最大数量。
# 
# 10. net.ipv4.tcp_keepalive_time = 600
#     - 设置TCP套接字的空闲超时时间（秒），超过该时间没有活动数据时，内核会发送心跳包。
# 
# 11. net.ipv4.tcp_keepalive_probes = 3
#     - 设置未收到响应的TCP心跳探测次数。
# 
# 12. net.ipv4.tcp_keepalive_intvl = 15
#     - 设置TCP心跳探测的时间间隔（秒）。
# 
# 13. net.ipv4.tcp_max_tw_buckets = 36000
#     - 设置系统可以使用的TIME_WAIT套接字的最大数量。
# 
# 14. net.ipv4.tcp_tw_reuse = 1
#     - 启用TIME_WAIT套接字的重新利用，允许新的套接字使用旧的TIME_WAIT套接字。
# 
# 15. net.ipv4.tcp_max_orphans = 327680
#     - 设置系统可以同时存在的TCP套接字垃圾回收包裹数的最大数量。
# 
# 16. net.ipv4.tcp_orphan_retries = 3
#     - 设置系统对于孤立的TCP套接字的重试次数。
# 
# 17. net.ipv4.tcp_syncookies = 1
#     - 启用TCP SYN cookies保护，用于防止SYN洪泛攻击。
# 
# 18. net.ipv4.tcp_max_syn_backlog = 16384
#     - 设置新的TCP连接的半连接数（半连接队列）的最大长度。
# 
# 19. net.ipv4.ip_conntrack_max = 65536
#     - 设置系统可以创建的网络连接跟踪表项的最大数量。
# 
# 20. net.ipv4.tcp_timestamps = 0
#     - 关闭TCP时间戳功能，用于提供更好的安全性。
# 
# 21. net.core.somaxconn = 16384
#     - 设置系统核心层的连接队列的最大值。
# 
# 22. net.ipv6.conf.all.disable_ipv6 = 0
#     - 启用IPv6协议。
# 
# 23. net.ipv6.conf.default.disable_ipv6 = 0
#     - 启用IPv6协议。
# 
# 24. net.ipv6.conf.lo.disable_ipv6 = 0
#     - 启用IPv6协议。
# 
# 25. net.ipv6.conf.all.forwarding = 1
#     - 允许IPv6数据包转发。
```


### 所有节点配置hosts本地解析

```shell
cat > /etc/hosts <<EOF
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

192.168.1.21 k8s-master01
192.168.1.22 k8s-master02
192.168.1.23 k8s-master03
192.168.1.24 k8s-node01
192.168.1.25 k8s-node02
192.168.1.36 lb-vip

fc00::21 k8s-master01
fc00::22 k8s-master02
fc00::23 k8s-master03
fc00::24 k8s-node01
fc00::25 k8s-node02
EOF
```

## 配置kubernetes安装源

##### Debian / Ubuntu

1. 在配置中添加镜像（注意修改为自己需要的版本号）：

```shell
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

cat <<EOF | tee /etc/apt/sources.list.d/kubernetes.list
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://mirrors.tuna.tsinghua.edu.cn/kubernetes/core:/stable:/v1.32/deb/ /
# deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://mirrors.tuna.tsinghua.edu.cn/kubernetes/addons:/cri-o:/stable:/v1.32/deb/ /
EOF
```

2. 安装必要应用：

```shell
apt-get update
apt-get install -y kubelet kubeadm kubectl
systemctl enable kubelet && systemctl start kubelet

# 如安装指定版本
# apt install kubelet=1.28.2-00 kubeadm=1.28.2-00 kubectl=1.28.2-00
```

##### CentOS / RHEL / Fedora

1. 执行如下命令（注意修改为自己需要的版本号）：

```shell
cat <<EOF | tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=kubernetes
baseurl=https://mirrors.tuna.tsinghua.edu.cn/kubernetes/yum/repos/kubernetes-el7-$basearch
name=Kubernetes
baseurl=https://mirrors.tuna.tsinghua.edu.cn/kubernetes/core:/stable:/v1.32/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/repodata/repomd.xml.key

[cri-o]
name=CRI-O
baseurl=https://mirrors.tuna.tsinghua.edu.cn/kubernetes/addons:/cri-o:/stable:/v1.32/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/addons:/cri-o:/prerelease:/main/rpm/repodata/repomd.xml.key
EOF
```
2. 安装必要应用：

```shell
yum update
yum install -y kubelet kubeadm kubectl

# 如安装指定版本
# yum install kubelet-1.28.2-0 kubeadm-1.28.2-0 kubectl-1.28.2-0

systemctl enable kubelet && systemctl start kubelet

# 将 SELinux 设置为 禁用
setenforce 0
sed -i 's#SELINUX=enforcing#SELINUX=disabled#g' /etc/selinux/config
```

ps: 由于官网未开放同步方式, 可能会有索引gpg检查失败的情况, 这时请用 `yum install -y --nogpgcheck kubelet kubeadm kubectl` 安装


# k8s基本组件安装

**注意 ：二选其一即可**

## 安装Containerd作为Runtime

```shell
# https://github.com/containernetworking/plugins/releases/
wget https://mirrors.chenby.cn/https://github.com/containernetworking/plugins/releases/download/v1.6.2/cni-plugins-linux-amd64-v1.6.2.tgz


#创建cni插件所需目录
mkdir -p /etc/cni/net.d /opt/cni/bin 
#解压cni二进制包
tar xf cni-plugins-linux-amd64-v*.tgz -C /opt/cni/bin/

# https://github.com/containerd/containerd/releases/
wget https://mirrors.chenby.cn/https://github.com/containerd/containerd/releases/download/v2.0.4/containerd-2.0.4-linux-amd64.tar.gz

#解压
tar -xzf containerd-*-linux-amd64.tar.gz -C /usr/local/

#创建服务启动文件
cat > /etc/systemd/system/containerd.service <<EOF
[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target local-fs.target

[Service]
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/local/bin/containerd
Type=notify
Delegate=yes
KillMode=process
Restart=always
RestartSec=5
LimitNPROC=infinity
LimitCORE=infinity
LimitNOFILE=infinity
TasksMax=infinity
OOMScoreAdjust=-999

[Install]
WantedBy=multi-user.target
EOF


# 参数解释：
#
# 这是一个用于启动containerd容器运行时的systemd unit文件。下面是对该文件不同部分的详细解释：
# 
# [Unit]
# Description=containerd container runtime
# 描述该unit的作用是作为containerd容器运行时。
# 
# Documentation=https://containerd.io
# 指向容器运行时的文档的URL。
# 
# After=network.target local-fs.target
# 定义了在哪些依赖项之后该unit应该被启动。在网络和本地文件系统加载完成后启动，确保了容器运行时在这些依赖项可用时才会启动。
# 
# [Service]
# ExecStartPre=-/sbin/modprobe overlay
# 在启动containerd之前执行的命令。这里的命令是尝试加载内核的overlay模块，如果失败则忽略错误继续执行下面的命令。
# 
# ExecStart=/usr/local/bin/containerd
# 实际执行的命令，用于启动containerd容器运行时。
# 
# Type=notify
# 指定服务的通知类型。这里使用notify类型，表示当服务就绪时会通过通知的方式告知systemd。
# 
# Delegate=yes
# 允许systemd对此服务进行重启和停止操作。
# 
# KillMode=process
# 在终止容器运行时时使用的kill模式。这里使用process模式，表示通过终止进程来停止容器运行时。
# 
# Restart=always
# 定义了当容器运行时终止后的重启策略。这里设置为always，表示无论何时终止容器运行时，都会自动重新启动。
# 
# RestartSec=5
# 在容器运行时终止后重新启动之前等待的秒数。
# 
# LimitNPROC=infinity
# 指定容器运行时可以使用的最大进程数量。这里设置为无限制。
# 
# LimitCORE=infinity
# 指定容器运行时可以使用的最大CPU核心数量。这里设置为无限制。
# 
# LimitNOFILE=infinity
# 指定容器运行时可以打开的最大文件数。这里设置为无限制。
# 
# TasksMax=infinity
# 指定容器运行时可以创建的最大任务数。这里设置为无限制。
# 
# OOMScoreAdjust=-999
# 指定容器运行时的OOM（Out-Of-Memory）分数调整值。负数值表示容器运行时的优先级较高。
# 
# [Install]
# WantedBy=multi-user.target
# 定义了服务的安装位置。这里指定为multi-user.target，表示将服务安装为多用户模式下的启动项。
```

### 配置Containerd所需的模块

```shell
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

# 参数解释：
#
# containerd是一个容器运行时，用于管理和运行容器。它支持多种不同的参数配置来自定义容器运行时的行为和功能。
# 
# 1. overlay：overlay是容器d默认使用的存储驱动，它提供了一种轻量级的、可堆叠的、逐层增量的文件系统。它通过在现有文件系统上叠加文件系统层来创建容器的文件系统视图。每个容器可以有自己的一组文件系统层，这些层可以共享基础镜像中的文件，并在容器内部进行修改。使用overlay可以有效地使用磁盘空间，并使容器更加轻量级。
# 
# 2. br_netfilter：br_netfilter是Linux内核提供的一个网络过滤器模块，用于在容器网络中进行网络过滤和NAT转发。当容器和主机之间的网络通信需要进行DNAT或者SNAT时，br_netfilter模块可以将IP地址进行转换。它还可以提供基于iptables规则的网络过滤功能，用于限制容器之间或容器与外部网络之间的通信。
# 
# 这些参数可以在containerd的配置文件或者命令行中指定。例如，可以通过设置--storage-driver参数来选择使用overlay作为存储驱动，通过设置--iptables参数来启用或禁用br_netfilter模块。具体的使用方法和配置细节可以参考containerd的官方文档。
```

### 加载模块

```shell
systemctl restart systemd-modules-load.service

# 参数解释：
# - `systemctl`: 是Linux系统管理服务的命令行工具，可以管理systemd init系统。
# - `restart`: 是systemctl命令的一个选项，用于重新启动服务。
# - `systemd-modules-load.service`: 是一个系统服务，用于加载内核模块。
# 
# 将上述参数结合在一起来解释`systemctl restart systemd-modules-load.service`的含义：
# 这个命令用于重新启动系统服务`systemd-modules-load.service`，它是负责加载内核模块的服务。在重新启动该服务后，系统会重新加载所有的内核模块。
```

### 配置Containerd所需的内核

```shell
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# 加载内核
sysctl --system

# 参数解释：
# 
# 这些参数是Linux操作系统中用于网络和网络桥接设置的参数。
# 
# - net.bridge.bridge-nf-call-iptables：这个参数控制网络桥接设备是否调用iptables规则处理网络数据包。当该参数设置为1时，网络数据包将被传递到iptables进行处理；当该参数设置为0时，网络数据包将绕过iptables直接传递。默认情况下，这个参数的值是1，即启用iptables规则处理网络数据包。
# 
# - net.ipv4.ip_forward：这个参数用于控制是否启用IP转发功能。IP转发使得操作系统可以将接收到的数据包从一个网络接口转发到另一个网络接口。当该参数设置为1时，启用IP转发功能；当该参数设置为0时，禁用IP转发功能。在网络环境中，通常需要启用IP转发功能来实现不同网络之间的通信。默认情况下，这个参数的值是0，即禁用IP转发功能。
# 
# - net.bridge.bridge-nf-call-ip6tables：这个参数与net.bridge.bridge-nf-call-iptables类似，但是它用于IPv6数据包的处理。当该参数设置为1时，IPv6数据包将被传递到ip6tables进行处理；当该参数设置为0时，IPv6数据包将绕过ip6tables直接传递。默认情况下，这个参数的值是1，即启用ip6tables规则处理IPv6数据包。
# 
# 这些参数的值可以通过修改操作系统的配置文件（通常是'/etc/sysctl.conf'）来进行设置。修改完成后，需要使用'sysctl -p'命令重载配置文件使参数生效。
```

### 创建Containerd的配置文件

```shell
# 参数解释：
# 
# 这段代码是用于修改并配置containerd的参数。
# 
# 1. 首先使用命令`mkdir -p /etc/containerd`创建/etc/containerd目录，如果该目录已存在，则不进行任何操作。
# 2. 使用命令`containerd config default | tee /etc/containerd/config.toml`创建默认配置文件，并将输出同时传递给/etc/containerd/config.toml文件。
# 3. 使用sed命令修改/etc/containerd/config.toml文件，将SystemdCgroup参数的值从false改为true。-i参数表示直接在原文件中进行编辑。
# 4. 使用cat命令结合grep命令查看/etc/containerd/config.toml文件中SystemdCgroup参数的值是否已修改为true。
# 5. 使用sed命令修改/etc/containerd/config.toml文件，将registry.k8s.io的地址替换为m.daocloud.io/registry.k8s.io。-i参数表示直接在原文件中进行编辑。
# 6. 使用cat命令结合grep命令查看/etc/containerd/config.toml文件中sandbox_image参数的值是否已修改为m.daocloud.io/registry.k8s.io。
# 7. 使用sed命令修改/etc/containerd/config.toml文件，将config_path参数的值从""改为"/etc/containerd/certs.d"。-i参数表示直接在原文件中进行编辑。
# 8. 使用cat命令结合grep命令查看/etc/containerd/config.toml文件中certs.d参数的值是否已修改为/etc/containerd/certs.d。
# 9. 使用mkdir命令创建/etc/containerd/certs.d/docker.io目录，如果目录已存在，则不进行任何操作。-p参数表示创建目录时，如果父级目录不存在，则自动创建父级目录。
# 
# 最后，使用cat重定向操作符将内容写入/etc/containerd/certs.d/docker.io/hosts.toml文件。该文件会配置加速器，其中server参数设置为"https://docker.io"，host参数设置为"https://hub-mirror.c.163.com"，并添加capabilities参数。

# 创建默认配置文件
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml

# 修改Containerd的配置文件

# sed -i "s#SystemdCgroup\ \=\ false#SystemdCgroup\ \=\ true#g" /etc/containerd/config.toml
# cat /etc/containerd/config.toml | grep SystemdCgroup

# 沙箱pause镜像
sed -i "s#registry.k8s.io#registry.aliyuncs.com/chenby#g" /etc/containerd/config.toml
cat /etc/containerd/config.toml | grep sandbox

# 配置加速器
[root@k8s-master01 ~]# vim /etc/containerd/config.toml
[root@k8s-master01 ~]# cat /etc/containerd/config.toml | grep certs.d -C 5

    [plugins.'io.containerd.cri.v1.images'.pinned_images]
      sandbox = 'registry.aliyuncs.com/chenby/pause:3.10'

    [plugins.'io.containerd.cri.v1.images'.registry]
      config_path = '/etc/containerd/certs.d'

    [plugins.'io.containerd.cri.v1.images'.image_decryption]
      key_model = 'node'

  [plugins.'io.containerd.cri.v1.runtime']
[root@k8s-master01 ~]# 

mkdir /etc/containerd/certs.d/docker.io -pv
cat > /etc/containerd/certs.d/docker.io/hosts.toml << EOF
server = "https://docker.io"
[host."https://xxxxxxxxxxx.com"]
  capabilities = ["pull", "resolve"]
EOF

# 注意！
# 加速地址 自己去找 我这里的地址已经失效了
# 
# SystemdCgroup参数是containerd中的一个配置参数，用于设置containerd在运行过程中使用的Cgroup（控制组）路径。Containerd使用SystemdCgroup参数来指定应该使用哪个Cgroup来跟踪和管理容器的资源使用。
# 
# Cgroup是Linux内核提供的一种资源隔离和管理机制，可以用于限制、分配和监控进程组的资源使用。使用Cgroup，可以将容器的资源限制和隔离，以防止容器之间的资源争用和不公平的竞争。
# 
# 通过设置SystemdCgroup参数，可以确保containerd能够找到正确的Cgroup路径，并正确地限制和隔离容器的资源使用，确保容器可以按照预期的方式运行。如果未正确设置SystemdCgroup参数，可能会导致容器无法正确地使用资源，或者无法保证资源的公平分配和隔离。
# 
# 总而言之，SystemdCgroup参数的作用是为了确保containerd能够正确地管理容器的资源使用，以实现资源的限制、隔离和公平分配。
```

### 启动并设置为开机启动

```shell
systemctl daemon-reload
# 用于重新加载systemd管理的单位文件。当你新增或修改了某个单位文件（如.service文件、.socket文件等），需要运行该命令来刷新systemd对该文件的配置。

systemctl enable --now containerd.service
# 启用并立即启动docker.service单元。docker.service是Docker守护进程的systemd服务单元。

systemctl stop containerd.service
# 停止运行中的docker.service单元，即停止Docker守护进程。

systemctl start containerd.service
# 启动docker.service单元，即启动Docker守护进程。

systemctl restart containerd.service
# 重启docker.service单元，即重新启动Docker守护进程。

systemctl status containerd.service
# 显示docker.service单元的当前状态，包括运行状态、是否启用等信息。
```

### 配置crictl客户端连接的运行时位置

```shell
# https://github.com/kubernetes-sigs/cri-tools/releases/
wget https://mirrors.chenby.cn/https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.32.0/crictl-v1.32.0-linux-amd64.tar.gz

#解压
tar xf crictl-v*-linux-amd64.tar.gz -C /usr/bin/
#生成配置文件
cat > /etc/crictl.yaml <<EOF
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 10
debug: false
EOF

#测试
systemctl restart  containerd
crictl info

# 注意！
# 下面是参数`crictl`的详细解释
# 
# `crictl`是一个用于与容器运行时通信的命令行工具。它是容器运行时接口（CRI）工具的一个实现，可以对容器运行时进行管理和操作。
# 
# 1. `runtime-endpoint: unix:///run/containerd/containerd.sock`
# 指定容器运行时的终端套接字地址。在这个例子中，指定的地址是`unix:///run/containerd/containerd.sock`，这是一个Unix域套接字地址。
# 
# 2. `image-endpoint: unix:///run/containerd/containerd.sock`
# 指定容器镜像服务的终端套接字地址。在这个例子中，指定的地址是`unix:///run/containerd/containerd.sock`，这是一个Unix域套接字地址。
# 
# 3. `timeout: 10`
# 设置与容器运行时通信的超时时间，单位是秒。在这个例子中，超时时间被设置为10秒。
# 
# 4. `debug: false`
# 指定是否开启调式模式。在这个例子中，调式模式被设置为关闭，即`false`。如果设置为`true`，则会输出更详细的调试信息。
# 
# 这些参数可以根据需要进行修改，以便与容器运行时进行有效的通信和管理。
```

## 安装docker作为Runtime

### 解压docker程序

```shell
# 二进制包下载地址：https://download.docker.com/linux/static/stable/x86_64/
wget https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/static/stable/x86_64/docker-28.0.2.tgz

#解压
tar xf docker-*.tgz 
#拷贝二进制文件
cp docker/* /usr/bin/
```

### 创建containerd的service文件

```shell
#创建containerd的service文件,并且启动
cat >/etc/systemd/system/containerd.service <<EOF
[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target local-fs.target

[Service]
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/bin/containerd
Type=notify
Delegate=yes
KillMode=process
Restart=always
RestartSec=5
LimitNPROC=infinity
LimitCORE=infinity
LimitNOFILE=1048576
TasksMax=infinity
OOMScoreAdjust=-999

[Install]
WantedBy=multi-user.target
EOF

# 参数解释：
# 
# [Unit]
# - Description=containerd container runtime：指定服务的描述信息。
# - Documentation=https://containerd.io：指定服务的文档链接。
# - After=network.target local-fs.target：指定服务的启动顺序，在网络和本地文件系统启动之后再启动该服务。
# 
# [Service]
# - ExecStartPre=-/sbin/modprobe overlay：在启动服务之前执行的命令，使用`-`表示忽略错误。
# - ExecStart=/usr/bin/containerd：指定服务的启动命令。
# - Type=notify：指定服务的类型，`notify`表示服务会在启动完成后向systemd发送通知。
# - Delegate=yes：允许服务代理其他服务的应答，例如收到关机命令后终止其他服务。
# - KillMode=process：指定服务终止时的行为，`process`表示终止服务进程。
# - Restart=always：指定服务终止后是否自动重启，`always`表示总是自动重启。
# - RestartSec=5：指定服务重启的时间间隔，单位为秒。
# - LimitNPROC=infinity：限制服务的最大进程数，`infinity`表示没有限制。
# - LimitCORE=infinity：限制服务的最大核心数，`infinity`表示没有限制。
# - LimitNOFILE=infinity：限制服务的最大文件数，`infinity`表示没有限制。
# - TasksMax=infinity：限制服务的最大任务数，`infinity`表示没有限制。
# - OOMScoreAdjust=-999：指定服务的OOM（Out of Memory）得分，负数表示降低被终止的概率。
# 
# [Install]
# - WantedBy=multi-user.target：指定服务的安装方式，`multi-user.target`表示该服务在多用户模式下安装。


# 设置开机自启
systemctl enable --now containerd.service
```

### 准备docker的service文件

```shell
#准备docker的service文件
cat > /etc/systemd/system/docker.service <<EOF
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service cri-docker.service docker.socket containerd.service
Wants=network-online.target
Requires=docker.socket containerd.service

[Service]
Type=notify
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
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
OOMScoreAdjust=-500

[Install]
WantedBy=multi-user.target
EOF

# 参数解释：
# 
# [Unit]
# - Description: 描述服务的作用，这里是Docker Application Container Engine，即Docker应用容器引擎。
# - Documentation: 提供关于此服务的文档链接，这里是Docker官方文档链接。
# - After: 说明该服务在哪些其他服务之后启动，这里是在网络在线、firewalld服务和containerd服务后启动。
# - Wants: 说明该服务想要的其他服务，这里是网络在线服务。
# - Requires: 说明该服务需要的其他服务，这里是containerd.service。
# 
# [Service]
# - Type: 服务类型，这里是notify，表示服务在启动完成时发送通知。
# - ExecStart: 命令，启动该服务时会执行的命令，这里是/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock，即启动dockerd并指定一些参数，其中-H指定dockerd的监听地址为fd://，--containerd指定containerd的sock文件位置。
# - ExecReload: 重载命令，当接收到HUP信号时执行的命令，这里是/bin/kill -s HUP $MAINPID，即发送HUP信号给主进程ID。
# - TimeoutSec: 服务超时时间，这里是0，表示没有超时限制。
# - RestartSec: 重启间隔时间，这里是2秒，表示重启失败后等待2秒再重启。
# - Restart: 重启策略，这里是always，表示总是重启。
# - StartLimitBurst: 启动限制次数，这里是3，表示在启动失败后最多重试3次。
# - StartLimitInterval: 启动限制时间间隔，这里是60秒，表示两次启动之间最少间隔60秒。
# - LimitNOFILE: 文件描述符限制，这里是infinity，表示没有限制。
# - LimitNPROC: 进程数限制，这里是infinity，表示没有限制。
# - LimitCORE: 核心转储限制，这里是infinity，表示没有限制。
# - TasksMax: 最大任务数，这里是infinity，表示没有限制。
# - Delegate: 修改权限，这里是yes，表示启用权限修改。
# - KillMode: 杀死模式，这里是process，表示杀死整个进程组。
# - OOMScoreAdjust: 用于调整进程在系统内存紧张时的优先级调整，这里是-500，表示将OOM分数降低500。
# 
# [Install]
# - WantedBy: 安装目标，这里是multi-user.target，表示在多用户模式下安装。
#      在WantedBy参数中，我们可以使用以下参数：
#      1. multi-user.target：指定该服务应该在多用户模式下启动。
#      2. graphical.target：指定该服务应该在图形化界面模式下启动。
#      3. default.target：指定该服务应该在系统的默认目标（runlevel）下启动。
#      4. rescue.target：指定该服务应该在系统救援模式下启动。
#      5. poweroff.target：指定该服务应该在关机时启动。
#      6. reboot.target：指定该服务应该在重启时启动。
#      7. halt.target：指定该服务应该在停止时启动。
#      8. shutdown.target：指定该服务应该在系统关闭时启动。
#      这些参数可以根据需要选择一个或多个，以告知系统在何时启动该服务。
```

### 准备docker的socket文件

```shell
#准备docker的socket文件
cat > /etc/systemd/system/docker.socket <<EOF
[Unit]
Description=Docker Socket for the API

[Socket]
ListenStream=/var/run/docker.sock
SocketMode=0660
SocketUser=root
SocketGroup=docker

[Install]
WantedBy=sockets.target
EOF

# 这是一个用于Docker API的socket配置文件，包含了以下参数：
# 
# [Unit]
# - Description：描述了该socket的作用，即为Docker API的socket。
# 
# [Socket]
# - ListenStream：指定了socket的监听地址，该socket会监听在/var/run/docker.sock上，即Docker守护程序使用的默认sock文件。
# - SocketMode：指定了socket文件的权限模式，此处为0660，即用户和用户组有读写权限，其他用户无权限。
# - SocketUser：指定了socket文件的所有者，此处为root用户。
# - SocketGroup：指定了socket文件的所属用户组，此处为docker用户组。
# 
# [Install]
# - WantedBy：指定了该socket被启用时的目标，此处为sockets.target，表示当sockets.target启动时启用该socket。
# 
# 该配置文件的作用是为Docker提供API访问的通道，它监听在/var/run/docker.sock上，具有root用户权限，但只接受docker用户组的成员的连接，并且其他用户无法访问。这样，只有docker用户组的成员可以通过该socket与Docker守护进程进行通信。
```

### 配置加速器

```shell
# 配置加速器
mkdir /etc/docker/ -pv
cat >/etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "registry-mirrors": [
    "https://xxxxxxxxxxxx.com"
  ],
  "max-concurrent-downloads": 10,
  "log-driver": "json-file",
  "log-level": "warn",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
    },
  "data-root": "/var/lib/docker"
}
EOF


# 该参数文件中包含以下参数：
# 
# 加速地址自己找 我的已经失效了
# 
# 1. exec-opts: 用于设置Docker守护进程的选项，native.cgroupdriver=systemd表示使用systemd作为Cgroup驱动程序。
# 2. registry-mirrors: 用于指定Docker镜像的镜像注册服务器。在这里有三个镜像注册服务器：https://docker.m.daocloud.io、https://docker.mirrors.ustc.edu.cn和http://hub-mirror.c.163.com。
# 3. max-concurrent-downloads: 用于设置同时下载镜像的最大数量，默认值为3，这里设置为10。
# 4. log-driver: 用于设置Docker守护进程的日志驱动程序，这里设置为json-file。
# 5. log-level: 用于设置日志的级别，这里设置为warn。
# 6. log-opts: 用于设置日志驱动程序的选项，这里有两个选项：max-size和max-file。max-size表示每个日志文件的最大大小，这里设置为10m，max-file表示保存的最大日志文件数量，这里设置为3。
# 7. data-root: 用于设置Docker守护进程的数据存储根目录，默认为/var/lib/docker，这里设置为/var/lib/docker。
```

### 启动docker

```shell
groupadd docker
#创建docker组

systemctl daemon-reload
# 用于重新加载systemd管理的单位文件。当你新增或修改了某个单位文件（如.service文件、.socket文件等），需要运行该命令来刷新systemd对该文件的配置。

systemctl enable --now docker.socket
# 启用并立即启动docker.socket单元。docker.socket是一个systemd的socket单元，用于接收来自网络的Docker API请求。

systemctl enable --now docker.service
# 启用并立即启动docker.service单元。docker.service是Docker守护进程的systemd服务单元。

systemctl stop docker.service
# 停止运行中的docker.service单元，即停止Docker守护进程。

systemctl start docker.service
# 启动docker.service单元，即启动Docker守护进程。

systemctl restart docker.service
# 重启docker.service单元，即重新启动Docker守护进程。

systemctl status docker.service
# 显示docker.service单元的当前状态，包括运行状态、是否启用等信息。

docker info
#验证
```

### 解压cri-docker

```shell
# 由于1.24以及更高版本不支持docker所以安装cri-docker
# 下载cri-docker 
# https://github.com/Mirantis/cri-dockerd/releases/
wget  https://mirrors.chenby.cn/https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.16/cri-dockerd-0.3.16.amd64.tgz

# 解压cri-docker
tar xvf cri-dockerd-*.amd64.tgz 
cp -r cri-dockerd/  /usr/bin/
chmod +x /usr/bin/cri-dockerd/cri-dockerd
```

### 写入启动cri-docker配置文件

```shell
# 写入启动配置文件
cat >  /usr/lib/systemd/system/cri-docker.service <<EOF
[Unit]
Description=CRI Interface for Docker Application Container Engine
Documentation=https://docs.mirantis.com
After=network-online.target firewalld.service docker.service
Wants=network-online.target
Requires=docker.service

[Service]
Type=notify
ExecStart=/usr/bin/cri-dockerd/cri-dockerd --network-plugin=cni --pod-infra-container-image=registry.aliyuncs.com/google_containers/pause:3.7
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


# [Unit]
# - Description：该参数用于描述该单元的功能，这里描述的是CRI与Docker应用容器引擎的接口。
# - Documentation：该参数指定了相关文档的网址，供用户参考。
# - After：该参数指定了此单元应该在哪些其他单元之后启动，确保在网络在线、防火墙和Docker服务启动之后再启动此单元。
# - Wants：该参数指定了此单元希望也启动的所有单元，此处是希望在网络在线之后启动。
# - Requires：该参数指定了此单元需要依赖的单元，此处是cri-docker.socket单元。
# 
# [Service]
# - Type：该参数指定了服务的类型，这里是notify，表示当服务启动完成时向系统发送通知。
# - ExecStart：该参数指定了将要运行的命令和参数，此处是执行/usr/bin/cri-dockerd/cri-dockerd命令，并指定了网络插件为cni和Pod基础设施容器的镜像为registry.aliyuncs.com/google_containers/pause:3.7。
# - ExecReload：该参数指定在服务重载时运行的命令，此处是发送HUP信号给主进程。
# - TimeoutSec：该参数指定了服务启动的超时时间，此处为0，表示无限制。
# - RestartSec：该参数指定了自动重启服务的时间间隔，此处为2秒。
# - Restart：该参数指定了在服务发生错误时自动重启，此处是始终重启。
# - StartLimitBurst：该参数指定了在给定时间间隔内允许的启动失败次数，此处为3次。
# - StartLimitInterval：该参数指定启动失败的时间间隔，此处为60秒。
# - LimitNOFILE：该参数指定了允许打开文件的最大数量，此处为无限制。
# - LimitNPROC：该参数指定了允许同时运行的最大进程数，此处为无限制。
# - LimitCORE：该参数指定了允许生成的core文件的最大大小，此处为无限制。
# - TasksMax：该参数指定了此服务的最大任务数，此处为无限制。
# - Delegate：该参数指定了是否将控制权委托给指定服务，此处为是。
# - KillMode：该参数指定了在终止服务时如何处理进程，此处是通过终止进程来终止服务。
# 
# [Install]
# - WantedBy：该参数指定了希望这个单元启动的多用户目标。在这里，这个单元希望在multi-user.target启动。
```

### 写入cri-docker的socket配置文件

```shell
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


# 该配置文件是用于systemd的单元配置文件(unit file)，用于定义一个socket单元。
# 
# [Unit]
# - Description：表示该单元的描述信息。
# - PartOf：表示该单元是cri-docker.service的一部分。
# 
# [Socket]
# - ListenStream：指定了该socket要监听的地址和端口，这里使用了%t占位符，表示根据单元的类型来决定路径。%t/cri-dockerd.sock表示将监听Unix域套接字cri-dockerd.sock。Unix域套接字用于在同一台主机上的进程之间通信。
# - SocketMode：指定了socket文件的权限模式，此处为0660，即用户和用户组有读写权限，其他用户无权限。
# - SocketUser：指定了socket文件的所有者，此处为root用户。
# - SocketGroup：指定了socket文件的所属用户组，此处为docker用户组。
# 
# [Install]
# - WantedBy：部分定义了该单元的安装配置信息。WantedBy=sockets.target表示当sockets.target单元启动时，自动启动该socket单元。sockets.target是一个系统服务，用于管理所有的socket单元。
```

### 启动cri-docker

```shell
systemctl daemon-reload
# 用于重新加载systemd管理的单位文件。当你新增或修改了某个单位文件（如.service文件、.socket文件等），需要运行该命令来刷新systemd对该文件的配置。

systemctl enable --now cri-docker.service
# 启用并立即启动cri-docker.service单元。cri-docker.service是cri-docker守护进程的systemd服务单元。

systemctl restart cri-docker.service
# 重启cri-docker.service单元，即重新启动cri-docker守护进程。

systemctl status docker.service
# 显示docker.service单元的当前状态，包括运行状态、是否启用等信息。
```

## 高可用keepalived、haproxy 

### 安装keepalived和haproxy服务

```shell
yum -y install keepalived haproxy
```

### 修改haproxy配置文件（配置文件一样）

```shell
# cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.bak

cat >/etc/haproxy/haproxy.cfg<<"EOF"
global
 maxconn 2000
 ulimit-n 16384
 log 127.0.0.1 local0 err
 stats timeout 30s

defaults
 log global
 mode http
 option httplog
 timeout connect 5000
 timeout client 50000
 timeout server 50000
 timeout http-request 15s
 timeout http-keep-alive 15s


frontend monitor-in
 bind *:33305
 mode http
 option httplog
 monitor-uri /monitor

frontend k8s-master
 bind 0.0.0.0:9443
 bind 127.0.0.1:9443
 mode tcp
 option tcplog
 tcp-request inspect-delay 5s
 default_backend k8s-master


backend k8s-master
 mode tcp
 option tcplog
 option tcp-check
 balance roundrobin
 default-server inter 10s downinter 5s rise 2 fall 2 slowstart 60s maxconn 250 maxqueue 256 weight 100
 server  k8s-master01  192.168.1.21:6443 check
 server  k8s-master02  192.168.1.22:6443 check
 server  k8s-master03  192.168.1.23:6443 check
EOF
```

参数
```shell
这段配置代码是指定了一个HAProxy负载均衡器的配置。下面对各部分进行详细解释：
1. global:
   - maxconn 2000: 设置每个进程的最大连接数为2000。
   - ulimit-n 16384: 设置每个进程的最大文件描述符数为16384。
   - log 127.0.0.1 local0 err: 指定日志的输出地址为本地主机的127.0.0.1，并且只记录错误级别的日志。
   - stats timeout 30s: 设置查看负载均衡器统计信息的超时时间为30秒。

2. defaults:
   - log global: 使默认日志与global部分相同。
   - mode http: 设定负载均衡器的工作模式为HTTP模式。
   - option httplog: 使负载均衡器记录HTTP协议的日志。
   - timeout connect 5000: 设置与后端服务器建立连接的超时时间为5秒。
   - timeout client 50000: 设置与客户端的连接超时时间为50秒。
   - timeout server 50000: 设置与后端服务器连接的超时时间为50秒。
   - timeout http-request 15s: 设置处理HTTP请求的超时时间为15秒。
   - timeout http-keep-alive 15s: 设置保持HTTP连接的超时时间为15秒。

3. frontend monitor-in:
   - bind *:33305: 监听所有IP地址的33305端口。
   - mode http: 设定frontend的工作模式为HTTP模式。
   - option httplog: 记录HTTP协议的日志。
   - monitor-uri /monitor: 设置监控URI为/monitor。

4. frontend k8s-master:
   - bind 0.0.0.0:9443: 监听所有IP地址的9443端口。
   - bind 127.0.0.1:9443: 监听本地主机的9443端口。
   - mode tcp: 设定frontend的工作模式为TCP模式。
   - option tcplog: 记录TCP协议的日志。
   - tcp-request inspect-delay 5s: 设置在接收到请求后延迟5秒进行检查。
   - default_backend k8s-master: 设置默认的后端服务器组为k8s-master。

5. backend k8s-master:
   - mode tcp: 设定backend的工作模式为TCP模式。
   - option tcplog: 记录TCP协议的日志。
   - option tcp-check: 启用TCP检查功能。
   - balance roundrobin: 使用轮询算法进行负载均衡。
   - default-server inter 10s downinter 5s rise 2 fall 2 slowstart 60s maxconn 250 maxqueue 256 weight 100: 设置默认的服务器参数。
   - server k8s-master01 192.168.1.21:6443 check: 增加一个名为k8s-master01的服务器，IP地址为192.168.1.21，端口号为6443，并对其进行健康检查。
   - server k8s-master02 192.168.1.22:6443 check: 增加一个名为k8s-master02的服务器，IP地址为192.168.1.22，端口号为6443，并对其进行健康检查。
   - server k8s-master03 192.168.1.23:6443 check: 增加一个名为k8s-master03的服务器，IP地址为192.168.1.23，端口号为6443，并对其进行健康检查。

以上就是这段配置代码的详细解释。它主要定义了全局配置、默认配置、前端监听和后端服务器组的相关参数和设置。通过这些配置，可以实现负载均衡和监控功能。
```

### Master01配置keepalived master节点

```shell
#cp /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf.bak

cat > /etc/keepalived/keepalived.conf << EOF
! Configuration File for keepalived

global_defs {
    router_id LVS_DEVEL
}
vrrp_script chk_apiserver {
    script "/etc/keepalived/check_apiserver.sh"
    interval 5 
    weight -5
    fall 2
    rise 1
}
vrrp_instance VI_1 {
    state MASTER
    # 注意网卡名
    interface ens160 
    mcast_src_ip 192.168.1.21
    virtual_router_id 51
    priority 100
    nopreempt
    advert_int 2
    authentication {
        auth_type PASS
        auth_pass K8SHA_KA_AUTH
    }
    virtual_ipaddress {
        192.168.1.36
    }
    track_script {
      chk_apiserver 
} }

EOF
```

### Master02配置keepalived backup节点

```shell
# cp /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf.bak

cat > /etc/keepalived/keepalived.conf << EOF
! Configuration File for keepalived

global_defs {
    router_id LVS_DEVEL
}
vrrp_script chk_apiserver {
    script "/etc/keepalived/check_apiserver.sh"
    interval 5 
    weight -5
    fall 2
    rise 1

}
vrrp_instance VI_1 {
    state BACKUP
    # 注意网卡名
    interface ens160
    mcast_src_ip 192.168.1.22
    virtual_router_id 51
    priority 80
    nopreempt
    advert_int 2
    authentication {
        auth_type PASS
        auth_pass K8SHA_KA_AUTH
    }
    virtual_ipaddress {
        192.168.1.36
    }
    track_script {
      chk_apiserver 
} }

EOF
```

### Master03配置keepalived backup节点

```shell
# cp /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf.bak

cat > /etc/keepalived/keepalived.conf << EOF
! Configuration File for keepalived

global_defs {
    router_id LVS_DEVEL
}
vrrp_script chk_apiserver {
    script "/etc/keepalived/check_apiserver.sh"
    interval 5 
    weight -5
    fall 2
    rise 1

}
vrrp_instance VI_1 {
    state BACKUP
    # 注意网卡名
    interface ens160
    mcast_src_ip 192.168.1.23
    virtual_router_id 51
    priority 50
    nopreempt
    advert_int 2
    authentication {
        auth_type PASS
        auth_pass K8SHA_KA_AUTH
    }
    virtual_ipaddress {
        192.168.1.36
    }
    track_script {
      chk_apiserver 
} }

EOF
```

参数

```shell
这是一个用于配置keepalived的配置文件。下面是对每个部分的详细解释：

- `global_defs`部分定义了全局参数。
- `router_id`参数指定了当前路由器的标识，这里设置为"LVS_DEVEL"。

- `vrrp_script`部分定义了一个VRRP脚本。`chk_apiserver`是脚本的名称，
    - `script`参数指定了脚本的路径。该脚本每5秒执行一次，返回值为0表示服务正常，返回值为1表示服务异常。
    - `weight`参数指定了根据脚本返回的值来调整优先级，这里设置为-5。
    - `fall`参数指定了失败阈值，当连续2次脚本返回值为1时认为服务异常。
    - `rise`参数指定了恢复阈值，当连续1次脚本返回值为0时认为服务恢复正常。

- `vrrp_instance`部分定义了一个VRRP实例。`VI_1`是实例的名称。
    - `state`参数指定了当前实例的状态，这里设置为MASTER表示当前实例是主节点。
    - `interface`参数指定了要监听的网卡，这里设置为ens160。
    - `mcast_src_ip`参数指定了VRRP报文的源IP地址，这里设置为192.168.1.21。
    - `virtual_router_id`参数指定了虚拟路由器的ID，这里设置为51。
    - `priority`参数指定了实例的优先级，优先级越高（数值越大）越有可能被选为主节点。
    - `nopreempt`参数指定了当主节点失效后不要抢占身份，即不要自动切换为主节点。
    - `advert_int`参数指定了发送广播的间隔时间，这里设置为2秒。
    - `authentication`部分指定了认证参数
    	- `auth_type`参数指定了认证类型，这里设置为PASS表示使用密码认证，
    	- `auth_pass`参数指定了认证密码，这里设置为K8SHA_KA_AUTH。
    - `virtual_ipaddress`部分指定了虚拟IP地址，这里设置为192.168.1.36。
    - `track_script`部分指定了要跟踪的脚本，这里跟踪了chk_apiserver脚本。
```

### 健康检查脚本配置（lb主机）

```shell
cat >  /etc/keepalived/check_apiserver.sh << EOF
#!/bin/bash

err=0
for k in \$(seq 1 3)
do
    check_code=\$(pgrep haproxy)
    if [[ \$check_code == "" ]]; then
        err=\$(expr \$err + 1)
        sleep 1
        continue
    else
        err=0
        break
    fi
done

if [[ \$err != "0" ]]; then
    echo "systemctl stop keepalived"
    /usr/bin/systemctl stop keepalived
    exit 1
else
    exit 0
fi
EOF

# 给脚本授权

chmod +x /etc/keepalived/check_apiserver.sh

# 这段脚本是一个简单的bash脚本，主要用来检查是否有名为haproxy的进程正在运行。
# 
# 脚本的主要逻辑如下：
# 1. 首先设置一个变量err为0，用来记录错误次数。
# 2. 使用一个循环，在循环内部执行以下操作：
#    a. 使用pgrep命令检查是否有名为haproxy的进程在运行。如果不存在该进程，将err加1，并暂停1秒钟，然后继续下一次循环。
#    b. 如果存在haproxy进程，将err重置为0，并跳出循环。
# 3. 检查err的值，如果不为0，表示检查失败，输出一条错误信息并执行“systemctl stop keepalived”命令停止keepalived进程，并退出脚本返回1。
# 4. 如果err的值为0，表示检查成功，退出脚本返回0。
# 
# 该脚本的主要作用是检查是否存在运行中的haproxy进程，如果无法检测到haproxy进程，将停止keepalived进程并返回错误状态。如果haproxy进程存在，则返回成功状态。这个脚本可能是作为一个健康检查脚本的一部分，在确保haproxy服务可用的情况下，才继续运行其他操作。
```

### 启动服务

```shell
systemctl daemon-reload
# 用于重新加载systemd管理的单位文件。当你新增或修改了某个单位文件（如.service文件、.socket文件等），需要运行该命令来刷新systemd对该文件的配置。
systemctl enable --now haproxy.service
# 启用并立即启动haproxy.service单元。haproxy.service是haproxy守护进程的systemd服务单元。
systemctl enable --now keepalived.service
# 启用并立即启动keepalived.service单元。keepalived.service是keepalived守护进程的systemd服务单元。
systemctl status haproxy.service
# haproxy.service单元的当前状态，包括运行状态、是否启用等信息。
systemctl status keepalived.service
# keepalived.service单元的当前状态，包括运行状态、是否启用等信息。
```

### 测试高可用

```shell
# 能ping同
[root@k8s-node02 ~]# ping 192.168.1.36

# 能telnet访问
[root@k8s-node02 ~]# telnet 192.168.1.36 9443

# 关闭主节点，看vip是否漂移到备节点
```

## 初始化安装

#### 整改镜像
```shell
# 查看最新版本有那些镜像
[root@k8s-master01 ~]# kubeadm config images list --image-repository registry.aliyuncs.com/google_containers
registry.aliyuncs.com/google_containers/kube-apiserver:v1.32.3
registry.aliyuncs.com/google_containers/kube-controller-manager:v1.32.3
registry.aliyuncs.com/google_containers/kube-scheduler:v1.32.3
registry.aliyuncs.com/google_containers/kube-proxy:v1.32.3
registry.aliyuncs.com/google_containers/coredns:v1.11.3
registry.aliyuncs.com/google_containers/pause:3.10
registry.aliyuncs.com/google_containers/etcd:3.5.16-0
[root@k8s-master01 ~]# 

# 只有一个CRI的情况下
kubeadm config images pull --image-repository registry.aliyuncs.com/google_containers
# 指定CRI拉去镜像
kubeadm config images pull --image-repository registry.aliyuncs.com/google_containers --cri-socket unix:///var/run/cri-dockerd.sock
kubeadm config images pull --image-repository registry.aliyuncs.com/google_containers --cri-socket unix:///var/run/containerd/containerd.sock

```

### 修改初始化配置
```shell
# 创建默认配置
kubeadm config print init-defaults > kubeadm-init.yaml
# 这是我使用的配置文件
cat > kubeadm.yaml << EOF
apiVersion: kubeadm.k8s.io/v1beta4
bootstrapTokens:
- groups:
  - system:bootstrappers:kubeadm:default-node-token
  token: abcdef.0123456789abcdef
  ttl: 24h0m0s
  usages:
  - signing
  - authentication
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: 192.168.1.21
  bindPort: 6443
nodeRegistration:
  # criSocket: unix:///run/containerd/containerd.sock
  criSocket: unix:///var/run/cri-dockerd.sock
  imagePullPolicy: IfNotPresent
  imagePullSerial: true
  kubeletExtraArgs:
  - name: "node-ip"
    value: "192.168.1.21,fc00::21"
  name: k8s-master01
  taints:
  - effect: PreferNoSchedule
    key: node-role.kubernetes.io/master
timeouts:
  controlPlaneComponentHealthCheck: 4m0s
  discovery: 5m0s
  etcdAPICall: 2m0s
  kubeletHealthCheck: 4m0s
  kubernetesAPICall: 1m0s
  tlsBootstrap: 5m0s
  upgradeManifests: 5m0s
---
apiServer:
  certSANs:
    - x.oiox.cn
    - z.oiox.cn
    - k8s-master01
    - k8s-master02
    - k8s-master03
    - 192.168.1.21
    - 192.168.1.22
    - 192.168.1.23
    - 192.168.1.24
    - 192.168.1.25
    - 192.168.1.26
    - 192.168.1.27
    - 192.168.1.28
    - 192.168.1.29
    - 127.0.0.1
  timeoutForControlPlane: 4m0s
apiVersion: kubeadm.k8s.io/v1beta4
caCertificateValidityPeriod: 87600h0m0s
certificateValidityPeriod: 8760h0m0s
certificatesDir: /etc/kubernetes/pki
clusterName: kubernetes
controllerManager: {}
dns: {}
encryptionAlgorithm: RSA-2048
etcd:
  local:
    dataDir: /var/lib/etcd
imageRepository: registry.aliyuncs.com/google_containers
kind: ClusterConfiguration
kubernetesVersion: 1.32.3
networking:
  dnsDomain: cluster.local
  podSubnet: 172.16.0.0/12,fc00:2222::/64
  serviceSubnet: 10.96.0.0/16,fd00:1111::/112
proxy: {}
scheduler: {}
controlPlaneEndpoint: "192.168.1.36:9443"
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: ipvs
---
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    cacheTTL: 0s
    enabled: true
  x509:
    clientCAFile: /etc/kubernetes/pki/ca.crt
authorization:
  mode: Webhook
  webhook:
    cacheAuthorizedTTL: 0s
    cacheUnauthorizedTTL: 0s
clusterDNS:
- 10.96.0.10
clusterDomain: cluster.local
cpuManagerReconcilePeriod: 0s
evictionPressureTransitionPeriod: 0s
fileCheckFrequency: 0s
healthzBindAddress: 127.0.0.1
healthzPort: 10248
httpCheckFrequency: 0s
imageMinimumGCAge: 0s
kind: KubeletConfiguration
cgroupDriver: systemd
logging: {}
memorySwap: {}
nodeStatusReportFrequency: 0s
nodeStatusUpdateFrequency: 0s
rotateCertificates: true
runtimeRequestTimeout: 0s
shutdownGracePeriod: 0s
shutdownGracePeriodCriticalPods: 0s
staticPodPath: /etc/kubernetes/manifests
streamingConnectionIdleTimeout: 0s
syncFrequency: 0s
volumeStatsAggPeriod: 0s
EOF
```

### 开始初始化
```shell
[root@k8s-master01 ~]# kubeadm init --config=kubeadm.yaml
W0323 14:33:08.483853   15471 initconfiguration.go:332] error unmarshaling configuration schema.GroupVersionKind{Group:"kubeadm.k8s.io", Version:"v1beta4", Kind:"ClusterConfiguration"}: strict decoding error: unknown field "apiServer.timeoutForControlPlane"
[init] Using Kubernetes version: v1.32.3
[preflight] Running pre-flight checks
	[WARNING Hostname]: hostname "node" could not be reached
	[WARNING Hostname]: hostname "node": lookup node on 192.168.1.99:53: no such host
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action beforehand using 'kubeadm config images pull'
W0323 14:33:08.591394   15471 checks.go:846] detected that the sandbox image "registry.aliyuncs.com/google_containers/pause:3.7" of the container runtime is inconsistent with that used by kubeadm.It is recommended to use "registry.aliyuncs.com/google_containers/pause:3.10" as the CRI sandbox image.
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [k8s-master01 k8s-master02 k8s-master03 kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local node x.oiox.cn z.oiox.cn] and IPs [10.96.0.1 192.168.1.21 192.168.1.36 192.168.1.22 192.168.1.23 192.168.1.24 192.168.1.25 192.168.1.26 192.168.1.27 192.168.1.28 192.168.1.29 127.0.0.1]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/ca" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [localhost node] and IPs [192.168.1.21 127.0.0.1 ::1]
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [localhost node] and IPs [192.168.1.21 127.0.0.1 ::1]
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Generating "sa" key and public key
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
W0323 14:33:10.094613   15471 endpoint.go:57] [endpoint] WARNING: port specified in controlPlaneEndpoint overrides bindPort in the controlplane address
[kubeconfig] Writing "admin.conf" kubeconfig file
W0323 14:33:10.188907   15471 endpoint.go:57] [endpoint] WARNING: port specified in controlPlaneEndpoint overrides bindPort in the controlplane address
[kubeconfig] Writing "super-admin.conf" kubeconfig file
W0323 14:33:10.447566   15471 endpoint.go:57] [endpoint] WARNING: port specified in controlPlaneEndpoint overrides bindPort in the controlplane address
[kubeconfig] Writing "kubelet.conf" kubeconfig file
W0323 14:33:10.495558   15471 endpoint.go:57] [endpoint] WARNING: port specified in controlPlaneEndpoint overrides bindPort in the controlplane address
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
W0323 14:33:10.579310   15471 endpoint.go:57] [endpoint] WARNING: port specified in controlPlaneEndpoint overrides bindPort in the controlplane address
[kubeconfig] Writing "scheduler.conf" kubeconfig file
[etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
[control-plane] Creating static Pod manifest for "kube-scheduler"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Starting the kubelet
[wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests"
[kubelet-check] Waiting for a healthy kubelet at http://127.0.0.1:10248/healthz. This can take up to 4m0s
[kubelet-check] The kubelet is healthy after 500.977478ms
[api-check] Waiting for a healthy API server. This can take up to 4m0s
[api-check] The API server is healthy after 11.652939705s
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config" in namespace kube-system with the configuration for the kubelets in the cluster
[upload-certs] Skipping phase. Please see --upload-certs
[mark-control-plane] Marking the node node as control-plane by adding the labels: [node-role.kubernetes.io/control-plane node.kubernetes.io/exclude-from-external-load-balancers]
[mark-control-plane] Marking the node node as control-plane by adding the taints [node-role.kubernetes.io/master:PreferNoSchedule]
[bootstrap-token] Using token: abcdef.0123456789abcdef
[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to get nodes
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] Configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] Configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
[kubelet-finalize] Updating "/etc/kubernetes/kubelet.conf" to point to a rotatable kubelet client certificate and key
[addons] Applied essential addon: CoreDNS
W0323 14:33:24.643627   15471 endpoint.go:57] [endpoint] WARNING: port specified in controlPlaneEndpoint overrides bindPort in the controlplane address
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

You can now join any number of control-plane nodes by copying certificate authorities
and service account keys on each node and then running the following as root:

  kubeadm join 192.168.1.36:9443 --token abcdef.0123456789abcdef \
	--discovery-token-ca-cert-hash sha256:1a6196cd63edf4e78f39d34d448d6333d25e1ad0ff650839260fc7df25ec8a92 \
	--control-plane 

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.1.36:9443 --token abcdef.0123456789abcdef \
	--discovery-token-ca-cert-hash sha256:1a6196cd63edf4e78f39d34d448d6333d25e1ad0ff650839260fc7df25ec8a92 
[root@k8s-master01 ~]# 



# 重新初始化

# 只有一个CRI的情况下
kubeadm reset
# 指定CRI重置
kubeadm reset --cri-socket unix:///var/run/cri-dockerd.sock
kubeadm reset --cri-socket unix:///var/run/containerd/containerd.sock

```
### 配置kubectl
```shell
# 配置kubectl
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
### 配置证书
```shell
# 使用脚本将这如果你睡拷贝到其他maser节点
USER=root
CONTROL_PLANE_IPS="192.168.1.22 192.168.1.23"
for host in ${CONTROL_PLANE_IPS}; do
    scp /etc/kubernetes/pki/ca.crt "${USER}"@$host:
    scp /etc/kubernetes/pki/ca.key "${USER}"@$host:
    scp /etc/kubernetes/pki/sa.key "${USER}"@$host:
    scp /etc/kubernetes/pki/sa.pub "${USER}"@$host:
    scp /etc/kubernetes/pki/front-proxy-ca.crt "${USER}"@$host:
    scp /etc/kubernetes/pki/front-proxy-ca.key "${USER}"@$host:
    scp /etc/kubernetes/pki/etcd/ca.crt "${USER}"@$host:etcd-ca.crt
    # 如果你正使用外部 etcd，忽略下一行
    scp /etc/kubernetes/pki/etcd/ca.key "${USER}"@$host:etcd-ca.key
done

# 在其他的maser上面执行 ，将证书文件放入所需目录
USER=root
mkdir -p /etc/kubernetes/pki/etcd
mv /${USER}/ca.crt /etc/kubernetes/pki/
mv /${USER}/ca.key /etc/kubernetes/pki/
mv /${USER}/sa.pub /etc/kubernetes/pki/
mv /${USER}/sa.key /etc/kubernetes/pki/
mv /${USER}/front-proxy-ca.crt /etc/kubernetes/pki/
mv /${USER}/front-proxy-ca.key /etc/kubernetes/pki/
mv /${USER}/etcd-ca.crt /etc/kubernetes/pki/etcd/ca.crt
# 如果你正使用外部 etcd，忽略下一行
mv /${USER}/etcd-ca.key /etc/kubernetes/pki/etcd/ca.key
```
### 初始化Master2
```shell

# 在maser02上执行操作，将加入控制节点
kubeadm config print join-defaults > kubeadm-join-master-02.yaml
cat > kubeadm-join-master-02.yaml << EOF
apiVersion: kubeadm.k8s.io/v1beta4
caCertPath: /etc/kubernetes/pki/ca.crt
discovery:
  bootstrapToken:
    apiServerEndpoint: 192.168.1.36:9443
    token: abcdef.0123456789abcdef
    caCertHashes:
    - "sha256:1a6196cd63edf4e78f39d34d448d6333d25e1ad0ff650839260fc7df25ec8a92"
    unsafeSkipCAVerification: true
  tlsBootstrapToken: abcdef.0123456789abcdef
kind: JoinConfiguration
controlPlane:
  localAPIEndpoint:
    advertiseAddress: "192.168.1.22"
    bindPort: 6443
nodeRegistration:
  # criSocket: unix:///run/containerd/containerd.sock
  criSocket: unix:///var/run/cri-dockerd.sock
  imagePullPolicy: IfNotPresent
  imagePullSerial: true
  name: k8s-master02
  taints:
  - effect: PreferNoSchedule
    key: node-role.kubernetes.io/master
  kubeletExtraArgs:
  - name: "node-ip"
    value: "192.168.1.22,fc00::22"
timeouts:
  controlPlaneComponentHealthCheck: 4m0s
  discovery: 5m0s
  etcdAPICall: 2m0s
  kubeletHealthCheck: 4m0s
  kubernetesAPICall: 1m0s
  tlsBootstrap: 5m0s
  upgradeManifests: 5m0s
EOF

kubeadm join --config=kubeadm-join-master-02.yaml
```

### 初始化Master3
```shell
# 在maser03上执行操作，将加入控制节点
kubeadm config print join-defaults > kubeadm-join-master-03.yaml
cat > kubeadm-join-master-03.yaml << EOF
apiVersion: kubeadm.k8s.io/v1beta4
caCertPath: /etc/kubernetes/pki/ca.crt
discovery:
  bootstrapToken:
    apiServerEndpoint: 192.168.1.36:9443
    token: abcdef.0123456789abcdef
    caCertHashes:
    - "sha256:1a6196cd63edf4e78f39d34d448d6333d25e1ad0ff650839260fc7df25ec8a92"
    unsafeSkipCAVerification: true
  tlsBootstrapToken: abcdef.0123456789abcdef
kind: JoinConfiguration
controlPlane:
  localAPIEndpoint:
    advertiseAddress: "192.168.1.23"
    bindPort: 6443
nodeRegistration:
  # criSocket: unix:///run/containerd/containerd.sock
  criSocket: unix:///var/run/cri-dockerd.sock
  imagePullPolicy: IfNotPresent
  imagePullSerial: true
  name: k8s-master03
  taints:
  - effect: PreferNoSchedule
    key: node-role.kubernetes.io/master
  kubeletExtraArgs:
  - name: "node-ip"
    value: "192.168.1.23,fc00::23"
timeouts:
  controlPlaneComponentHealthCheck: 4m0s
  discovery: 5m0s
  etcdAPICall: 2m0s
  kubeletHealthCheck: 4m0s
  kubernetesAPICall: 1m0s
  tlsBootstrap: 5m0s
  upgradeManifests: 5m0s
EOF

kubeadm join --config=kubeadm-join-master-03.yaml

```
### 初始化Node1
```shell
# 在node01上执行操作，将加入工作节点
kubeadm config print join-defaults > kubeadm-join-node-01.yaml
cat > kubeadm-join-node-01.yaml << EOF
apiVersion: kubeadm.k8s.io/v1beta4
caCertPath: /etc/kubernetes/pki/ca.crt
discovery:
  bootstrapToken:
    apiServerEndpoint: 192.168.1.36:9443
    token: abcdef.0123456789abcdef
    caCertHashes:
    - "sha256:1a6196cd63edf4e78f39d34d448d6333d25e1ad0ff650839260fc7df25ec8a92"
    unsafeSkipCAVerification: true
  tlsBootstrapToken: abcdef.0123456789abcdef
kind: JoinConfiguration
nodeRegistration:
  # criSocket: unix:///run/containerd/containerd.sock
  criSocket: unix:///var/run/cri-dockerd.sock
  imagePullPolicy: IfNotPresent
  imagePullSerial: true
  name: k8s-node01
  taints: null
  kubeletExtraArgs:
  - name: "node-ip"
    value: "192.168.1.24,fc00::24"
timeouts:
  controlPlaneComponentHealthCheck: 4m0s
  discovery: 5m0s
  etcdAPICall: 2m0s
  kubeletHealthCheck: 4m0s
  kubernetesAPICall: 1m0s
  tlsBootstrap: 5m0s
  upgradeManifests: 5m0s
EOF

kubeadm join --config=kubeadm-join-node-01.yaml
```
### 初始化Node2
```shell
# 在node02上执行操作，将加入工作节点
kubeadm config print join-defaults > kubeadm-join-node-02.yaml
cat > kubeadm-join-node-02.yaml << EOF
apiVersion: kubeadm.k8s.io/v1beta4
caCertPath: /etc/kubernetes/pki/ca.crt
discovery:
  bootstrapToken:
    apiServerEndpoint: 192.168.1.36:9443
    token: abcdef.0123456789abcdef
    caCertHashes:
    - "sha256:1a6196cd63edf4e78f39d34d448d6333d25e1ad0ff650839260fc7df25ec8a92"
    unsafeSkipCAVerification: true
  tlsBootstrapToken: abcdef.0123456789abcdef
kind: JoinConfiguration
nodeRegistration:
  # criSocket: unix:///run/containerd/containerd.sock
  criSocket: unix:///var/run/cri-dockerd.sock
  imagePullPolicy: IfNotPresent
  imagePullSerial: true
  name: k8s-node02
  taints: null
  kubeletExtraArgs:
  - name: "node-ip"
    value: "192.168.1.25,fc00::25"
timeouts:
  controlPlaneComponentHealthCheck: 4m0s
  discovery: 5m0s
  etcdAPICall: 2m0s
  kubeletHealthCheck: 4m0s
  kubernetesAPICall: 1m0s
  tlsBootstrap: 5m0s
  upgradeManifests: 5m0s
EOF

kubeadm join --config=kubeadm-join-node-02.yaml
```

## 查看集群状态

```shell
[root@k8s-master01 ~]# kubectl get nodes
NAME           STATUS     ROLES           AGE     VERSION
k8s-master01   NotReady   control-plane   3m56s   v1.32.3
k8s-master02   NotReady   control-plane   2m3s    v1.32.3
k8s-master03   NotReady   control-plane   40s     v1.32.3
k8s-node01     NotReady   <none>          8s      v1.32.3
k8s-node02     NotReady   <none>          5s      v1.32.3
[root@k8s-master01 ~]# 
```

# 安装网络插件

**注意二选其一即可，建议在此处创建好快照后在进行操作，后续出问题可以回滚**

** centos7 要升级libseccomp 不然 无法安装网络插件**

```shell
# https://github.com/opencontainers/runc/releases
# 升级runc
# wget https://mirrors.chenby.cn/https://github.com/opencontainers/runc/releases/download/v1.1.12/runc.amd64

install -m 755 runc.amd64 /usr/local/sbin/runc
cp -p /usr/local/sbin/runc  /usr/local/bin/runc
cp -p /usr/local/sbin/runc  /usr/bin/runc

#查看当前版本
[root@k8s-master-1 ~]# rpm -qa | grep libseccomp
libseccomp-2.5.2-2.el9.x86_64

#下载高于2.4以上的包
# yum -y install http://rpmfind.net/linux/centos/8-stream/BaseOS/x86_64/os/Packages/libseccomp-2.5.1-1.el8.x86_64.rpm
# 清华源
# yum -y install https://mirrors.tuna.tsinghua.edu.cn/centos/8-stream/BaseOS/x86_64/os/Packages/libseccomp-2.5.1-1.el8.x86_64.rpm
```

## 安装Calico

### 更改calico网段

```shell

# 安装operator
kubectl create -f https://mirrors.chenby.cn/https://raw.githubusercontent.com/projectcalico/calico/v3.29.2/manifests/tigera-operator.yaml


# 下载配置文件
curl https://mirrors.chenby.cn/https://raw.githubusercontent.com/projectcalico/calico/v3.29.2/manifests/custom-resources.yaml -O




# 修改地址池
vim custom-resources.yaml
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
spec:
  calicoNetwork:
    ipPools:
    - name: default-ipv4-ippool
      blockSize: 26
      cidr: 172.16.0.0/12 
      encapsulation: VXLANCrossSubnet
      natOutgoing: Enabled
      nodeSelector: all()

---
apiVersion: operator.tigera.io/v1
kind: APIServer
metadata:
  name: default
spec: {}


# 执行安装
kubectl create -f custom-resources.yaml



# 安装客户端
curl -L https://mirrors.chenby.cn/https://github.com/projectcalico/calico/releases/download/v3.28.2/calicoctl-linux-amd64 -o calicoctl


# 给客户端添加执行权限
chmod +x ./calicoctl


# 查看集群节点
./calicoctl get nodes
# 查看集群节点状态
./calicoctl node status
#查看地址池
./calicoctl get ipPool
./calicoctl get ipPool -o yaml


```

### 查看容器状态

```shell
# calico 初始化会很慢 需要耐心等待一下，大约十分钟左右
[root@k8s-master01 ~]# kubectl get pod -A | grep calico
NAMESPACE          NAME                                       READY   STATUS              RESTARTS   AGE
calico-apiserver   calico-apiserver-6c6d4589d6-hfzpg          1/1     Running             0          6m3s
calico-apiserver   calico-apiserver-6c6d4589d6-rs27g          1/1     Running             0          6m3s
calico-system      calico-kube-controllers-7cdf8468d9-9jc22   1/1     Running             0          6m3s
calico-system      calico-node-2qk9k                          1/1     Running             0          6m3s
calico-system      calico-node-755hv                          1/1     Running             0          6m3s
calico-system      calico-node-rncvq                          1/1     Running             0          6m3s
calico-system      calico-node-t694l                          1/1     Running             0          6m3s
calico-system      calico-node-txwr6                          1/1     Running             0          6m3s
calico-system      calico-typha-58c46dd757-8sn77              1/1     Running             0          6m3s
calico-system      calico-typha-58c46dd757-lsnkh              1/1     Running             0          5m57s
calico-system      calico-typha-58c46dd757-wpz64              1/1     Running             0          5m57s
calico-system      csi-node-driver-84xbq                      2/2     Running             0          6m3s
calico-system      csi-node-driver-gl8m7                      2/2     Running             0          6m3s
calico-system      csi-node-driver-lf4xp                      2/2     Running             0          6m3s
calico-system      csi-node-driver-mlwnf                      2/2     Running             0          6m3s
calico-system      csi-node-driver-pqpkb                      2/2     Running             0          6m3s
```

## 安装cilium(推荐)

### 安装helm

```shell
# [root@k8s-master01 ~]# curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
# [root@k8s-master01 ~]# chmod 700 get_helm.sh
# [root@k8s-master01 ~]# ./get_helm.sh

wget https://mirrors.huaweicloud.com/helm/v3.17.2/helm-v3.17.2-linux-amd64.tar.gz
tar xvf helm-*-linux-amd64.tar.gz
cp linux-amd64/helm /usr/local/bin/
```

### 安装cilium

```shell
# 添加源
helm repo add cilium https://helm.cilium.io

# 修改为国内源
helm pull cilium/cilium
tar xvf cilium-*.tgz
cd cilium/

# sed -i "s#quay.io/#quay.m.daocloud.io/#g" values.yaml

# 默认参数安装
helm install  cilium ./cilium/ -n kube-system

# 启用ipv6
# helm install cilium ./cilium/ --namespace kube-system --set ipv6.enabled=true

# 启用路由信息和监控插件
# helm install cilium ./cilium/ --namespace kube-system --set ipv6.enabled=true --set hubble.relay.enabled=true --set hubble.ui.enabled=true --set prometheus.enabled=true --set operator.prometheus.enabled=true --set hubble.enabled=true --set hubble.metrics.enabled="{dns,drop,tcp,flow,port-distribution,icmp,http}" 
```

### 查看

```shell
[root@k8s-master01 ~]# kubectl  get pod -A | grep cil
NAMESPACE     NAME                               READY   STATUS    RESTARTS   AGE
kube-system   cilium-2tnfb                       1/1     Running   0          60s
kube-system   cilium-5tgcb                       1/1     Running   0          60s
kube-system   cilium-6shf5                       1/1     Running   0          60s
kube-system   cilium-ccbcx                       1/1     Running   0          60s
kube-system   cilium-cppft                       1/1     Running   0          60s
kube-system   cilium-operator-675f685d59-7q27q   1/1     Running   0          60s
kube-system   cilium-operator-675f685d59-kwmqz   1/1     Running   0          60s
[root@k8s-master01 ~]#
```

### 下载专属监控面板

安装时候没有创建 监控可以忽略

```shell
[root@k8s-master01 yaml]# wget https://mirrors.chenby.cn/https://raw.githubusercontent.com/cilium/cilium/1.12.1/examples/kubernetes/addons/prometheus/monitoring-example.yaml

[root@k8s-master01 yaml]# sed -i "s#docker.io/#jockerhub.com/#g" monitoring-example.yaml

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

### 修改为NodePort

安装时候没有创建 监控可以忽略

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

### 查看端口

安装时候没有创建 监控可以忽略

```shell
[root@k8s-master01 yaml]# kubectl get svc -A | grep NodePort
cilium-monitoring   grafana          NodePort    10.111.74.3      <none>        3000:32648/TCP   74s
cilium-monitoring   prometheus       NodePort    10.107.240.124   <none>        9090:30495/TCP   74s
kube-system         hubble-ui        NodePort    10.96.185.26     <none>        80:31568/TCP     99s
```

### 访问

安装时候没有创建 监控可以忽略

```shell
http://192.168.1.31:32648
http://192.168.1.31:30495
http://192.168.1.31:31568
```


## 查看集群

```shell
[root@k8s-master01 ~]# kubectl get node
NAME           STATUS   ROLES           AGE     VERSION
k8s-master01   Ready    control-plane   10m     v1.30.0
k8s-master02   Ready    control-plane   9m3s    v1.30.0
k8s-master03   Ready    control-plane   8m45s   v1.30.0
k8s-node01     Ready    <none>          8m34s   v1.30.0
k8s-node02     Ready    <none>          8m24s   v1.30.0
[root@k8s-master01 ~]# 
[root@k8s-master01 ~]# kubectl get pod -A
NAMESPACE     NAME                                   READY   STATUS    RESTARTS   AGE
kube-system   cilium-2vlhn                           1/1     Running   0          70s
kube-system   cilium-94pvm                           1/1     Running   0          70s
kube-system   cilium-dqllb                           1/1     Running   0          70s
kube-system   cilium-operator-84cc645cfd-nl286       1/1     Running   0          70s
kube-system   cilium-operator-84cc645cfd-v9lzh       1/1     Running   0          70s
kube-system   cilium-r649m                           1/1     Running   0          70s
kube-system   cilium-xhcb5                           1/1     Running   0          70s
kube-system   coredns-85c54ff74b-vgxbg               1/1     Running   0          27s
kube-system   coredns-85c54ff74b-zvr67               1/1     Running   0          42s
kube-system   etcd-k8s-master01                      1/1     Running   0          20m
kube-system   etcd-k8s-master02                      1/1     Running   0          8m20s
kube-system   etcd-k8s-master03                      1/1     Running   0          11m
kube-system   kube-apiserver-k8s-master01            1/1     Running   0          20m
kube-system   kube-apiserver-k8s-master02            1/1     Running   0          8m20s
kube-system   kube-apiserver-k8s-master03            1/1     Running   0          11m
kube-system   kube-controller-manager-k8s-master01   1/1     Running   0          20m
kube-system   kube-controller-manager-k8s-master02   1/1     Running   0          8m20s
kube-system   kube-controller-manager-k8s-master03   1/1     Running   0          11m
kube-system   kube-proxy-6bd4n                       1/1     Running   0          11m
kube-system   kube-proxy-77w24                       1/1     Running   0          8m26s
kube-system   kube-proxy-9d5m8                       1/1     Running   0          12m
kube-system   kube-proxy-jxcrx                       1/1     Running   0          20m
kube-system   kube-proxy-vr5w9                       1/1     Running   0          11m
kube-system   kube-scheduler-k8s-master01            1/1     Running   0          20m
kube-system   kube-scheduler-k8s-master02            1/1     Running   0          8m20s
kube-system   kube-scheduler-k8s-master03            1/1     Running   0          11m
```

# 集群验证

## 部署pod资源

```shell
cat<<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: busybox
  namespace: default
spec:
  containers:
  - name: busybox
    image: docker.m.daocloud.io/library/busybox:1.28
    command:
      - sleep
      - "3600"
    imagePullPolicy: IfNotPresent
  restartPolicy: Always
EOF

# 查看
kubectl  get pod
NAME      READY   STATUS    RESTARTS   AGE
busybox   1/1     Running   0          17s
```

## 用pod解析默认命名空间中的kubernetes

```shell
# 查看name
kubectl get svc
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   17h

# 进行解析
kubectl exec  busybox -n default -- nslookup kubernetes
3Server:    10.96.0.10
Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local

Name:      kubernetes
Address 1: 10.96.0.1 kubernetes.default.svc.cluster.local
```

## 测试跨命名空间是否可以解析

```shell
# 查看有那些name
kubectl  get svc -A
NAMESPACE     NAME             TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                  AGE
default       kubernetes       ClusterIP   10.96.0.1       <none>        443/TCP                  7m12s
kube-system   cilium-envoy     ClusterIP   None            <none>        9964/TCP                 3m31s
kube-system   hubble-peer      ClusterIP   10.96.247.148   <none>        443/TCP                  3m31s
kube-system   kube-dns         ClusterIP   10.96.0.10      <none>        53/UDP,53/TCP,9153/TCP   6m58s
kube-system   metrics-server   ClusterIP   10.96.18.184    <none>        443/TCP                  94s


# 进行解析
kubectl exec  busybox -n default -- nslookup kube-dns.kube-system
Server:    10.96.0.10
Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local

Name:      kube-dns.kube-system
Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local
[root@k8s-master01 metrics-server]# 
```

## 每个节点都必须要能访问Kubernetes的kubernetes svc 443和kube-dns的service 53

```shell
telnet 10.96.0.1 443
Trying 10.96.0.1...
Connected to 10.96.0.1.
Escape character is '^]'.

telnet 10.96.0.10 53
Trying 10.96.0.10...
Connected to 10.96.0.10.
Escape character is '^]'.

curl 10.96.0.10:53
curl: (52) Empty reply from server
```

## Pod和Pod之前要能通

```shell
kubectl get po -owide
NAME      READY   STATUS    RESTARTS   AGE   IP              NODE         NOMINATED NODE   READINESS GATES
busybox   1/1     Running   0          17m   172.27.14.193   k8s-node02   <none>           <none>

kubectl get po -n kube-system -owide
NAME                                       READY   STATUS    RESTARTS   AGE     IP               NODE           NOMINATED NODE   READINESS GATES
calico-kube-controllers-76754ff848-pw4xg   1/1     Running   0          38m     172.25.244.193   k8s-master01   <none>           <none>
calico-node-97m55                          1/1     Running   0          38m     192.168.1.34     k8s-node01     <none>           <none>
calico-node-hlz7j                          1/1     Running   0          38m     192.168.1.32     k8s-master02   <none>           <none>
calico-node-jtlck                          1/1     Running   0          38m     192.168.1.33     k8s-master03   <none>           <none>
calico-node-lxfkf                          1/1     Running   0          38m     192.168.1.35     k8s-node02     <none>           <none>
calico-node-t667x                          1/1     Running   0          38m     192.168.1.31     k8s-master01   <none>           <none>
calico-typha-59d75c5dd4-gbhfp              1/1     Running   0          38m     192.168.1.35     k8s-node02     <none>           <none>
coredns-coredns-c5c6d4d9b-bd829            1/1     Running   0          10m     172.25.92.65     k8s-master02   <none>           <none>
metrics-server-7c8b55c754-w7q8v            1/1     Running   0          3m56s   172.17.125.3     k8s-node01     <none>           <none>

# 进入busybox ping其他节点上的pod

kubectl exec -ti busybox -- sh
/ # ping 192.168.1.23
PING 192.168.1.23 (192.168.1.23): 56 data bytes
64 bytes from 192.168.1.23: seq=0 ttl=62 time=0.494 ms
64 bytes from 192.168.1.23: seq=1 ttl=62 time=0.342 ms
64 bytes from 192.168.1.23: seq=2 ttl=62 time=0.335 ms

# 可以连通证明这个pod是可以跨命名空间和跨主机通信的
```

## 创建三个副本，可以看到3个副本分布在不同的节点上（用完可以删了）

```shell
cat<<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
EOF

kubectl  get pod 
NAME                               READY   STATUS    RESTARTS   AGE
busybox                            1/1     Running   0          6m25s
nginx-deployment-9456bbbf9-4bmvk   1/1     Running   0          8s
nginx-deployment-9456bbbf9-9rcdk   1/1     Running   0          8s
nginx-deployment-9456bbbf9-dqv8s   1/1     Running   0          8s

# 删除nginx
[root@k8s-master01 ~]# kubectl delete deployments nginx-deployment 
```

# 安装dashboard

```shell
# 添加源信息
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/


# 修改为国内源
helm pull kubernetes-dashboard/kubernetes-dashboard
tar xvf kubernetes-dashboard-*.tgz
cd kubernetes-dashboard
sed -i "s#docker.io/#jockerhub.com/#g" values.yaml

# 默认参数安装
helm upgrade --install kubernetes-dashboard ./kubernetes-dashboard/  --create-namespace --namespace kube-system


# 我的集群使用默认参数安装 kubernetes-dashboard-kong 出现异常 8444 端口占用
# 使用下面的命令进行安装，在安装时关闭kong.tls功能
helm upgrade --install kubernetes-dashboard ./kubernetes-dashboard/ --namespace kube-system --set kong.admin.tls.enabled=false
```

## 更改dashboard的svc为NodePort，如果已是请忽略

```shell
kubectl edit svc  -n kube-system kubernetes-dashboard-kong-proxy
  type: NodePort
```

## 查看端口号

```shell
[root@k8s-master01 ~]# kubectl get svc kubernetes-dashboard-kong-proxy -n kube-system
NAME                              TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)         AGE
kubernetes-dashboard-kong-proxy   NodePort   10.96.247.74   <none>        443:31495/TCP   2m29s
[root@k8s-master01 ~]# 
```

## 创建token

```shell
cat > dashboard-user.yaml << EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kube-system
EOF

kubectl  apply -f dashboard-user.yaml

# 创建token
kubectl -n kube-system create token admin-user
eyJhbGciOiJSUzI1NiIsImtpZCI6IjVWNTNJSGFsNDhTLU1TNDVEZkZmeUlkbFpaUEVsVU8yOXZqQjJ0Rmk0eGcifQ.eyJhdWQiOlsiaHR0cHM6Ly9rdWJlcm5ldGVzLmRlZmF1bHQuc3ZjLmNsdXN0ZXIubG9jYWwiXSwiZXhwIjoxNzQyNzIyNTIxLCJpYXQiOjE3NDI3MTg5MjEsImlzcyI6Imh0dHBzOi8va3ViZXJuZXRlcy5kZWZhdWx0LnN2Yy5jbHVzdGVyLmxvY2FsIiwianRpIjoiMjJkZjBiODYtNTQwNS00ZGMwLThjMjgtOTlhM2RiODhjZjMzIiwia3ViZXJuZXRlcy5pbyI6eyJuYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsInNlcnZpY2VhY2NvdW50Ijp7Im5hbWUiOiJhZG1pbi11c2VyIiwidWlkIjoiNzBiMTI1MjEtNjJkMC00ZTA3LTkzNDYtM2IyYWYxMDY5MmUzIn19LCJuYmYiOjE3NDI3MTg5MjEsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDprdWJlLXN5c3RlbTphZG1pbi11c2VyIn0.OWIO-PR9EQ4ZUwmtKRQtzdhV4ycESyF6viDFR8yhnT3u9fB8QkSD5dA7pxp6zt_e-bHFU0nxz5DiHgy6xQmxW-6nhtviRk0KkXaQHGHdlo5TrcRTuE1zwAclPsPvuEhuF7z-IIemSy6CrBi_P_nRyeQSFKN_GhVz3-frgMHHkb6rV8HxGp1kIL2z2FakB-72XfhXRb--4lf41PfGMaMCOvPTYy4YhBkwtUKFPzQ3Ixr80naiFp4I2_M5mlnuNu_xHvIWl43zXTrvnrMZchqor9vLjrQcPcPzd6GH_YJcsCOLq4i1Qp2M6TwvbMa1Zd-kZHokIrEc8TCdiALIbS_2cg
```

## 创建长期token

```shell
cat > dashboard-user-token.yaml << EOF
apiVersion: v1
kind: Secret
metadata:
  name: admin-user
  namespace: kube-system
  annotations:
    kubernetes.io/service-account.name: "admin-user"   
type: kubernetes.io/service-account-token  
EOF

kubectl  apply -f dashboard-user-token.yaml

# 查看密码
kubectl get secret admin-user -n kube-system -o jsonpath={".data.token"} | base64 -d

eyJhbGciOiJSUzI1NiIsImtpZCI6IjVWNTNJSGFsNDhTLU1TNDVEZkZmeUlkbFpaUEVsVU8yOXZqQjJ0Rmk0eGcifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJhZG1pbi11c2VyIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6ImFkbWluLXVzZXIiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiI3MGIxMjUyMS02MmQwLTRlMDctOTM0Ni0zYjJhZjEwNjkyZTMiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6a3ViZS1zeXN0ZW06YWRtaW4tdXNlciJ9.CWJmVeh3f0LHFqM7BXeMYytVN0tWITgVwCifDX8EqL_CkB7L0sZKzr35UgoB7_ByutpAAx7rN57wme1Kg3kHbXJGT5_C3biUhYX8o665QKDMYXjeWE8hBQb6hPS6S5GrZ8srmv4lOHNeso3q1X1znvm5Pe987Y74b4PMiTQZ0JzlapYCQSVgda6kxgaff-jwmF3uW_E8Le2DydLBRwILRtiQxUX3wMtMM9u_RgmqB1zKvQymm-EDPPYouEruz_8bbrXbMTgAqML7PydeXqB8Cd_t8Xiv2A19wd4VkLH1E-eN6esRSR2nCLsJn6vQfRV--mH1OH-DR6LCd4yUsDnqaQ
```

## 登录dashboard

https://192.168.1.21:31495/

# ingress安装

## 执行部署

```shell
wget https://mirrors.chenby.cn/https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml -O ingress.yaml

# 修改为国内源 docker源可选
sed -i "s#registry.k8s.io/ingress-nginx/#registry.aliyuncs.com/chenby/#g" ingress.yaml

cat > ingress-backend.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: default-http-backend
  labels:
    app.kubernetes.io/name: default-http-backend
  namespace: kube-system
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: default-http-backend
  template:
    metadata:
      labels:
        app.kubernetes.io/name: default-http-backend
    spec:
      terminationGracePeriodSeconds: 60
      containers:
      - name: default-http-backend
        image: registry.cn-hangzhou.aliyuncs.com/chenby/defaultbackend-amd64:1.5 
        livenessProbe:
          httpGet:
            path: /healthz
            port: 8080
            scheme: HTTP
          initialDelaySeconds: 30
          timeoutSeconds: 5
        ports:
        - containerPort: 8080
        resources:
          limits:
            cpu: 10m
            memory: 20Mi
          requests:
            cpu: 10m
            memory: 20Mi
---
apiVersion: v1
kind: Service
metadata:
  name: default-http-backend
  namespace: kube-system
  labels:
    app.kubernetes.io/name: default-http-backend
spec:
  ports:
  - port: 80
    targetPort: 8080
  selector:
    app.kubernetes.io/name: default-http-backend
EOF

kubectl  apply -f ingress.yaml 
kubectl  apply -f ingress-backend.yaml 


cat > ingress-demo-app.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-server
spec:
  replicas: 2
  selector:
    matchLabels:
      app: hello-server
  template:
    metadata:
      labels:
        app: hello-server
    spec:
      containers:
      - name: hello-server
        image: registry.cn-hangzhou.aliyuncs.com/lfy_k8s_images/hello-server
        ports:
        - containerPort: 9000
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx-demo
  name: nginx-demo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx-demo
  template:
    metadata:
      labels:
        app: nginx-demo
    spec:
      containers:
      - image: nginx
        name: nginx
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: nginx-demo
  name: nginx-demo
spec:
  selector:
    app: nginx-demo
  ports:
  - port: 8000
    protocol: TCP
    targetPort: 80
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: hello-server
  name: hello-server
spec:
  selector:
    app: hello-server
  ports:
  - port: 8000
    protocol: TCP
    targetPort: 9000
---
apiVersion: networking.k8s.io/v1
kind: Ingress  
metadata:
  name: ingress-host-bar
spec:
  ingressClassName: nginx
  rules:
  - host: "hello.chenby.cn"
    http:
      paths:
      - pathType: Prefix
        path: "/"
        backend:
          service:
            name: hello-server
            port:
              number: 8000
  - host: "demo.chenby.cn"
    http:
      paths:
      - pathType: Prefix
        path: "/nginx"  
        backend:
          service:
            name: nginx-demo
            port:
              number: 8000
EOF

# 等创建完成后在执行：
kubectl  apply -f ingress-demo-app.yaml 

kubectl  get ingress
NAME               CLASS   HOSTS                            ADDRESS     PORTS   AGE
ingress-host-bar   nginx   hello.chenby.cn,demo.chenby.cn   192.168.1.32   80      7s
```

## 过滤查看ingress端口

```shell
# 修改为nodeport
kubectl edit svc -n ingress-nginx   ingress-nginx-controller
type: NodePort

[root@hello ~/yaml]# kubectl  get svc -A | grep ingress
ingress-nginx          ingress-nginx-controller             NodePort    10.104.231.36    <none>        80:32636/TCP,443:30579/TCP   104s
ingress-nginx          ingress-nginx-controller-admission   ClusterIP   10.101.85.88     <none>        443/TCP                      105s
[root@hello ~/yaml]#
```

# IPv6测试

```shell
#部署应用

cat<<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: chenby
spec:
  replicas: 1
  selector:
    matchLabels:
      app: chenby
  template:
    metadata:
      labels:
        app: chenby
    spec:
      hostNetwork: true
      containers:
      - name: chenby
        image: docker.io/library/nginx
        resources:
          limits:
            memory: "128Mi"
            cpu: "500m"
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: chenby
spec:
  ipFamilyPolicy: PreferDualStack
  ipFamilies:
  - IPv6
  - IPv4
  type: NodePort
  selector:
    app: chenby
  ports:
  - port: 80
    targetPort: 80
EOF


#查看端口
[root@k8s-master01 ~]# kubectl  get svc
NAME           TYPE        CLUSTER-IP            EXTERNAL-IP   PORT(S)        AGE
chenby         NodePort    fd00:1111::7c07       <none>        80:32386/TCP   5s
[root@k8s-master01 ~]# 

# 直接访问POD地址
[root@k8s-master01 ~]# curl -I http://[fd00:1111::7c07]
HTTP/1.1 200 OK
Server: nginx/1.27.3
Date: Sun, 15 Dec 2024 10:56:49 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Tue, 26 Nov 2024 15:55:00 GMT
Connection: keep-alive
ETag: "6745ef54-267"
Accept-Ranges: bytes


# 使用IPv4地址访问测试
[root@k8s-master01 ~]# curl -I http://192.168.1.21:32386
HTTP/1.1 200 OK
Server: nginx/1.21.6
Date: Thu, 05 May 2022 10:20:59 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Tue, 25 Jan 2022 15:03:52 GMT
Connection: keep-alive
ETag: "61f01158-267"
Accept-Ranges: bytes

# 使用主机的内网IPv6地址测试
[root@k8s-master01 ~]# curl -I http://[fc00::21]:32386
HTTP/1.1 200 OK
Server: nginx/1.21.6
Date: Thu, 05 May 2022 10:20:54 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Tue, 25 Jan 2022 15:03:52 GMT
Connection: keep-alive
ETag: "61f01158-267"
Accept-Ranges: bytes

# 使用主机的公网IPv6地址测试
[root@k8s-master01 ~]# curl -I http://[2408:822a:736:c0d1::bad]:32386
HTTP/1.1 200 OK
Server: nginx/1.27.3
Date: Sun, 15 Dec 2024 10:54:16 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Tue, 26 Nov 2024 15:55:00 GMT
Connection: keep-alive
ETag: "6745ef54-267"
Accept-Ranges: bytes

```

# 污点

```shell
# 查看当前污点状态
[root@k8s-master01 ~]# kubectl describe node  | grep Taints
Taints:             node-role.kubernetes.io/master:PreferNoSchedule
Taints:             node-role.kubernetes.io/master:PreferNoSchedule
Taints:             node-role.kubernetes.io/master:PreferNoSchedule
Taints:             <none>
Taints:             <none>

# 设置污点 禁止调度 同时进行驱赶现有的POD
kubectl taint nodes k8s-master01 key1=value1:NoExecute
kubectl taint nodes k8s-master02 key1=value1:NoExecute
kubectl taint nodes k8s-master03 key1=value1:NoExecute

# 取消污点
kubectl taint nodes k8s-master01 key1=value1:NoExecute-
kubectl taint nodes k8s-master02 key1=value1:NoExecute-
kubectl taint nodes k8s-master03 key1=value1:NoExecute-

# 设置污点 禁止调度 不进行驱赶现有的POD
kubectl taint nodes k8s-master01 key1=value1:NoSchedule
kubectl taint nodes k8s-master02 key1=value1:NoSchedule
kubectl taint nodes k8s-master03 key1=value1:NoSchedule

# 取消污点
kubectl taint nodes k8s-master01 key1=value1:NoSchedule-
kubectl taint nodes k8s-master02 key1=value1:NoSchedule-
kubectl taint nodes k8s-master03 key1=value1:NoSchedule-
```

# 安装命令行自动补全功能

```shell
yum install bash-completion -y
source /usr/share/bash-completion/bash_completion
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> ~/.bashrc
```

# 附录

```shell
# 镜像加速器可以使用DaoCloud仓库，替换规则如下

# 镜像版本要自行查看，因为镜像版本是随时更新的，文档无法做到实时更新

# docker pull 镜像

docker pull registry.cn-hangzhou.aliyuncs.com/chenby/cni:master 

# docker 保存镜像
docker save registry.cn-hangzhou.aliyuncs.com/chenby/cni:master -o cni.tar 

# 传输到各个节点
for NODE in k8s-master01 k8s-master02 k8s-master03 k8s-node01 k8s-node02; do scp -r images/  $NODE:/root/ ; done

# 创建命名空间
ctr ns create k8s.io
# 导入镜像
ctr --namespace k8s.io image import images/cni.tar

# pull tar包 解压后
helm pull cilium/cilium

# 查看镜像版本
root@hello:~/cilium# cat values.yaml| grep tag: -C1
  repository: "quay.io/cilium/cilium"
  tag: "v1.12.6"
  pullPolicy: "IfNotPresent"
--
    repository: "quay.io/cilium/certgen"
    tag: "v0.1.8@sha256:4a456552a5f192992a6edcec2febb1c54870d665173a33dc7d876129b199ddbd"
    pullPolicy: "IfNotPresent"
--
      repository: "quay.io/cilium/hubble-relay"
      tag: "v1.12.6"
       # hubble-relay-digest

```

**关于**

https://www.oiox.cn/

https://www.oiox.cn/index.php/start-page.html

**CSDN、GitHub、知乎、开源中国、思否、掘金、简书、华为云、阿里云、腾讯云、哔哩哔哩、今日头条、新浪微博、个人博客**

**全网可搜《小陈运维》**