# 创建etcd集群
## TLS 认证文件

ETCD 3.1 之后不支持监听域名，证书需要改成IP形式

需要为 etcd 集群创建加密通信的 TLS 证书，这里使用上次创建的etcd证书

下载二进制文件

https://github.com/coreos/etcd/releases

这里使用的版本是3.2.8

```shell
wget https://github.com/etcd-io/etcd/releases/download/v3.2.28/etcd-v3.2.28-linux-amd64.tar.gz
tar xf etcd-v3.2.28-linux-amd64.tar.gz
mv etcd-v3.2.28-linux-amd64/etcd* /usr/local/bin
# 或者使用yum的方式安装，版本不固定
#yum install etcd

```

## 创建 etcd 的 systemd unit 文件
在/usr/lib/systemd/system/目录下创建文件etcd.service，内容如下。注意替换IP地址为你自己的etcd集群的主机IP。

```
[Unit]
Description=Etcd Server
After=network.target
After=network-online.target
Wants=network-online.target
Documentation=https://github.com/coreos

[Service]
Type=notify
WorkingDirectory=/var/lib/etcd/
EnvironmentFile=-/etc/etcd/etcd.conf
ExecStart=/usr/local/bin/etcd \
  --name ${ETCD_NAME} \
  --cert-file=/etc/kubernetes/ssl/etcd.pem \
  --key-file=/etc/kubernetes/ssl/etcd-key.pem \
  --peer-cert-file=/etc/kubernetes/ssl/etcd.pem \
  --peer-key-file=/etc/kubernetes/ssl/etcd-key.pem \
  --trusted-ca-file=/etc/kubernetes/ssl/ca.pem \
  --peer-trusted-ca-file=/etc/kubernetes/ssl/ca.pem \
  --initial-advertise-peer-urls ${ETCD_INITIAL_ADVERTISE_PEER_URLS} \
  --listen-peer-urls ${ETCD_LISTEN_PEER_URLS} \
  --listen-client-urls ${ETCD_LISTEN_CLIENT_URLS},http://127.0.0.1:2379 \
  --advertise-client-urls ${ETCD_ADVERTISE_CLIENT_URLS} \
  --initial-cluster-token ${ETCD_INITIAL_CLUSTER_TOKEN} \
  --initial-cluster ${ETCD_INITIAL_CLUSTER} \
  --initial-cluster-state new \
  --data-dir=${ETCD_DATA_DIR}
Restart=on-failure
RestartSec=5
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
```
- 指定 etcd 的工作目录为 /var/lib/etcd，数据目录为 /var/lib/etcd，需在启动服务前创建这个目录，否则启动服务的时候会报错“Failed at step CHDIR spawning /usr/bin/etcd: No such file or directory”；
- 为了保证通信安全，需要指定 etcd 的公私钥(cert-file和key-file)、Peers 通信的公私钥和 CA 证书(peer-cert-file、peer-key-file、peer-trusted-ca-file)、客户端的CA证书（trusted-ca-file）；
- 创建 kubernetes.pem 证书时使用的 kubernetes-csr.json 文件的 hosts 字段包含所有 etcd 节点的IP，否则证书校验会出错；
- --initial-cluster-state 值为 new 时，--name 的参数值必须位于 --initial-cluster 列表中；
**需要了解更多的参数使用etcd --help 进行查看**

环境变量配置文件`/etc/etcd/etcd.conf`
```shell
mkdir -p /etc/etcd/

```

```config
# [member]
ETCD_NAME=etcd-node01
ETCD_DATA_DIR="/var/lib/etcd"
ETCD_LISTEN_PEER_URLS="https://10.10.10.5:2380"
ETCD_LISTEN_CLIENT_URLS="https://10.10.10.5:2379"

#[cluster]
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://10.10.10.5:2380"
ETCD_INITIAL_CLUSTER="etcd-node01=https://k8s01.example.com:2380, etcd-node02=https://k8s02.example.com:2380, etcd-node03=https://k8s03.example.com:2380"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_ADVERTISE_CLIENT_URLS="https://10.10.10.5:2379"
```
**注意**： 监听地址修改成对应主机的IP地址  
这是10.10.10.5节点的配置，其他两个etcd节点只要将上面的IP地址改成相应节点的IP地址即可。ETCD_NAME换成对应节点的etcd-node01 etcd-node02 etcd-node03 。

其中 **`ETCD_INITIAL_CLUSTER`** 是指定集群的机器

## 启动 etcd 服务

```
mkdir -p /var/lib/etcd
mv etcd.service /usr/lib/systemd/system/
systemctl daemon-reload
systemctl enable etcd
systemctl start etcd
systemctl status etcd
```

在所有的 kubernetes master 节点重复上面的步骤，直到所有机器的 etcd 服务都已启动。

如果打开的防火墙，请把2379和2380端口开发，以centos7为例：  

```
firewall-cmd --zone=public --add-port=2380/tcp --permanent
firewall-cmd --zone=public --add-port=2379/tcp --permanent
firewall-cmd --reload
```

## 验证服务
在任一 kubernetes master 机器上执行如下命令：
```
$ etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --ca-file=/etc/kubernetes/ssl/ca.pem \
  --cert-file=/etc/kubernetes/ssl/etcd.pem \
  --key-file=/etc/kubernetes/ssl/etcd-key.pem \
  cluster-health
```
结果最后一行为 cluster is healthy 时表示集群服务正常。
