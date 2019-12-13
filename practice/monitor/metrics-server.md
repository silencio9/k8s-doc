# 安装metrics-server

[sig-GitHub地址](https://github.com/kubernetes-sigs/metrics-server)  
[官方github目录](https://github.com/kubernetes/kubernetes/tree/master/cluster/addons/metrics-server)  

由于官方的有些yaml文件使用了模版形式，[点击查看yaml](/manifests/example/metrics-server) 仓库把那些模版给注释了  
安装
```shell
# 下载所有文件到本地
kubectl -f ./metrics-server/
```
以下是官方
```shell
# 使用官方的，需要自行注释或修改配置文件
git clone https://github.com/kubernetes/kubernetes.git
cd cluster/addons/
kubectl -f ./metrics-server/
```
