# 让nfs支持storageclass

[点击查看github文档](https://github.com/kubernetes-incubator/external-storage/tree/master/nfs-client)

部署nfs按照[nfs](/practice/storage/nfs/nfs.md)进行部署服务端

克隆代码下来，并且修改  

```shell
git clone https://github.com/kubernetes-incubator/external-storage.git
cd external-storage/nfs-client/deploy/
# 替换nfs服务端地址
sed -i 's#10.10.10.60#10.10.10.5#g' deployment.yaml
# 替换挂载的目录, 一个是环境变量，一个是volume的值都得替换成nfs服务端有的目录
sed -i 's#/ifs/kubernetes#/data/data#g' deployment.yaml
# 创建deployment
kubectl  apply -f deployment.yaml
# 创建rbac
kubectl apply -f rbac.yaml
# 创建StorageClass
kubectl apply -f class.yaml
```
测试
```shell
# 创建pvc
kubectl apply -f test-claim.yaml
# 创建pod 因为使用的是go的域名，是外网，修改一下域名地址
# 修改镜像
sed -i 's#gcr.io/google_containers/busybox:1.24#busybox#g' test-pod.yaml
kubectl apply -f test-pod.yaml
```

[deployment](/manifests/example/nfs-storageclass/client/deployment.yaml)  
[class](/manifests/example/nfs-storageclass/client/class.yaml)  
[rbac](/manifests/example/nfs-storageclass/client/rabc.yaml)  
[test-claim](/manifests/example/nfs-storageclass/client/test-claim.yaml)  
[test-pod](/manifests/example/nfs-storageclass/client/test-pod.yaml)  
