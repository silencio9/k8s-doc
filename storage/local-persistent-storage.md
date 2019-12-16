# 注意
`hostpath`一旦pvc指定了亲和性节点名称，那么`pod`的使用也需要指定到那一台机器上面
```
nodeAffinity:
  required:
    nodeSelectorTerms:
    - matchExpressions:
      - key: kubernetes.io/hostname
        operator: In
        values:
        - 10.10.10.5
```
