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

ConfigMap

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: www-conf
data:
  www.conf: |
    server {
      listen 81;
    }
```

pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-example-1
  labels:
    app: myapp
spec:
  containers:
  - name: myapp
    image: hank997/webapp:v1
    ports:
    - name: http
      containerPort: 80
    volumeMounts:
    - name: nginxconfig
      mountPath: /home/conf.d/
      readOnly: true
  volumes:
  - name: nginxconfig
    configMap:
      name: www-conf
```

弹性存储  ceph rook 和portworx 
