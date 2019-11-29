# 环境准备
**本次集群使用的是域名的方式进行不部署，所以一定要配置好域名解析**  
**不使用域名解析的方式，只需要把对应的域名改成ip即可使用**  
**此次测试单节点通过，多master的kube-apiserver部署未成功**  

## 基础环境准备
1. 准备三台服务器，一台master，两台node节点
  ```shell
    CentOS7.6.1810
    2核4G内存
    50G硬盘
  ```
2. 配置好`hosts`解析并且分别重命名主机
  ```shell
  echo "10.10.10.5 k8s01.example.com" >> /etc/hosts
  echo "10.10.10.6 k8s02.example.com"  >> /etc/hosts
  echo "10.10.10.7 k8s03.example.com"  >> /etc/hosts
  ```
  ```shell
  hostnamectl set-hostname k8s01.example.com
  #hostnamectl set-hostname k8s02.example.com
  #hostnamectl set-hostname k8s03.example.com
  ```
3. 关闭防火墙，selinux

  ```shell
  systemctl stop firewalld
  systemctl disable firewalld
  sed -i 's#SELINUX=enforcing#SELINUX=disabled#g' /etc/selinux/config
  ```
4. 关闭swap
  ```shell
  sed -ri 's/.*swap.*/#&/' /etc/fstab
  swapoff -a
  ```
5. 同步时间
  ```shell
  yum install ntpdate -y
  ntpdate ntp1.aliyun.com
  echo '*/5 * * * * root ntpdate ntp1.aliyun.com > /dev/null 2>&1' >> /etc/crontab
  ```

6. 安装功能包
  ```shell
  yum install wget lrzsz bash-completion net-tools -y
  ```
7. 增加文件描述符
  ```shell
  # 增大文件描述数值 默认1024
  echo "* soft nofile 65536" >> /etc/security/limits.conf
  echo "* hard nofile 65536" >> /etc/security/limits.conf
  echo "* soft nproc 65536"  >> /etc/security/limits.conf
  echo "* hard nproc 65536"  >> /etc/security/limits.conf
  echo "* soft  memlock  unlimited"  >> /etc/security/limits.conf
  echo "* soft  memlock  unlimited"  >> /etc/security/limits.conf
  ```

8. 内核参数修改
  ```shell
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
  sysctl -p
  ```
9. 支持ipvs
  ```shell
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
  ```

6. 解释EOF前面加`\`就不会转义例如
  ```shell
  cat > 1.log << \EOF
  \a
  $a
  EOF
  ```
