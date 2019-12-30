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
创建pv的时候，需要确保被调度宿主机上面已经安装了nfs客户端  
创建的实质就是在宿主机执行了
```
mount -t nfs 10.10.10.5:/data/data  /var/lib/kubelet/pods/7afed383-ef25-4c39-a5e5-62b459d0afc6/volumes/kubernetes.io~nfs/data
```
所以不符合nfs的方式都会挂载失败
```
yum install -y nfs-utils rpcbind
```

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
    server: 10.10.10.5
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
  name: data
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

# 测试pod

```
apiVersion: v1
kind: Pod
metadata:
  name: webapp01
  labels:
    app: web
    env: prd
spec:
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: data
  containers:
  - name: webapp
    image: hank997/webapp:v1
    volumeMounts:
      - name: data
        mountPath: /data

apiVersion: v1
kind: Pod
metadata:
  name: example-pod
spec:
  containers:
  - name: device-container
    image: hank997/webapp:v1
    volumeMounts:
    - name: test-deivce
      mountPath: /data
  volumes:
  - name: test-deivce
    persistentVolumeClaim:
      claimName: hank-jenkins
```

# 问题
一旦设置了其他方式的storageclass为default。那么PVC和pv的对应关系就会找不到。可以指定
`storageClassName: ""`,该值设置为空即可  
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ev-dataset
  annotations:
    volume.beta.kubernetes.io/storage-class: ""
spec:
  storageClassName: ""
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Ti
  selector:
    matchLabels:
      name: ev-dataset
```
