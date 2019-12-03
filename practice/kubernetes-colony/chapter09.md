# kube-proxy部署

```
yum install -y conntrack-tools
```

```shell
export K8S_API_URL=10.10.10.5
/usr/local/bin/kubectl config set-cluster kubernetes \
--certificate-authority=/etc/kubernetes/ssl/ca.pem \
--embed-certs=true \
--server=https://${K8S_API_URL}:6443 \
--kubeconfig=kube-proxy.kubeconfig

/usr/local/bin/kubectl  config set-credentials kube-proxy \
--client-certificate=/etc/kubernetes/ssl/kube-proxy.pem \
--client-key=/etc/kubernetes/ssl/kube-proxy-key.pem \
--embed-certs=true \
--kubeconfig=kube-proxy.kubeconfig

/usr/local/bin/kubectl  config set-context default \
--cluster=kubernetes \
--user=kube-proxy \
--kubeconfig=kube-proxy.kubeconfig

/usr/local/bin/kubectl  config use-context default --kubeconfig=kube-proxy.kubeconfig

mv kube-proxy.kubeconfig /etc/kubernetes/
```

```shell
cat > kube-proxy.service << \EOF
[Unit]
Description=Kubernetes Kube-Proxy Server
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=network.target

[Service]
WorkingDirectory=/var/lib/kube-proxy
ExecStart=/usr/local/bin/kube-proxy   \
        --bind-address=0.0.0.0   \
        --hostname-override=k8s-master01  
        --kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig \
        --masquerade-all   \
        --feature-gates=SupportIPVSProxyMode=true   \
        --proxy-mode=ipvs   \
        --ipvs-min-sync-period=5s   \
        --ipvs-sync-period=5s   \
        --ipvs-scheduler=rr   \
        --logtostderr=true   \
        --v=2   \
        --logtostderr=false   \
        --log-dir=/var/log/kubernetes

Restart=on-failure
RestartSec=5
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
```
参数介绍
- `--hostname-override` 参数值必须与 kubelet 的值一致，否则 `kube-proxy` 启动后会找不到该 Node，从而不会创建任何 `iptables` 规则；


```
mkdir -p /var/lib/kube-proxy
mv kube-proxy.service /usr/lib/systemd/system/
systemctl daemon-reload
systemctl enable kube-proxy
systemctl start kube-proxy
systemctl status kube-proxy
```
