# coredns
官网  https://coredns.io  
github  https://github.com/coredns/coredns  https://github.com/coredns/deployment/tree/master/kubernetes  

```
git clone https://github.com/coredns/deployment.git
cd deployment/kubernetes

```
- 需要修改clusterIP地址。  
- 10.96.0.2 跟kubelet一致  
- 还需要修改一部分的内容  
完整修改后的 [coredns.yaml](/manifests/example/coredns/coredns.yaml)  

修改完之后，使用 `apply` 执行
```
kubectl apply -f coredns.yaml
```
# dashboard

# helm

# metrics
