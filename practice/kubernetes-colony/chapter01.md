# 二进制的下载

## 下载kubernetes
kubernetes在内网下载非常慢，不推荐直接下载，我把二进制文件打包在百度云中，方便所有人下载

url: https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.16.md#downloads-for-v1163  
其中server包含了所有的二进制包，既，可只下载server的包即可
```shell
# 客户端下载
wget https://dl.k8s.io/v1.16.3/kubernetes-client-linux-amd64.tar.gz
# 服务端下载
wget https://dl.k8s.io/v1.16.3/kubernetes-server-linux-amd64.tar.gz
# 节点下载
wget https://dl.k8s.io/v1.16.3/kubernetes-node-linux-amd64.tar.gz
```

百度云地址

```shell
# 下载后请去github匹配一下md5码，不保证是否被串改，主要是针对生产环境的谨慎
链接：https://pan.baidu.com/s/1dPdsKdCDOeoBUsegxnp1EA
提取码：37ap
```

```shell
tar xf kubernetes-client-linux-amd64.tar.gz
tar xf kubernetes-server-linux-amd64.tar.gz
tar xf kubernetes-node-linux-amd64.tar.gz

mv kubernetes/client/bin/kubectl /usr/local/bin/
mv kubernetes/node/bin/kubelet kubernetes/node/bin/kube-proxy /usr/local/bin/
mv kubernetes/server/bin/kube-apiserver kubernetes/server/bin/kube-controller-manager kubernetes/server/bin/kube-scheduler /usr/local/bin/
```
