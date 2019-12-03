# coredns
官网  https://coredns.io  
github  https://github.com/coredns/coredns  https://github.com/coredns/deployment/tree/master/kubernetes  

```
wget https://raw.githubusercontent.com/coredns/deployment/master/kubernetes/coredns.yaml.sed -O coredns.yaml
# 需要修改clusterIP地址。
#10.96.0.2 跟kubelet一致
kubectl apply -f coredns.yaml
```
# dashboard

# helm

# metrics
