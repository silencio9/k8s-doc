# NFS 的部署

```shell
yum install -y nfs-utils rpcbind
# 创建用户
useradd -s /sbin/nologin -M -u 1000 nfs
```

`/etc/exports`

```
/data/data 10.10.10.0/24(rw,sync,all_squash,anonuid=1000,anongid=1000)
/data/images 10.10.10.0/24(rw,sync,all_squash,anonuid=1000,anongid=1000)
/data/harbor-registry 10.10.10.0/24(rw,sync,all_squash,anonuid=1000,anongid=1000)
```

# 创建pv
```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: data
  labels:
    name: data
spec:
  nfs:
    path: /data/data
    server: k8s01.extremevision.com.cn
  accessModes:
    - ReadWriteMany
  capacity:
    storage: 50Gi
```
# 创建pvc
```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: /data/data
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 50Gi
  selector:
    matchLabels:
      name: data
```
