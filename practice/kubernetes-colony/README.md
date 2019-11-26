# 环境准备
**本次集群使用的是域名的方式进行不部署，所以一定要配置好域名解析**  
**不使用域名解析的方式，只需要把对应的域名改成ip即可使用**
## 基础环境准备
1. 准备三台服务器，一台master，两台node节点
  ```shell
    CentOS7.6.1810
    2核4G内存
    50G硬盘
  ```
2. 配置好`hosts`解析
  ```shell
  echo "10.10.10.5 k8s01.example.com" >> /etc/hosts
  echo "10.10.10.6 k8s02.example.com"  >> /etc/hosts
  echo "10.10.10.7 k8s03.example.com"  >> /etc/hosts
  ```
3. 关闭防火墙，selinux

  ```shell
  systemctl stop firewall
  systemctl disable firewall
  sed -i 's#SELINUX=enforcing#SELINUX=disabled#g' /etc/selinux/config
  ```
4. 关闭swap
  ```shell
  sed -ri 's/.*swap.*/#&/' /etc/fstab
  swapoff -a
  ```
5. 同步时间
  ```shell
  ntpdate ntp1.aliyun.com
  echo '*/5 * * * * root ntpdate ntp1.aliyun.com > /dev/null 2>&1' >> /etc/crontab
  ```
6. 解释EOF前面加`\`就不会转义例如
  ```shell
  cat > 1.log << \EOF
  \a
  $a
  EOF
  ```
