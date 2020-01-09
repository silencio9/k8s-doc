# 利用kubeadm 部署 kubernetes

## kubeadm 介绍

github地址： [点击此处](https://github.com/kubernetes/kubeadm)      
官网安装地址： [点击此处](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)     
详细介绍地址： [点击此处](https://github.com/kubernetes/kubeadm/blob/master/docs/design/design_v1.10.md)    

## 节点分配

配置信息：  
1. CentOS7.6
2. 2 GB 以上
3. 2 核以上
4. 小写的主机名
5. Swap disabled.
6. 充足的硬盘空间
url = https://github.com/AgoCan/dockerfile.git
***虚拟机部署的时候最好把内存调高一点，不然会把物理机的cpu给撑到100%***

|节点|ip地址|节点角色|
|-|-|-|
|k8s-master01.example.com|10.10.10.5|master|
|k8s-node01.example.com|10.10.10.6|node01|
|k8s-node02.example.com|10.10.10.7|node02|

设置主机名

```shell
hostnamectl set-hostname k8s-master01.example.com
# hostnamectl set-hostname k8s-node01.example.com
# hostnamectl set-hostname k8s-node02.example.com
cat >> /etc/hosts << EOF
10.10.10.5 k8s-master01.example.com k8s-master01
10.10.10.6 k8s-node01.example.com k8s-node01
10.10.10.7 k8s-node02.example.com k8s-node02
EOF
```
准备工作
```shell
# 关闭selinux
sed -i 's#SELINUX=enforcing#SELINUX=disabled#g' /etc/selinux/config
# 关闭防火墙
systemctl stop firewalld
systemctl disable firewalld
# 有swap的话
sed -ri 's/.*swap.*/#&/' /etc/fstab
swapoff -a
# 增大文件描述数值 默认1024
echo "* soft nofile 65536" >> /etc/security/limits.conf
echo "* hard nofile 65536" >> /etc/security/limits.conf
echo "* soft nproc 65536"  >> /etc/security/limits.conf
echo "* hard nproc 65536"  >> /etc/security/limits.conf
echo "* soft  memlock  unlimited"  >> /etc/security/limits.conf
echo "* soft  memlock  unlimited"  >> /etc/security/limits.conf
# 修改一些内核
cat >> /etc/sysctl.conf << EOF
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1

vm.swappiness = 0
net.ipv4.neigh.default.gc_stale_time=120
net.ipv4.ip_forward = 1

# see details in https://help.aliyun.com/knowledge_detail/39428.html
net.ipv4.conf.all.rp_filter=0
net.ipv4.conf.default.rp_filter=0
net.ipv4.conf.default.arp_announce = 2
net.ipv4.conf.lo.arp_announce=2
net.ipv4.conf.all.arp_announce=2


# see details in https://help.aliyun.com/knowledge_detail/41334.html
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 1024
net.ipv4.tcp_synack_retries = 2
kernel.sysrq = 1

# iptables透明网桥的实现
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-arptables = 1
EOF
yum install -y ipvsadm
# 增加ipvs
cat > /etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF
chmod 755 /etc/sysconfig/modules/ipvs.modules && bash /etc/sysconfig/modules/ipvs.modules && lsmod | grep -e ip_vs -e nf_conntrack_ipv4
# 不升级为ipvs的话。calico的pod和service是不通的
```


## 操作具体步骤

### 1. 增加源并安装

docker
```shell
wget -O /etc/yum.repos.d/docker-ce.repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

# 查看docker-ce版本
yum --showduplicates list docker-ce

# 安装docker-ce
yum -y install docker-ce
```

kubernetes
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
yum -y install kubeadm-1.15.2 kubelet-1.15.2 kubectl-1.15.2
```
设置开机自启
```shell
systemctl enable docker kubelet

```

### 2. 拉取镜像
查看使用的镜像然后用一下的命令进行替换
```shell
kubeadm config images list
```
如何直接修改库文件可以查看文末  
```shell
systemctl start docker
# 拉取镜像（all）
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-controller-manager:v1.15.2
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-scheduler:v1.15.2
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy:v1.15.2
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.1
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/etcd:3.3.10
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/coredns:1.3.1
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver:v1.15.2

# 对镜像重新改名（all）
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-controller-manager:v1.15.2 k8s.gcr.io/kube-controller-manager:v1.15.2
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-scheduler:v1.15.2 k8s.gcr.io/kube-scheduler:v1.15.2
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy:v1.15.2 k8s.gcr.io/kube-proxy:v1.15.2
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.1 k8s.gcr.io/pause:3.1
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/etcd:3.3.10 k8s.gcr.io/etcd:3.3.10
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/coredns:1.3.1 k8s.gcr.io/coredns:1.3.1
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver:v1.15.2 k8s.gcr.io/kube-apiserver:v1.15.2
```

### 3. master初始化

```shell
kubeadm init --kubernetes-version=v1.15.2 --pod-network-cidr=10.244.0.0/16 \
        --service-cidr=10.96.0.0/12 --ignore-preflight-errors=Swap | tee kubeadm_init.txt

# 查看是否健康
kubectl  get componentstatus
# 去掉master污点，测试使用
kubectl taint nodes --all node-role.kubernetes.io/master-
```
部署flannel 网络组建  
github地址: https://github.com/coreos/flannel  
```shell
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

calico

网址 https://docs.projectcalico.org/master/getting-started/kubernetes/installation/calico  
注意版本的对应关系

还需要注意cidr的IP网段去pod一样,请有手动修改`620`行左右的位置，一旦这个跟`pod_dir`不一致的话，就会导致pod的网络有问题，访问不了局域网

### 4. node加入

每次初始化之后最后一句都是不一样的  跟token和证书相关，命令就不复制了  
主要是使用`kubeadm join`进行加入


### 5. 部署dashboard
https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/  
这是token账户的地址  
https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md  
```
wget https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta6/aio/deploy/recommended.yaml
# 修改成nodeport的方式，然后使用
kubectl apply -f recommended.yaml

```
设置token的账户
```yaml
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
```
获取token
```shell
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')
```


## 补充

### 1. kubeadm使用配置文件进行修改源
推荐使用上文的方式来进行pull镜像
```shell
kubeadm config print init-defaults Print default init configuration >> kubeadm.conf
# 修改里面内容imageRepository 对应的仓库改为阿里云仓库的
imageRepository: registry.cn-hangzhou.aliyuncs.com
# 其他版本也需要做相对应的修改
kubernetesVersion: v1.15.2
# 最后运行
kubeadm config images list --config kubeadm.conf
kubeadm config images pull --config kubeadm.conf
kubeadm init --config kubeadm.conf
# 更多详细信息
kubeadm config print-defaults
```

### 2. 证书一年过期问题（未验证、未完待续）

首先需要重新编译kubeadm
```shell
git clone https://github.com/kubernetes/kubernetes.git
# git checkout 1.16.3
vim vendor/k8s.io/client-go/util/cert/cert.go



# 修改证书
```

在kubeadm1.16.3版本的时候，替换证书还是alpha版本  

```shell
# 查看帮助  
kubeadm alpha certs -h
# 查看证书过期时间
kubeadm alpha certs check-expiration
# 查看替换证书命令
kubeadm alpha certs renew -h
# 替换所有证书
kubeadm alpha certs renew all
```

上面的指令需要和`--csr-only`参数进行修改

[参考文档](https://v1-15.docs.kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-certs/)

### 3. kubeadm join 对应的token过期

```
kubeadm token create --ttl 0
# 或者直接创建
kubeadm token create
kubeadm token list
```

然后使用 `kubeadm join` 重新加入
