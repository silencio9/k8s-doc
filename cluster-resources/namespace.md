# 命名空间



## 指定命名空间到指定的节点

[参考文档](https://stackoverflow.com/questions/52487333/how-to-assign-a-namespace-to-certain-nodes)

指定服务器到指定的节点

`ns1.yaml`
```yaml
apiVersion: v1
kind: Namespace
metadata
 name: ns1
 annotations:
   scheduler.alpha.kubernetes.io/node-selector: env=test
spec: {}
status: {}
```

```shell
kubectl apply -f ns1.yaml
```

创建之后，在这个命名空间下的所有`pod`会增加一句话

```
nodeSelector
  env: test
```
