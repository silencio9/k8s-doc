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
cat >> kube-apiserver.service << EOF
[Unit]
Description=Kubernetes API Service
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=network.target
After=etcd.service

[Service]
EnvironmentFile=-/etc/kubernetes/config
EnvironmentFile=-/etc/kubernetes/apiserver.conf
ExecStart=/usr/local/bin/kube-apiserver \
        $KUBE_LOGTOSTDERR \
        $KUBE_LOG_LEVEL \
        $KUBE_ETCD_SERVERS \
        $KUBE_API_ADDRESS \
        $KUBE_API_PORT \
        $KUBELET_PORT \
        $KUBE_ALLOW_PRIV \
        $KUBE_SERVICE_ADDRESSES \
        $KUBE_ADMISSION_CONTROL \
        $KUBE_API_ARGS
Restart=on-failure
Type=notify
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
```

/etc/kubernetes/apiserver.conf

```

```
