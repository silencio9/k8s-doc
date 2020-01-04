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
    --cni-bin-dir=/opt/cni/bin/cni   \
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
- `--cni-bin-dir` 指定cni的目录，使用默认即可。 一旦找不到cni的插件。`kubectl get node`会发现部署完网络插件之后节点却还一直都是`NotReady`

```
mv kubelet.service /usr/lib/systemd/system/
systemctl daemon-reload
systemctl enable kubelet
systemctl start kubelet
systemctl status kubelet
```

其他节点
```
scp /etc/kubernetes/bootstrap.kubeconfig  10.10.10.6:/etc/kubernetes/
scp /etc/kubernetes/bootstrap.kubeconfig  10.10.10.7:/etc/kubernetes/
```

注意：

```
kubelet 安装之后，使用systemctl start 的时候会报错， 说命令找不到
重启服务器之后就好了
```

# 到master节点执行
```
/usr/local/bin/kubectl get csr
/usr/local/bin/kubectl get csr|grep 'Pending' | awk 'NR>0{print $1}'| xargs kubectl certificate approve
/usr/local/bin/kubectl get node
```




## 为master打上标签

```
/usr/local/bin/kubectl label node k8s-master01 node-role.kubernetes.io/master=k8s-master01
/usr/local/bin/kubectl label node k8s-node01 node-role.kubernetes.io/node=k8s-node01
kubectl get node --show-labels
# 删除所有节点的标签
kubectl  label node --all kubernetes.io/role-
```

如果不让调度

```shell
kubectl  patch node 10.10.10.5 -p '{"spec":{"unschedulable":true}}'
# 相对应的
kubectl  patch node 10.10.10.5 -p '{"spec":{"unschedulable":false}}'
```
查看,出现SchedulingDisabled
```shell
[root@demo ansible]# kubectl  get node
NAME            STATUS                     ROLES    AGE   VERSION
10.10.10.5   Ready,SchedulingDisabled   master   78m   v1.16.2
```

## 注意

1. 这个部署，`kubelet`的启动有问题。 需要在系统起来之后执行
  ```
  systemctl stop kubelet
  systemctl start kubelet
  ```

2. `bubelet`加入节点后，会在加目录加入 `.kube`的目录，该目录是cni的主要目录，不能丢失，不然创建容器会出现如下的错误

```
Events:
  Type     Reason                  Age                    From                   Message
  ----     ------                  ----                   ----                   -------
  Normal   Scheduled               <unknown>              default-scheduler      Successfully assigned profession-cvmart-project/profession-cvmart-project-1-instance-1-train-11-b5kjg to 192.168.1.80
  Warning  FailedCreatePodSandBox  6m2s                   kubelet, 192.168.1.80  Failed create pod sandbox: rpc error: code = Unknown desc = failed to set up sandbox container "d75ef828dbc4ec744684d5973a7cb05ef73f8aab1920b661887321069d9194d2" network for pod "profession-cvmart-project-1-instance-1-train-11-b5kjg": networkPlugin cni failed to set up pod "profession-cvmart-project-1-instance-1-train-11-b5kjg_profession-cvmart-project" network: stat /root/.kube/config: no such file or directory
```

修复：

```
拿其他的节点的.kube 目录scp过来即可。
```
