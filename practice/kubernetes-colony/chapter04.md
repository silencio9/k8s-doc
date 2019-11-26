# kebe-apiserver部署

## 创建config配置文件

注意：请先参考 安装kubectl命令行工具，先在 master 节点上安装 kubectl 然后再进行下面的操作。

kubelet、kube-proxy 等 Node 机器上的进程与 Master 机器的 kube-apiserver 进程通信时需要认证和授权；

kubernetes 1.4 开始支持由 kube-apiserver 为客户端生成 TLS 证书的 TLS Bootstrapping 功能，这样就不需要为每个客户端生成证书了；该功能当前仅支持为 kubelet 生成证书；

因为我的master节点和node节点复用，所有在这一步其实已经安装了kubectl。参考安装kubectl命令行工具。

以下操作只需要在master节点上执行，生成的*.kubeconfig文件可以直接拷贝到node节点的/etc/kubernetes目录下。

## 创建 TLS Bootstrapping Token
Token可以是任意的包含128 bit的字符串，可以使用安全的随机数发生器生成。

```shell
export BOOTSTRAP_TOKEN=$(head -c 16 /dev/urandom | od -An -t x | tr -d ' ')
cat > bootstrap-token.csv <<EOF
${BOOTSTRAP_TOKEN},kubelet-bootstrap,10001,"system:kubelet-bootstrap"
EOF
mv bootstrap-token.csv /etc/kubernetes/ssl/
```

## 创建访问用户

```shell
cat >>  basic-auth.csv  << EOF
admin,admin,1
readonly,readonly,2
# password,usernmae,id
EOF
```

## 创建kube-apiserver.service

```shell
cat >> kube-apiserver.service << \EOF
[Unit]
Description=Kubernetes API Service
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=network.target
After=etcd.service

[Service]
EnvironmentFile=-/etc/kubernetes/kube.conf
EnvironmentFile=-/etc/kubernetes/apiserver.conf
ExecStart=/usr/local/bin/kube-apiserver \
        $KUBE_LOGTOSTDERR \
        $KUBE_LOG_LEVEL \
        $KUBE_ETCD_SERVERS \
        $KUBE_ADVERTISE_ADDRESS \
        $KUBE_API_PORT \
        $KUBELET_PORT \
        $KUBE_ALLOW_PRIV \
        $KUBE_SERVICE_ADDRESSES \
        $KUBE_ADMISSION_CONTROL \
        &KUBE_ETCD_CERT \
        $KUBE_API_CERT \
        $KUBE_BOOTSTRAP \
        $KUBE_NODE_PORT \
        $KUBE_LOG \
        $KUBE_API_ARGS
Restart=on-failure
Type=notify
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
```
kube.conf

```config
KUBE_LOGTOSTDERR="--logtostderr=true"
KUBE_LOG_LEVEL="--v=0"
KUBE_ALLOW_PRIV="--allow-privileged=true"
KUBE_MASTER="--master=http://10.10.10.5:8080"
```

/etc/kubernetes/apiserver.conf

```config
#
KUBE_ADVERTISE_ADDRESS="--advertise-address=10.10.10.5"
KUBE_BIND_ADDRESS="--bind-address=10.10.10.5 --insecure-bind-address=10.10.10.5"

KUBE_ETCD_SERVERS="--etcd-servers=https://10.10.10.5:6379, https://10.10.10.6:6379, https://10.10.10.7:6379,"

KUBE_ETCD_CERT="--etcd-cafile=/etc/kubernetes/ssl/ca.pem --etcd-certfile=/etc/kubernetes/ssl/etcd.pem --etcd-keyfile=/etc/kubernetes/ssl/etcd-key.pem"

KUBE_SERVICE_ADDRESSES="--service-cluster-ip-range=10.96.0.0/16 "
#KUBE_API_PORT="--port=8080"
#
## Port minions listen on
#KUBELET_PORT="--kubelet-port=10250"

KUBE_ADMISSION_CONTROL="--admission-control=ServiceAccount,NamespaceLifecycle,NamespaceExists,LimitRanger,ResourceQuota"
KUBE_API_CERT="--tls-cert-file=/etc/kubernetes/ssl/kubernetes.pem --tls-private-key-file=/etc/kubernetes/ssl/kubernetes-key.pem --client-ca-file=/etc/kubernetes/ssl/ca.pem --service-account-key-file=/etc/kubernetes/ssl/ca-key.pem "
KUBE_BOOTSTRAP="--token-auth-file=/etc/kubernetes/bootstrap-token.csv --enable-bootstrap-token-auth"

KUBE_NODE_PORT="--service-node-port-range=30000-32767"

KUBE_LOG="--audit-log-maxage=30 --audit-log-maxbackup=3 --audit-log-maxsize=100 --audit-log-path=/var/lib/audit.log"

KUBE_API_ARGS="--authorization-mode=Node,RBAC --runtime-config=rbac.authorization.k8s.io/v1beta1    --apiserver-count=3  --event-ttl=1h"

```

启动kube-apiserver
```shell
systemctl daemon-reload
systemctl enable kube-apiserver
systemctl start kube-apiserver
systemctl status kube-apiserver
```
