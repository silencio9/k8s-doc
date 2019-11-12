# 额外，挂载设备的方式
kubernete1.11之前和之后有点小区别


```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: yxs-pv
spec:
  capacity:
    storage: 20Gi
  volumeMode: Block
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Recycle
  local:
    path: /dev/sda
    fsType: xfs
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - node192.168.1.175
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: yxs-pvc
spec:
  accessModes:
    - ReadWriteOnce
  volumeMode: Block
  resources:
    requests:
      storage: 10Gi
---
apiVersion: v1
kind: Pod
metadata:
  name: yxs-pod
spec:
  containers:
  - name: yxstest
    image: hub.tencentyun.com/test_team/test_images:yxstest_v1.0
    command: [ "/bin/bash", "-c", "--" ]
    args: [ "while true; do sleep 30; done;" ]
    volumeDevices:
    - name: test
      devicePath: "/dev/sda"
  volumes:
  - name: test
    persistentVolumeClaim:
      claimName: yxs-pvc
```

挂载宿主机路径

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: hank-jenkins
spec:
  capacity:
    storage: 20Gi
  accessModes:
  - ReadWriteMany
  persistentVolumeReclaimPolicy: Delete
  hostPath:
    path: /data/hank-jenkins

---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: hank-jenkins
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 20Gi
```

