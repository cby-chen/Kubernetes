# 使用kubeadm部署高可用IPV4/IPV6集群

https://github.com/cby-chen/Kubernetes 开源不易，帮忙点个star，谢谢了

## 介绍

kubernetes（k8s）二进制高可用安装部署，支持IPv4+IPv6双栈。

我使用IPV6的目的是在公网进行访问，所以我配置了IPV6静态地址。

若您没有IPV6环境，或者不想使用IPv6，不对主机进行配置IPv6地址即可。

不配置IPV6，不影响后续，不过集群依旧是支持IPv6的。为后期留有扩展可能性。

若不要IPv6 ，不给网卡配置IPv6即可，不要对IPv6相关配置删除或操作，否则会出问题。

## 强烈建议在Github上查看文档 ！！！

## Github出问题会更新文档，并且后续尽可能第一时间更新新版本文档 ！！！



## k8s基础系统环境配置

### 配置IP

```shell
# 注意！
# 若虚拟机是进行克隆的那么网卡的UUID会重复
# 若UUID重复需要重新生成新的UUID
# UUID重复无法获取到IPV6地址
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
ssh root@192.168.1.31 "nmcli con delete uuid 708a1497-2192-43a5-9f03-2ab936fb3c44;nmcli con add type ethernet ifname eth0 con-name eth0;nmcli con up eth0"
ssh root@192.168.1.32 "nmcli con delete uuid 708a1497-2192-43a5-9f03-2ab936fb3c44;nmcli con add type ethernet ifname eth0 con-name eth0;nmcli con up eth0"
ssh root@192.168.1.33 "nmcli con delete uuid 708a1497-2192-43a5-9f03-2ab936fb3c44;nmcli con add type ethernet ifname eth0 con-name eth0;nmcli con up eth0"
ssh root@192.168.1.34 "nmcli con delete uuid 708a1497-2192-43a5-9f03-2ab936fb3c44;nmcli con add type ethernet ifname eth0 con-name eth0;nmcli con up eth0"
ssh root@192.168.1.35 "nmcli con delete uuid 708a1497-2192-43a5-9f03-2ab936fb3c44;nmcli con add type ethernet ifname eth0 con-name eth0;nmcli con up eth0"

# 参数解释
# 
# ssh ssh root@192.168.1.31
# 使用SSH登录到IP为192.168.1.31的主机，使用root用户身份。
# 
# nmcli con delete uuid 708a1497-2192-43a5-9f03-2ab936fb3c44
# 删除 UUID 为 708a1497-2192-43a5-9f03-2ab936fb3c44 的网络连接，这是 NetworkManager 中一种特定网络配置的唯一标识符。
# 
# nmcli con add type ethernet ifname eth0 con-name eth0
# 添加一种以太网连接类型，并指定接口名为 eth0，连接名称也为 eth0。
# 
# nmcli con up eth0
# 开启 eth0 这个网络连接。
# 
# 简单来说，这个命令的作用是删除一个特定的网络连接配置，并添加一个名为 eth0 的以太网连接，然后启用这个新的连接。

# 修改静态的IPv4地址
ssh root@192.168.1.104 "nmcli con mod eth0 ipv4.addresses 192.168.1.31/24; nmcli con mod eth0 ipv4.gateway  192.168.1.1; nmcli con mod eth0 ipv4.method manual; nmcli con mod eth0 ipv4.dns "8.8.8.8"; nmcli con up eth0"
ssh root@192.168.1.106 "nmcli con mod eth0 ipv4.addresses 192.168.1.32/24; nmcli con mod eth0 ipv4.gateway  192.168.1.1; nmcli con mod eth0 ipv4.method manual; nmcli con mod eth0 ipv4.dns "8.8.8.8"; nmcli con up eth0"
ssh root@192.168.1.107 "nmcli con mod eth0 ipv4.addresses 192.168.1.33/24; nmcli con mod eth0 ipv4.gateway  192.168.1.1; nmcli con mod eth0 ipv4.method manual; nmcli con mod eth0 ipv4.dns "8.8.8.8"; nmcli con up eth0"
ssh root@192.168.1.109 "nmcli con mod eth0 ipv4.addresses 192.168.1.34/24; nmcli con mod eth0 ipv4.gateway  192.168.1.1; nmcli con mod eth0 ipv4.method manual; nmcli con mod eth0 ipv4.dns "8.8.8.8"; nmcli con up eth0"
ssh root@192.168.1.110 "nmcli con mod eth0 ipv4.addresses 192.168.1.35/24; nmcli con mod eth0 ipv4.gateway  192.168.1.1; nmcli con mod eth0 ipv4.method manual; nmcli con mod eth0 ipv4.dns "8.8.8.8"; nmcli con up eth0"

# 参数解释
# 
# ssh root@192.168.1.154
# 使用SSH登录到IP为192.168.1.154的主机，使用root用户身份。
# 
# "nmcli con mod eth0 ipv4.addresses 192.168.1.31/24"
# 修改eth0网络连接的IPv4地址为192.168.1.31，子网掩码为 24。
# 
# "nmcli con mod eth0 ipv4.gateway 192.168.1.1"
# 修改eth0网络连接的IPv4网关为192.168.1.1。
# 
# "nmcli con mod eth0 ipv4.method manual"
# 将eth0网络连接的IPv4配置方法设置为手动。
# 
# "nmcli con mod eth0 ipv4.dns "8.8.8.8"
# 将eth0网络连接的IPv4 DNS服务器设置为 8.8.8.8。
# 
# "nmcli con up eth0"
# 启动eth0网络连接。
# 
# 总体来说，这条命令是通过SSH远程登录到指定的主机，并使用网络管理命令 (nmcli) 修改eth0网络连接的配置，包括IP地址、网关、配置方法和DNS服务器，并启动该网络连接。

# 没有IPv6选择不配置即可
ssh root@192.168.1.31 "nmcli con mod eth0 ipv6.addresses fc00:43f4:1eea:1::10; nmcli con mod eth0 ipv6.gateway fc00:43f4:1eea:1::1; nmcli con mod eth0 ipv6.method manual; nmcli con mod eth0 ipv6.dns "2400:3200::1"; nmcli con up eth0"
ssh root@192.168.1.32 "nmcli con mod eth0 ipv6.addresses fc00:43f4:1eea:1::20; nmcli con mod eth0 ipv6.gateway fc00:43f4:1eea:1::1; nmcli con mod eth0 ipv6.method manual; nmcli con mod eth0 ipv6.dns "2400:3200::1"; nmcli con up eth0"
ssh root@192.168.1.33 "nmcli con mod eth0 ipv6.addresses fc00:43f4:1eea:1::30; nmcli con mod eth0 ipv6.gateway fc00:43f4:1eea:1::1; nmcli con mod eth0 ipv6.method manual; nmcli con mod eth0 ipv6.dns "2400:3200::1"; nmcli con up eth0"
ssh root@192.168.1.34 "nmcli con mod eth0 ipv6.addresses fc00:43f4:1eea:1::40; nmcli con mod eth0 ipv6.gateway fc00:43f4:1eea:1::1; nmcli con mod eth0 ipv6.method manual; nmcli con mod eth0 ipv6.dns "2400:3200::1"; nmcli con up eth0"
ssh root@192.168.1.35 "nmcli con mod eth0 ipv6.addresses fc00:43f4:1eea:1::50; nmcli con mod eth0 ipv6.gateway fc00:43f4:1eea:1::1; nmcli con mod eth0 ipv6.method manual; nmcli con mod eth0 ipv6.dns "2400:3200::1"; nmcli con up eth0"

# 参数解释
# 
# ssh root@192.168.1.31
# 通过SSH连接到IP地址为192.168.1.31的远程主机，使用root用户进行登录。
# 
# "nmcli con mod eth0 ipv6.addresses fc00:43f4:1eea:1::10"
# 使用nmcli命令修改eth0接口的IPv6地址为fc00:43f4:1eea:1::10。
# 
# "nmcli con mod eth0 ipv6.gateway fc00:43f4:1eea:1::1"
# 使用nmcli命令修改eth0接口的IPv6网关为fc00:43f4:1eea:1::1。
# 
# "nmcli con mod eth0 ipv6.method manual"
# 使用nmcli命令将eth0接口的IPv6配置方法修改为手动配置。
# 
# "nmcli con mod eth0 ipv6.dns "2400:3200::1"
# 使用nmcli命令设置eth0接口的IPv6 DNS服务器为2400:3200::1。
# 
# "nmcli con up eth0"
# 使用nmcli命令启动eth0接口。
# 
# 这个命令的目的是在远程主机上配置eth0接口的IPv6地址、网关、配置方法和DNS服务器，并启动eth0接口。

# 查看网卡配置
# nmcli device show eth0
# nmcli con show eth0
[root@localhost ~]# cat /etc/sysconfig/network-scripts/ifcfg-eth0 
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=none
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
IPV6_ADDR_GEN_MODE=stable-privacy
NAME=eth0
UUID=2aaddf95-3f36-4a48-8626-b55ebf7f53e7
DEVICE=eth0
ONBOOT=yes
IPADDR=192.168.1.31
PREFIX=24
GATEWAY=192.168.1.1
DNS1=8.8.8.8
[root@localhost ~]# 

# 参数解释
# 
# TYPE=Ethernet
# 指定连接类型为以太网。
# 
# PROXY_METHOD=none
# 指定不使用代理方法。
# 
# BROWSER_ONLY=no
# 指定不仅仅在浏览器中使用代理。
# 
# BOOTPROTO=none
# 指定自动分配地址的方式为无（即手动配置IP地址）。
# 
# DEFROUTE=yes
# 指定默认路由开启。
# 
# IPV4_FAILURE_FATAL=no
# 指定IPv4连接失败时不宣告严重错误。
# 
# IPV6INIT=yes
# 指定启用IPv6。
# 
# IPV6_AUTOCONF=no
# 指定不自动配置IPv6地址。
# 
# IPV6_DEFROUTE=yes
# 指定默认IPv6路由开启。
# 
# IPV6_FAILURE_FATAL=no
# 指定IPv6连接失败时不宣告严重错误。
# 
# IPV6_ADDR_GEN_MODE=stable-privacy
# 指定IPv6地址生成模式为稳定隐私模式。
# 
# NAME=eth0
# 指定设备名称为eth0。
# 
# UUID=424fd260-c480-4899-97e6-6fc9722031e8
# 指定设备的唯一标识符。
# 
# DEVICE=eth0
# 指定设备名称为eth0。
# 
# ONBOOT=yes
# 指定开机自动启用这个连接。
# 
# IPADDR=192.168.1.31
# 指定IPv4地址为192.168.1.31。
# 
# PREFIX=24
# 指定IPv4地址的子网掩码为24。
# 
# GATEWAY=192.168.8.1
# 指定IPv4的网关地址为192.168.8.1。
# 
# DNS1=8.8.8.8
# 指定首选DNS服务器为8.8.8.8。
# 
# IPV6ADDR=fc00:43f4:1eea:1::10/128
# 指定IPv6地址为fc00:43f4:1eea:1::10，子网掩码为128。
# 
# IPV6_DEFAULTGW=fc00:43f4:1eea:1::1
# 指定IPv6的默认网关地址为fc00:43f4:1eea:1::1。
# 
# DNS2=2400:3200::1
# 指定备用DNS服务器为2400:3200::1。
```

### 设置主机名

```shell
hostnamectl set-hostname k8s-master01
hostnamectl set-hostname k8s-master02
hostnamectl set-hostname k8s-master03
hostnamectl set-hostname k8s-node01
hostnamectl set-hostname k8s-node02

# 参数解释
# 
# 参数: set-hostname
# 解释: 这是hostnamectl命令的一个参数，用于设置系统的主机名。
# 
# 参数: k8s-master01
# 解释: 这是要设置的主机名，将系统的主机名设置为"k8s-master01"。
```

### 配置yum源

```shell
# 其他系统的源地址
# https://mirrors.tuna.tsinghua.edu.cn/help/

# 对于 Ubuntu
sed -i 's/cn.archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

# 对于 CentOS 7
sudo sed -e 's|^mirrorlist=|#mirrorlist=|g' \
         -e 's|^#baseurl=http://mirror.centos.org/centos|baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos|g' \
         -i.bak \
         /etc/yum.repos.d/CentOS-*.repo

# 对于 CentOS 8
sudo sed -e 's|^mirrorlist=|#mirrorlist=|g' \
         -e 's|^#baseurl=http://mirror.centos.org/$contentdir|baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos|g' \
         -i.bak \
         /etc/yum.repos.d/CentOS-*.repo

# 对于私有仓库
sed -e 's|^mirrorlist=|#mirrorlist=|g' -e 's|^#baseurl=http://mirror.centos.org/\$contentdir|baseurl=http://192.168.1.123/centos|g' -i.bak  /etc/yum.repos.d/CentOS-*.repo

# 参数解释
# 
# 以上命令是用于更改系统软件源的配置，以便从国内镜像站点下载软件包和更新。
# 
# 对于 Ubuntu 系统，将 /etc/apt/sources.list 文件中的软件源地址 cn.archive.ubuntu.com 替换为 mirrors.ustc.edu.cn。
# 
# 对于 CentOS 7 系统，将 /etc/yum.repos.d/CentOS-*.repo 文件中的 mirrorlist 注释掉，并将 baseurl 的值替换为 https://mirrors.tuna.tsinghua.edu.cn/centos。
# 
# 对于 CentOS 8 系统，同样将 /etc/yum.repos.d/CentOS-*.repo 文件中的 mirrorlist 注释掉，并将 baseurl 的值替换为 https://mirrors.tuna.tsinghua.edu.cn/centos。
# 
# 对于私有仓库，将 /etc/yum.repos.d/CentOS-*.repo 文件中的 mirrorlist 注释掉，并将 baseurl 的值替换为私有仓库地址 http://192.168.1.123/centos。
# 
# 这些命令通过使用 sed 工具和正则表达式，对相应的配置文件进行批量的替换操作，从而更改系统软件源配置。
```

### 安装一些必备工具

```shell
# 对于 Ubuntu
apt update && apt upgrade -y && apt install -y wget psmisc vim net-tools nfs-kernel-server telnet lvm2 git tar curl

# 对于 CentOS 7
yum update -y && yum -y install  wget psmisc vim net-tools nfs-utils telnet yum-utils device-mapper-persistent-data lvm2 git tar curl

# 对于 CentOS 8
yum update -y && yum -y install wget psmisc vim net-tools nfs-utils telnet yum-utils device-mapper-persistent-data lvm2 git network-scripts tar curl
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

# 参数解释
# 
# setenforce 0
# 此命令用于设置 SELinux 的执行模式。0 表示关闭 SELinux。
# 
# sed -i 's#SELINUX=enforcing#SELINUX=disabled#g' /etc/selinux/config
# 该命令使用 sed 工具来编辑 /etc/selinux/config 文件。其中 '-i' 参数表示直接修改原文件，而不是输出到终端或另一个文件。's#SELINUX=enforcing#SELINUX=disabled#g' 是 sed 的替换命令，它将文件中所有的 "SELINUX=enforcing" 替换为 "SELINUX=disabled"。这里的 '#' 是分隔符，用于替代传统的 '/' 分隔符，以避免与路径中的 '/' 冲突。
```

### 关闭交换分区

```shell
sed -ri 's/.*swap.*/#&/' /etc/fstab
swapoff -a && sysctl -w vm.swappiness=0

cat /etc/fstab
# /dev/mapper/centos-swap swap                    swap    defaults        0 0


# 参数解释：
# 
# -ri: 这个参数用于在原文件中替换匹配的模式。-r表示扩展正则表达式，-i允许直接修改文件。
# 's/.*swap.*/#&/': 这是一个sed命令，用于在文件/etc/fstab中找到包含swap的行，并在行首添加#来注释掉该行。
# /etc/fstab: 这是一个文件路径，即/etc/fstab文件，用于存储文件系统表。
# swapoff -a: 这个命令用于关闭所有启用的交换分区。
# sysctl -w vm.swappiness=0: 这个命令用于修改vm.swappiness参数的值为0，表示系统在物理内存充足时更倾向于使用物理内存而非交换分区。
```

### 网络配置（俩种方式二选一）

```shell
# Ubuntu忽略，CentOS执行

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
pool 192.168.1.31 iburst
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
export IP="192.168.1.31 192.168.1.32 192.168.1.33 192.168.1.34 192.168.1.35"
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
# 3. `export IP="192.168.1.31 192.168.1.32 192.168.1.33 192.168.1.34 192.168.1.35"`：设置一个包含多个远程主机IP地址的环境变量IP，用空格分隔开，表示要将SSH公钥复制到这些远程主机上。
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
ip_vs                 180224  6 ip_vs_rr,ip_vs_sh,ip_vs_wrr
nf_conntrack          176128  1 ip_vs
nf_defrag_ipv6         24576  2 nf_conntrack,ip_vs
nf_defrag_ipv4         16384  1 nf_conntrack
libcrc32c              16384  3 nf_conntrack,xfs,ip_vs

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

192.168.1.31 k8s-master01
192.168.1.32 k8s-master02
192.168.1.33 k8s-master03
192.168.1.34 k8s-node01
192.168.1.35 k8s-node02
192.168.1.36 lb-vip
EOF
```



## 配置安装源

### 简介

Kubernetes是一个开源系统，用于容器化应用的自动部署、扩缩和管理。它将构成应用的容器按逻辑单位进行分组以便于管理和发现。

由于 Kubernetes 官方变更了仓库的存储路径以及使用方式，如果需要使用 1.28 及以上版本，请使用 新版配置方法 进行配置。

下载地址：https://mirrors.aliyun.com/kubernetes/

新版下载地址：https://mirrors.aliyun.com/kubernetes-new/

### 配置方法

#### 新版配置方法

新版 kubernetes 源使用方法和之前有一定区别，请求按照如下配置方法配置使用。

其中新版 kubernetes 源按照安装版本区分不同仓库，该文档示例为配置 1.30 版本，如需其他版本请在对应位置字符串替换即可。

##### Debian / Ubuntu

1. 在配置中添加镜像（注意修改为自己需要的版本号）：

```shell
apt-get update && apt-get install -y apt-transport-https
curl -fsSL https://mirrors.aliyun.com/kubernetes-new/core/stable/v1.30/deb/Release.key |
    gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://mirrors.aliyun.com/kubernetes-new/core/stable/v1.28/deb/ /" |
    tee /etc/apt/sources.list.d/kubernetes.list
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
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes-new/core/stable/v1.30/rpm/
enabled=1
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes-new/core/stable/v1.30/rpm/repodata/repomd.xml.key
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
sudo setenforce 0
sudo sed -i 's#SELINUX=enforcing#SELINUX=disabled#g' /etc/selinux/config
```

ps: 由于官网未开放同步方式, 可能会有索引gpg检查失败的情况, 这时请用 `yum install -y --nogpgcheck kubelet kubeadm kubectl` 安装

#### 旧版配置方法

目前由于kubernetes官方变更了仓库的存储路径以及使用方式，旧版 kubernetes 源只更新到 1.28 部分版本，后续更新版本请使用 新源配置方法 进行配置。

##### Debian / Ubuntu

```shell
apt-get update && apt-get install -y apt-transport-https
curl https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | apt-key add - 
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet kubeadm kubectl
```

##### CentOS / RHEL / Fedora

```shell
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
setenforce 0
yum install -y kubelet kubeadm kubectl
systemctl enable kubelet && systemctl start kubelet
```

ps: 由于官网未开放同步方式, 可能会有索引gpg检查失败的情况, 这时请用 `yum install -y --nogpgcheck kubelet kubeadm kubectl` 安装


## 配置containerd

```shell
# 下载所需应用包
wget https://mirrors.chenby.cn/https://github.com/containerd/containerd/releases/download/v1.7.16/cri-containerd-cni-1.7.16-linux-amd64.tar.gz
wget https://mirrors.chenby.cn/https://github.com/containernetworking/plugins/releases/download/v1.4.1/cni-plugins-linux-amd64-v1.4.1.tgz

# centos7 要升级libseccomp
yum -y install https://mirrors.tuna.tsinghua.edu.cn/centos/8-stream/BaseOS/x86_64/os/Packages/libseccomp-2.5.1-1.el8.x86_64.rpm


#创建cni插件所需目录
mkdir -p /etc/cni/net.d /opt/cni/bin 
#解压cni二进制包
tar xf cni-plugins-linux-amd64-v*.tgz -C /opt/cni/bin/

#解压
tar -xzf cri-containerd-cni-*-linux-amd64.tar.gz -C /

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

# 配置Containerd所需的模块
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

# 加载模块
systemctl restart systemd-modules-load.service

# 配置Containerd所需的内核
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# 加载内核
sysctl --system

# 创建Containerd的配置文件
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml

# 修改Containerd的配置文件
sed -i "s#SystemdCgroup\ \=\ false#SystemdCgroup\ \=\ true#g" /etc/containerd/config.toml
cat /etc/containerd/config.toml | grep SystemdCgroup
sed -i "s#registry.k8s.io#registry.cn-hangzhou.aliyuncs.com/google_containers#g" /etc/containerd/config.toml
cat /etc/containerd/config.toml | grep sandbox_image
sed -i "s#config_path\ \=\ \"\"#config_path\ \=\ \"/etc/containerd/certs.d\"#g" /etc/containerd/config.toml
cat /etc/containerd/config.toml | grep certs.d

# 配置加速器
mkdir /etc/containerd/certs.d/docker.io -pv
cat > /etc/containerd/certs.d/docker.io/hosts.toml << EOF
server = "https://docker.io"
[host."https://dockerproxy.com"]
  capabilities = ["pull", "resolve"]
EOF


# 启动并设置为开机启动
systemctl daemon-reload
systemctl enable --now containerd.service
systemctl stop containerd.service
systemctl start containerd.service
systemctl restart containerd.service
systemctl status containerd.service
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
 server  k8s-master01  192.168.1.31:6443 check
 server  k8s-master02  192.168.1.32:6443 check
 server  k8s-master03  192.168.1.33:6443 check
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
   - server k8s-master01 192.168.1.31:6443 check: 增加一个名为k8s-master01的服务器，IP地址为192.168.1.31，端口号为6443，并对其进行健康检查。
   - server k8s-master02 192.168.1.32:6443 check: 增加一个名为k8s-master02的服务器，IP地址为192.168.1.32，端口号为6443，并对其进行健康检查。
   - server k8s-master03 192.168.1.33:6443 check: 增加一个名为k8s-master03的服务器，IP地址为192.168.1.33，端口号为6443，并对其进行健康检查。

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
    interface eth0 
    mcast_src_ip 192.168.1.31
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
    interface eth0
    mcast_src_ip 192.168.1.32
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
    interface eth0
    mcast_src_ip 192.168.1.33
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
    - `interface`参数指定了要监听的网卡，这里设置为eth0。
    - `mcast_src_ip`参数指定了VRRP报文的源IP地址，这里设置为192.168.1.31。
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

```shell
# 查看最新版本有那些镜像
[root@k8s-master01 ~]# kubeadm config images list --image-repository registry.cn-hangzhou.aliyuncs.com/google_containers
registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver:v1.30.0
registry.cn-hangzhou.aliyuncs.com/google_containers/kube-controller-manager:v1.30.0
registry.cn-hangzhou.aliyuncs.com/google_containers/kube-scheduler:v1.30.0
registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy:v1.30.0
registry.cn-hangzhou.aliyuncs.com/google_containers/coredns:v1.11.1
registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.9
registry.cn-hangzhou.aliyuncs.com/google_containers/etcd:3.5.12-0
[root@k8s-master01 ~]# 

# 创建默认配置
kubeadm config print init-defaults > kubeadm-init.yaml
# 这是我使用的配置文件
cat > kubeadm.yaml << EOF
apiVersion: kubeadm.k8s.io/v1beta3
bootstrapTokens:
- groups:
  - system:bootstrappers:kubeadm:default-node-token
  token: abcdef.0123456789abcdef
  ttl: 72h0m0s
  usages:
  - signing
  - authentication
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: 192.168.1.31
  bindPort: 6443
nodeRegistration:
  criSocket: unix:///var/run/containerd/containerd.sock
  imagePullPolicy: IfNotPresent
  kubeletExtraArgs:
    # 这里使用maser01的IP 
    node-ip: 192.168.1.31,2408:822a:730:af01::7d8
  taints:
  - effect: PreferNoSchedule
    key: node-role.kubernetes.io/master
---
apiServer:
  certSANs:
    - x.oiox.cn
    - k8s-master01
    - k8s-master02
    - k8s-master03
    - 192.168.1.31
    - 192.168.1.32
    - 192.168.1.33
    - 192.168.1.34
    - 192.168.1.35
    - 192.168.1.36
    - 192.168.1.60
    - 127.0.0.1
  timeoutForControlPlane: 4m0s
apiVersion: kubeadm.k8s.io/v1beta3
certificatesDir: /etc/kubernetes/pki
clusterName: kubernetes
controllerManager: {}
dns: {}
etcd:
  local:
    dataDir: /var/lib/etcd
kind: ClusterConfiguration
kubernetesVersion: 1.30.0
imageRepository: registry.cn-hangzhou.aliyuncs.com/google_containers
networking:
  dnsDomain: cluster.local
  podSubnet: 10.244.0.0/16,2408:822a:730:af01::/64
  serviceSubnet: 10.96.0.0/16,2408:822a:730:af01::/112
scheduler: {}
# 这里使用的是负载地址
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







[root@k8s-master01 ~]# kubeadm init --config=kubeadm.yaml
[init] Using Kubernetes version: v1.30.0
[preflight] Running pre-flight checks
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
W0505 03:06:30.873603   10998 checks.go:844] detected that the sandbox image "m.daocloud.io/registry.k8s.io/pause:3.8" of the container runtime is inconsistent with that used by kubeadm.It is recommended to use "registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.9" as the CRI sandbox image.
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [k8s-master01 kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local x.oiox.cn] and IPs [10.96.0.1 192.168.1.31 192.168.1.36 192.168.1.32 192.168.1.33 192.168.1.34 192.168.1.35 192.168.1.60 127.0.0.1]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/ca" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [k8s-master01 localhost] and IPs [192.168.1.31 127.0.0.1 ::1]
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [k8s-master01 localhost] and IPs [192.168.1.31 127.0.0.1 ::1]
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Generating "sa" key and public key
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
W0505 03:06:33.121345   10998 endpoint.go:57] [endpoint] WARNING: port specified in controlPlaneEndpoint overrides bindPort in the controlplane address
[kubeconfig] Writing "admin.conf" kubeconfig file
W0505 03:06:33.297328   10998 endpoint.go:57] [endpoint] WARNING: port specified in controlPlaneEndpoint overrides bindPort in the controlplane address
[kubeconfig] Writing "super-admin.conf" kubeconfig file
W0505 03:06:33.403541   10998 endpoint.go:57] [endpoint] WARNING: port specified in controlPlaneEndpoint overrides bindPort in the controlplane address
[kubeconfig] Writing "kubelet.conf" kubeconfig file
W0505 03:06:33.552221   10998 endpoint.go:57] [endpoint] WARNING: port specified in controlPlaneEndpoint overrides bindPort in the controlplane address
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
W0505 03:06:33.625848   10998 endpoint.go:57] [endpoint] WARNING: port specified in controlPlaneEndpoint overrides bindPort in the controlplane address
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
[kubelet-check] Waiting for a healthy kubelet. This can take up to 4m0s
[kubelet-check] The kubelet is healthy after 501.155946ms
[api-check] Waiting for a healthy API server. This can take up to 4m0s
[api-check] The API server is healthy after 16.665034989s
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config" in namespace kube-system with the configuration for the kubelets in the cluster
[upload-certs] Skipping phase. Please see --upload-certs
[mark-control-plane] Marking the node k8s-master01 as control-plane by adding the labels: [node-role.kubernetes.io/control-plane node.kubernetes.io/exclude-from-external-load-balancers]
[mark-control-plane] Marking the node k8s-master01 as control-plane by adding the taints [node-role.kubernetes.io/master:PreferNoSchedule]
[bootstrap-token] Using token: abcdef.0123456789abcdef
[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to get nodes
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] Configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] Configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
[kubelet-finalize] Updating "/etc/kubernetes/kubelet.conf" to point to a rotatable kubelet client certificate and key
[addons] Applied essential addon: CoreDNS
W0505 03:06:54.233183   10998 endpoint.go:57] [endpoint] WARNING: port specified in controlPlaneEndpoint overrides bindPort in the controlplane address
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
	--discovery-token-ca-cert-hash sha256:583ddadd1318dae447c3890aa3a2469c5b00c6775e87102458db07e691c724be \
	--control-plane 

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.1.36:9443 --token abcdef.0123456789abcdef \
	--discovery-token-ca-cert-hash sha256:583ddadd1318dae447c3890aa3a2469c5b00c6775e87102458db07e691c724be 
[root@k8s-master01 ~]# 



# 重新初始化
[root@k8s-master01 ~]# kubeadm reset



[root@k8s-master01 ~]# 
[root@k8s-master01 ~]#   mkdir -p $HOME/.kube
[root@k8s-master01 ~]#   sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
[root@k8s-master01 ~]#   sudo chown $(id -u):$(id -g) $HOME/.kube/config
[root@k8s-master01 ~]# 
[root@k8s-master01 ~]# 

# 使用脚本将这如果你睡拷贝到其他maser节点
USER=root
CONTROL_PLANE_IPS="192.168.1.32 192.168.1.33"
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


# 在maser02上执行操作，将加入控制节点
cat > kubeadm-join-master-02.yaml << EOF
apiVersion: kubeadm.k8s.io/v1beta3
kind: JoinConfiguration
controlPlane:
  localAPIEndpoint:
    advertiseAddress: "192.168.1.32"
    bindPort: 6443
discovery:
  bootstrapToken:
    apiServerEndpoint: 192.168.1.36:9443
    token: "abcdef.0123456789abcdef"
    caCertHashes:
    - "sha256:583ddadd1318dae447c3890aa3a2469c5b00c6775e87102458db07e691c724be"
    # 请更改上面的认证信息，使之与你的集群中实际使用的令牌和 CA 证书匹配
nodeRegistration:
  kubeletExtraArgs:
    node-ip: 192.168.1.32,2408:822a:730:af01::fab
EOF

kubeadm join --config=kubeadm-join-master-02.yaml

# 在maser03上执行操作，将加入控制节点
cat > kubeadm-join-master-03.yaml << EOF
apiVersion: kubeadm.k8s.io/v1beta3
kind: JoinConfiguration
controlPlane:
  localAPIEndpoint:
    advertiseAddress: "192.168.1.33"
    bindPort: 6443
discovery:
  bootstrapToken:
    apiServerEndpoint: 192.168.1.36:9443
    token: "abcdef.0123456789abcdef"
    caCertHashes:
    - "sha256:583ddadd1318dae447c3890aa3a2469c5b00c6775e87102458db07e691c724be"
    # 请更改上面的认证信息，使之与你的集群中实际使用的令牌和 CA 证书匹配
nodeRegistration:
  kubeletExtraArgs:
    node-ip: 192.168.1.33,2408:822a:730:af01::bea
EOF

kubeadm join --config=kubeadm-join-master-03.yaml


# 在node02上执行操作，将加入工作节点
cat > kubeadm-join-node-01.yaml << EOF
apiVersion: kubeadm.k8s.io/v1beta3
kind: JoinConfiguration
discovery:
  bootstrapToken:
    apiServerEndpoint: 192.168.1.36:9443
    token: "abcdef.0123456789abcdef"
    caCertHashes:
    - "sha256:583ddadd1318dae447c3890aa3a2469c5b00c6775e87102458db07e691c724be"
    # 请更改上面的认证信息，使之与你的集群中实际使用的令牌和 CA 证书匹配
nodeRegistration:
  kubeletExtraArgs:
    node-ip: 192.168.1.34,2408:822a:730:af01::bcf
EOF

kubeadm join --config=kubeadm-join-node-01.yaml

# 在node02上执行操作，将加入工作节点
cat > kubeadm-join-node-02.yaml << EOF
apiVersion: kubeadm.k8s.io/v1beta3
kind: JoinConfiguration
discovery:
  bootstrapToken:
    apiServerEndpoint: 192.168.1.36:9443
    token: "abcdef.0123456789abcdef"
    caCertHashes:
    - "sha256:583ddadd1318dae447c3890aa3a2469c5b00c6775e87102458db07e691c724be"
    # 请更改上面的认证信息，使之与你的集群中实际使用的令牌和 CA 证书匹配
nodeRegistration:
  kubeletExtraArgs:
    node-ip: 192.168.1.35,2408:822a:730:af01::443
EOF

kubeadm join --config=kubeadm-join-node-02.yaml
```

## 查看集群状态

```shell
[root@k8s-master01 ~]# kubectl get nodes
NAME           STATUS     ROLES           AGE     VERSION
k8s-master01   NotReady   control-plane   2m14s   v1.30.0
k8s-master02   NotReady   control-plane   48s     v1.30.0
k8s-master03   NotReady   control-plane   30s     v1.30.0
k8s-node01     NotReady   <none>          19s     v1.30.0
k8s-node02     NotReady   <none>          9s      v1.30.0
[root@k8s-master01 ~]# 
```

## 安装Calico

### 更改calico网段

```shell
# 下载所需yaml文件
wget https://mirrors.chenby.cn/https://github.com/projectcalico/calico/blob/master/manifests/calico-typha.yaml

# 备份脚本文件
cp calico-typha.yaml calico.yaml
cp calico-typha.yaml calico-ipv6.yaml

# 修改脚本文件中配置项

# vim calico.yaml
# calico-config ConfigMap处
    "ipam": {
        "type": "calico-ipam",
    },
    - name: IP
      value: "autodetect"

    - name: CALICO_IPV4POOL_CIDR
      value: "172.16.0.0/12"

vim calico-ipv6.yaml
# calico-config ConfigMap处
    "ipam": {
        "type": "calico-ipam",
        "assign_ipv4": "true",
        "assign_ipv6": "true"
    },
    - name: IP
      value: "autodetect"

    - name: IP6
      value: "autodetect"

    - name: CALICO_IPV4POOL_CIDR
      value: "10.244.0.0/16"

    - name: CALICO_IPV6POOL_CIDR
      value: "2408:822a:730:af01::/64"

    - name: FELIX_IPV6SUPPORT
      value: "true"
      
     # 设置IPv6 vxLAN的模式为CrossSubnet
     # 如果节点跨了子网，pod通信用vxlan封装，注意该功能3.23版本后才支持
    - name: CALICO_IPV6POOL_VXLAN
      value: "CrossSubnet"
     # 增加环境变量，开启IPv6 pool nat outgoing功能
    - name: CALICO_IPV6POOL_NAT_OUTGOING
      value: "true"



# 若docker镜像拉不下来，可以使用国内的仓库
# sed -i "s#docker.io/calico/#m.daocloud.io/docker.io/calico/#g" calico.yaml 
# sed -i "s#docker.io/calico/#m.daocloud.io/docker.io/calico/#g" calico-ipv6.yaml
# sed -i "s#m.daocloud.io/docker.io/calico/#docker.io/calico/#g" calico.yaml 
# sed -i "s#m.daocloud.io/docker.io/calico/#docker.io/calico/#g" calico-ipv6.yaml

# 本地没有公网 IPv6 使用 calico.yaml
# kubectl apply -f calico.yaml

# 本地有公网 IPv6 使用 calico-ipv6.yaml 
kubectl apply -f calico-ipv6.yaml 
```

### 查看容器状态

```shell
# calico 初始化会很慢 需要耐心等待一下，大约十分钟左右
[root@k8s-master01 ~]# kubectl get pod -A| grep calico
kube-system   calico-kube-controllers-57cf4498-rqhhz   1/1     Running   0          4m1s
kube-system   calico-node-4mbth                        1/1     Running   0          4m1s
kube-system   calico-node-624z2                        1/1     Running   0          4m1s
kube-system   calico-node-646qq                        1/1     Running   0          4m1s
kube-system   calico-node-7m4z8                        1/1     Running   0          4m1s
kube-system   calico-node-889qb                        1/1     Running   0          4m1s
kube-system   calico-typha-7746b44b78-kcgkx            1/1     Running   0          4m1s
[root@k8s-master01 ~]# 
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
NAMESPACE     NAME                                     READY   STATUS    RESTARTS   AGE
kube-system   calico-kube-controllers-57cf4498-rqhhz   1/1     Running   0          93s
kube-system   calico-node-4mbth                        1/1     Running   0          93s
kube-system   calico-node-624z2                        1/1     Running   0          93s
kube-system   calico-node-646qq                        1/1     Running   0          93s
kube-system   calico-node-7m4z8                        1/1     Running   0          93s
kube-system   calico-node-889qb                        1/1     Running   0          93s
kube-system   calico-typha-7746b44b78-kcgkx            1/1     Running   0          93s
kube-system   coredns-7c445c467-kmjd7                  1/1     Running   0          10m
kube-system   coredns-7c445c467-xzhn6                  1/1     Running   0          10m
kube-system   etcd-k8s-master01                        1/1     Running   5          10m
kube-system   etcd-k8s-master02                        1/1     Running   70         9m8s
kube-system   etcd-k8s-master03                        1/1     Running   0          8m50s
kube-system   kube-apiserver-k8s-master01              1/1     Running   5          10m
kube-system   kube-apiserver-k8s-master02              1/1     Running   70         9m8s
kube-system   kube-apiserver-k8s-master03              1/1     Running   0          8m50s
kube-system   kube-controller-manager-k8s-master01     1/1     Running   5          10m
kube-system   kube-controller-manager-k8s-master02     1/1     Running   2          9m8s
kube-system   kube-controller-manager-k8s-master03     1/1     Running   2          8m50s
kube-system   kube-proxy-74c8q                         1/1     Running   0          8m52s
kube-system   kube-proxy-g6mcf                         1/1     Running   0          8m31s
kube-system   kube-proxy-lcrv7                         1/1     Running   0          10m
kube-system   kube-proxy-qbvc8                         1/1     Running   0          8m41s
kube-system   kube-proxy-vxhh9                         1/1     Running   0          9m10s
kube-system   kube-scheduler-k8s-master01              1/1     Running   5          10m
kube-system   kube-scheduler-k8s-master02              1/1     Running   2          9m8s
kube-system   kube-scheduler-k8s-master03              1/1     Running   2          8m50s
[root@k8s-master01 ~]# 
```

## 集群验证

### 部署pod资源

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
    image: docker.io/library/busybox:1.28
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

### 用pod解析默认命名空间中的kubernetes

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

### 测试跨命名空间是否可以解析

```shell
# 查看有那些name
kubectl  get svc -A
NAMESPACE     NAME              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)         AGE
default       kubernetes        ClusterIP   10.96.0.1       <none>        443/TCP         76m
kube-system   calico-typha      ClusterIP   10.105.100.82   <none>        5473/TCP        35m
kube-system   coredns-coredns   ClusterIP   10.96.0.10      <none>        53/UDP,53/TCP   8m14s
kube-system   metrics-server    ClusterIP   10.105.60.31    <none>        443/TCP         109s

# 进行解析
kubectl exec  busybox -n default -- nslookup coredns-coredns.kube-system
Server:    10.96.0.10
Address 1: 10.96.0.10 coredns-coredns.kube-system.svc.cluster.local

Name:      coredns-coredns.kube-system
Address 1: 10.96.0.10 coredns-coredns.kube-system.svc.cluster.local
[root@k8s-master01 metrics-server]# 
```

### 每个节点都必须要能访问Kubernetes的kubernetes svc 443和kube-dns的service 53

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

### Pod和Pod之前要能通

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
/ # ping 192.168.1.34
PING 192.168.1.34 (192.168.1.34): 56 data bytes
64 bytes from 192.168.1.34: seq=0 ttl=63 time=0.358 ms
64 bytes from 192.168.1.34: seq=1 ttl=63 time=0.668 ms
64 bytes from 192.168.1.34: seq=2 ttl=63 time=0.637 ms
64 bytes from 192.168.1.34: seq=3 ttl=63 time=0.624 ms
64 bytes from 192.168.1.34: seq=4 ttl=63 time=0.907 ms

# 可以连通证明这个pod是可以跨命名空间和跨主机通信的
```

### 创建三个副本，可以看到3个副本分布在不同的节点上（用完可以删了）

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

## 测试IPV6

```shell
# 创建测试服务
[root@k8s-master01 ~]# cat > cby.yaml << EOF 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: chenby
spec:
  replicas: 3
  selector:
    matchLabels:
      app: chenby
  template:
    metadata:
      labels:
        app: chenby
    spec:
      containers:
      - name: chenby
        image: nginx
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
  ipFamilyPolicy: RequireDualStack
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

[root@k8s-master01 ~]# kubectl  apply -f cby.yaml 

# 查看pod情况
[root@k8s-master01 ~]# kubectl  get pod
NAME                      READY   STATUS    RESTARTS   AGE
chenby-868fd8f687-727hd   1/1     Running   0          23s
chenby-868fd8f687-lrxsr   1/1     Running   0          23s
chenby-868fd8f687-n7f2k   1/1     Running   0          23s
[root@k8s-master01 ~]#

# 查看svc情况
[root@k8s-master01 ~]# kubectl get svc 
NAME         TYPE        CLUSTER-IP                 EXTERNAL-IP   PORT(S)        AGE
chenby       NodePort    2408:822a:730:af01::4466   <none>        80:30921/TCP   2m40s
kubernetes   ClusterIP   10.96.0.1                  <none>        443/TCP        58m
[root@k8s-master01 ~]# 

# 在集群内访问，需要在pod所在的节点上执行测试
[root@k8s-node01 ~]# curl -g -6 [2408:822a:730:af01::4466]
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
[root@k8s-node01 ~]# 

# 在集群内访问node地址，集群内需要在pod所在的节点上执行测试，集群外任意节点即可访问
[root@k8s-node01 ~]# curl -g -6 [2408:822a:730:af01::bcf]:30921
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
[root@k8s-node01 ~]#

# 测试ipv4地址
[root@k8s-master01 ~]# curl  http://192.168.1.31:30921/
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
[root@k8s-master01 ~]# 

```

## 安装Metrics-Server

```shell
# 下载 
wget https://mirrors.chenby.cn/https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# 修改配置
vim components.yaml

# 修改此处 添加   - --kubelet-insecure-tls
      - args:
        - --cert-dir=/tmp
        - --secure-port=10250
        - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
        - --kubelet-use-node-status-port
        - --metric-resolution=15s
        - --kubelet-insecure-tls


# 修改镜像地址
sed -i "s#registry.k8s.io/metrics-server#registry.aliyuncs.com/google_containers#g" components.yaml
cat components.yaml | grep image


[root@k8s-master01 ~]# kubectl apply -f components.yaml

# 需要稍等一会才可查看到
[root@k8s-master01 ~]# kubectl  top node
NAME           CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%   
k8s-master01   196m         4%     2270Mi          58%       
k8s-master02   165m         4%     1823Mi          47%       
k8s-master03   162m         4%     1784Mi          46%       
k8s-node01     72m          1%     1492Mi          38%       
k8s-node02     62m          1%     1355Mi          35%       
[root@k8s-master01 ~]# 
```

## 安装HELM

```shell
wget https://mirrors.huaweicloud.com/helm/v3.14.4/helm-v3.14.4-linux-amd64.tar.gz
tar xvf helm-*-linux-amd64.tar.gz
cp linux-amd64/helm /usr/local/bin/
```

## 安装dashboard

```shell
# 添加源信息
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/

# 默认参数安装
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kube-system

# 我的集群使用默认参数安装 kubernetes-dashboard-kong 出现异常 8444 端口占用
# 使用下面的命令进行安装，在安装时关闭kong.tls功能
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --namespace kube-system --set kong.admin.tls.enabled=false
```

### 更改dashboard的svc为NodePort，如果已是请忽略

```shell
kubectl edit svc  -n kube-system kubernetes-dashboard-kong-proxy
  type: NodePort
```

### 查看端口号

```shell
[root@k8s-master01 ~]# kubectl get svc kubernetes-dashboard-kong-proxy -n kube-system
NAME                              TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)         AGE
kubernetes-dashboard-kong-proxy   NodePort   10.96.247.74   <none>        443:32457/TCP   2m29s
[root@k8s-master01 ~]# 
```

### 创建token

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
eyJhbGciOiJSUzI1NiIsImtpZCI6Ikk0dXVHN05BZ0k3VXQ1ekR3NkMzTThad2tzVkpEbFp0bjAyR1lRYlpObmMifQ.eyJhdWQiOlsiaHR0cHM6Ly9rdWJlcm5ldGVzLmRlZmF1bHQuc3ZjLmNsdXN0ZXIubG9jYWwiXSwiZXhwIjoxNzE0ODg1NDYzLCJpYXQiOjE3MTQ4ODE4NjMsImlzcyI6Imh0dHBzOi8va3ViZXJuZXRlcy5kZWZhdWx0LnN2Yy5jbHVzdGVyLmxvY2FsIiwianRpIjoiNWYzYzkxYjctZDMzYy00ZjcwLTg0OTEtMmEwNTVmYzI1ZThhIiwia3ViZXJuZXRlcy5pbyI6eyJuYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsInNlcnZpY2VhY2NvdW50Ijp7Im5hbWUiOiJhZG1pbi11c2VyIiwidWlkIjoiZjdjYmFmMGItOGVkMC00ZmU4LThlNGUtZGUwZDEzZDk5ZDJhIn19LCJuYmYiOjE3MTQ4ODE4NjMsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDprdWJlLXN5c3RlbTphZG1pbi11c2VyIn0.JELSXYQM7fRt4ccaBhBe1O_rMvvVGtv_NzN3Hr8TIzxGTc0yvv3lwSP8SygFQVI3a60Y3ZU45khjqYJ5MbmJfO_t3BtjjMXE-WXmqTK4_lSS0urkmZ_7yxwJNwq4keAQYRIXcOJzzEwbhKhKblRoY5GgssW93nAOfcHZZNy2hKXzmlnzBoMbg46P2TmcSeYitYq4yLL877KALvQVUg7OWcUnX68NGWM3kW78Uakurjcx7WGSOZRm-vS2VWn3iyf--3Jz2v-oUHmtPUEj82SE0rXnBMC_VlrSlWBR34gk0p7NLeblAlmuqiY7FEOkWyHbtQmGZuCVm0DUtGnMsqAfew
```

### 创建长期token

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

eyJhbGciOiJSUzI1NiIsImtpZCI6Ikk0dXVHN05BZ0k3VXQ1ekR3NkMzTThad2tzVkpEbFp0bjAyR1lRYlpObmMifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJhZG1pbi11c2VyIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6ImFkbWluLXVzZXIiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiJmN2NiYWYwYi04ZWQwLTRmZTgtOGU0ZS1kZTBkMTNkOTlkMmEiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6a3ViZS1zeXN0ZW06YWRtaW4tdXNlciJ9.B5UxbBooSeV5M9PfOhSp5bCwBs5434u3y1tjCmfEuKKfUYbwYMq2jsjm4n9M816kKWG30NoQ8aqVxfJK2EKThSURLMhhr4idq2E_ndftXel-fE4dqDfHj8jfDcuvfXMXJhsNFkD6jcQW25aMl_W1u8_5A5xNAE9EkspkQWYAiBFJHZO6jd5Evt134Q0i9mPGqw-kqK7QOaBoVlYPlJd4jPdrPUoIyx0VLj9rjNcYTFWhe_qkBndcu28nM33NfG9D-Qj6Z29_-rT3BrpCfe54S3ihdsn5YNxu3UQrKM6Vaquwgq0Z4SnMHUfSvV1OwsYGLeLC6gb8dgtVhwF5tJIuAQ
```



### 登录dashboard

https://192.168.1.31:32457/

## ingress安装

### 执行部署

```shell
wget https://mirrors.chenby.cn/https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml

# 修改为国内源 docker源可选
sed -i "s#registry.k8s.io#k8s.dockerproxy.com#g" *.yaml
cat deploy.yaml | grep image

cat > backend.yaml << EOF
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

kubectl  apply -f deploy.yaml 
kubectl  apply -f backend.yaml 


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

### 过滤查看ingress端口

```shell
# 修改为nodeport
kubectl edit svc -n ingress-nginx   ingress-nginx-controller
type: NodePort

[root@hello ~/yaml]# kubectl  get svc -A | grep ingress
ingress-nginx          ingress-nginx-controller             NodePort    10.104.231.36    <none>        80:32636/TCP,443:30579/TCP   104s
ingress-nginx          ingress-nginx-controller-admission   ClusterIP   10.101.85.88     <none>        443/TCP                      105s
[root@hello ~/yaml]#
```

### ingress测试

```shell
cat >> /etc/hosts <<EOF
192.168.1.31 hello.chenby.cn
192.168.1.31 demo.chenby.cn
EOF

[root@k8s-master01 ~]# curl hello.chenby.cn:32472
[root@k8s-master01 ~]# curl demo.chenby.cn:32472

```

## 安装 Grafana Prometheus Altermanager 套件

### 下载离线包

```shell
# 添加 prometheus-community 官方Helm Chart仓库
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# 下载离线包
helm pull  prometheus-community/kube-prometheus-stack

# 解压下载下来的包
tar xvf kube-prometheus-stack-*.tgz 
```

### 修改镜像地址

```shell
# 进入目录进行修改images地址
cd kube-prometheus-stack/
sed -i "s#registry.k8s.io#k8s.dockerproxy.com#g" charts/kube-state-metrics/values.yaml
sed -i "s#quay.io#quay.dockerproxy.com#g" charts/kube-state-metrics/values.yaml

sed -i "s#registry.k8s.io#k8s.dockerproxy.com#g" values.yaml
sed -i "s#quay.io#quay.dockerproxy.com#g" values.yaml
```

### 安装

```shell
# 进行安装 
helm install  op  .  --create-namespace --namespace op
NAME: op
LAST DEPLOYED: Sun May  5 12:43:26 2024
NAMESPACE: op
STATUS: deployed
REVISION: 1
NOTES:
kube-prometheus-stack has been installed. Check its status by running:
  kubectl --namespace op get pods -l "release=op"

Visit https://github.com/prometheus-operator/kube-prometheus for instructions on how to create & configure Alertmanager and Prometheus instances using the Operator.
```

### 修改 svc

```shell
# 修改 svc 将其设置为NodePort
kubectl  edit svc -n op op-grafana
kubectl  edit svc -n op op-kube-prometheus-stack-prometheus 
        type: NodePort
```



### 查看

```shell
[root@hello ~/yaml]# kubectl --namespace op get pods -l "release=op"
NAME                                                 READY   STATUS    RESTARTS   AGE
op-kube-prometheus-stack-operator-5c586dfc7f-hmqdf   1/1     Running   0          96s
op-kube-state-metrics-57d49c9db4-r2mvn               1/1     Running   0          96s
op-prometheus-node-exporter-7lrks                    1/1     Running   0          96s
op-prometheus-node-exporter-7q2ns                    1/1     Running   0          96s
op-prometheus-node-exporter-9xblm                    1/1     Running   0          96s
op-prometheus-node-exporter-gf6gf                    1/1     Running   0          96s
op-prometheus-node-exporter-h976s                    1/1     Running   0          96s
[root@hello ~/yaml]# 

# 查看svc
[root@hello ~/yaml]# kubectl --namespace op get svc
NAME                                    TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                         AGE
alertmanager-operated                   ClusterIP   None            <none>        9093/TCP,9094/TCP,9094/UDP      2m8s
op-grafana                              NodePort    10.96.28.3      <none>        80:30833/TCP                    2m15s
op-kube-prometheus-stack-alertmanager   ClusterIP   10.96.134.225   <none>        9093/TCP,8080/TCP               2m15s
op-kube-prometheus-stack-operator       ClusterIP   10.96.106.106   <none>        443/TCP                         2m15s
op-kube-prometheus-stack-prometheus     NodePort    10.96.181.73    <none>        9090:31474/TCP,8080:31012/TCP   2m15s
op-kube-state-metrics                   ClusterIP   10.96.168.6     <none>        8080/TCP                        2m15s
op-prometheus-node-exporter             ClusterIP   10.96.43.139    <none>        9100/TCP                        2m15s
prometheus-operated                     ClusterIP   None            <none>        9090/TCP                        2m7s
[root@hello ~/yaml]# 

# 查看POD
root@hello:~# kubectl --namespace op get pod
alertmanager-op-kube-prometheus-stack-alertmanager-0   2/2     Running   0          2m32s
op-grafana-6489698854-bhgc5                            3/3     Running   0          2m39s
op-kube-prometheus-stack-operator-5c586dfc7f-hmqdf     1/1     Running   0          2m39s
op-kube-state-metrics-57d49c9db4-r2mvn                 1/1     Running   0          2m39s
op-prometheus-node-exporter-7lrks                      1/1     Running   0          2m39s
op-prometheus-node-exporter-7q2ns                      1/1     Running   0          2m39s
op-prometheus-node-exporter-9xblm                      1/1     Running   0          2m39s
op-prometheus-node-exporter-gf6gf                      1/1     Running   0          2m39s
op-prometheus-node-exporter-h976s                      1/1     Running   0          2m39s
prometheus-op-kube-prometheus-stack-prometheus-0       2/2     Running   0          2m31s
root@hello:~# 
```



### 访问

```shell
# 访问
http://192.168.1.31:30833
http://192.168.1.31:31474

user： admin
password： prom-operator
```

## 安装命令行自动补全功能

```shell
yum install bash-completion -y
source /usr/share/bash-completion/bash_completion
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> ~/.bashrc
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
