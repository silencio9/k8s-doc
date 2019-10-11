简单的nfs使用
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs01
  labels:
    name: nfs01
spec:
  nfs:
    path: /data/ev-www
    server: ev-k8s01.hankbook.com
  accessModes:
    - ReadWriteMany
  capacity:
    storage: 5Gi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nfs-pvc01
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 5Gi
```

测试的pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hank-pod
spec:
  containers:
  - name: hanktest
    image: hank997/webapp:v1
    volumeMounts:
    - name: test
      mountPath: /var/test-www
  volumes:
  - name: test
    persistentVolumeClaim:
      claimName: nfs-pvc01
```
