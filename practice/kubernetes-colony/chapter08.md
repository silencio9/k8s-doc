# kubelet部署

```
/usr/local/bin/kubectl create clusterrolebinding kubelet-bootstrap --clusterrole=system:node-bootstrapper --user=kubelet-bootstrap

```

```
export K8S_API_URL=10.10.10.5
/usr/local/bin/kubectl config set-cluster kubernetes \
--certificate-authority=/etc/kubernetes/ssl/ca.pem \
--embed-certs=true \
--server=https://${K8S_API_URL}:6443 \
--kubeconfig=bootstrap.kubeconfig
```

```
export TOKEN=$(awk -F "," '{print $1}' /etc/kubernetes/ssl/bootstrap-token.csv)
/usr/local/bin/kubectl config set-credentials kubelet-bootstrap \
--token=${TOKEN} \
--kubeconfig=bootstrap.kubeconfig
```

```
/usr/local/bin/kubectl config set-context default \
--cluster=kubernetes \
--user=kubelet-bootstrap \
--kubeconfig=bootstrap.kubeconfig
```

```
/usr/local/bin/kubectl config use-context default --kubeconfig=bootstrap.kubeconfig
```

```
mv bootstrap.kubeconfig /etc/kubernetes/
```

```shell
cat > kubelet.service << \EOF
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=docker.service
Requires=docker.service

[Service]
WorkingDirectory=/var/lib/kubelet
ExecStart=/usr/local/bin/kubelet  \
    --hostname-override=k8s-master01   \
    --pod-infra-container-image=mirrorgooglecontainers/pause-amd64:3.1   \
    --bootstrap-kubeconfig=/etc/kubernetes/bootstrap.kubeconfig   \
    --kubeconfig=/etc/kubernetes/kubelet.kubeconfig   \
    --cert-dir=/etc/kubernetes/ssl   \
    --network-plugin=cni   \
    --cni-conf-dir=/etc/cni/net.d   \
    --cni-bin-dir=/usr/local/bin/cni   \
    --cluster-dns=10.96.0.2   \
    --cluster-domain=cluster.local.   \
    --hairpin-mode hairpin-veth   \
    --fail-swap-on=false   \
    --logtostderr=true   \
    --v=2   \
    --logtostderr=false   \
    --log-dir=/var/log/kubernetes   \
    --feature-gates=DevicePlugins=true
Restart=on-failure
RestartSec=5
EOF
```

参数介绍
- `--hostname-override`是节点名称，最好和主机名一一对应
-

```
mv kubelet.service /usr/lib/systemd/system/
systemctl daemon-reload
systemctl enable kubelet
systemctl start kubelet
systemctl status kubelet
```

其他节点
```
scp /etc/kubernetes/kubelet.kubeconfig  10.10.10.6:/etc/kubernetes/
scp /etc/kubernetes/kubelet.kubeconfig  10.10.10.7:/etc/kubernetes/
```

# 到master节点执行
```
/usr/local/bin/kubectl get csr
/usr/local/bin/kubectl get csr|grep 'Pending' | awk 'NR>0{print $1}'| xargs kubectl certificate approve
/usr/local/bin/kubectl get node
```




## 为master打上标签
