# 清理集群

如果要拆除群集并启动一个新群集，请注意以下需要清除的资源：

- `rook-ceph`名称空间：由`operator.yaml`和创建的`Rook`运算符和集群`cluster.yaml`（集群CRD）
- `/var/lib/rook`：集群中每台主机上的路径，其中`ceph mons`和`osds`缓存配置  
请注意，如果您更改了默认名称空间或路径（例如`dataDirHostPath`示例`yaml`文件中的路径），则需要在这些说明中调整这些名称空间和路径。

**删除块和文件工件**  
首先，您需要清理在Rook群集顶部创建的资源

这些命令将从块和文件演练中清除资源（卸载卷，删除卷声明等）。如果您没有完成本演练的那些部分，则可以跳过以下说明：

```
kubectl delete -f ../wordpress.yaml
kubectl delete -f ../mysql.yaml
kubectl delete -n rook-ceph cephblockpool replicapool
kubectl delete storageclass rook-ceph-block
kubectl delete -f csi/cephfs/kube-registry.yaml
kubectl delete storageclass rook-cephfs
```

**删除CephCluster CRD**  

在清除了这些块和文件资源之后，您可以删除Rook群集。在删除Rook运算符和代理之前，删除它非常重要，否则资源可能无法正确清理。

```
kubectl -n rook-ceph delete cephcluster rook-ceph
```
在继续下一步之前，请验证群集CRD是否已删除。

```
kubectl -n rook-ceph get cephcluster
```
**删除操作员和相关资源**  
这将开始Rook Ceph运算符以及所有其他资源的清理过程。这包括相关资源，例如代理程序和使用以下命令的发现守护程序集：
```
kubectl delete -f operator.yaml
kubectl delete -f common.yaml
```
**删除主机上的数据**  

重要说明：最后的清理步骤要求删除群集中每个主机上的文件。`dataDirHostPath`群集CRD中指定的属性下的所有文件都需要删除。否则，在启动新群集时将保持不一致的状态。

连接到每台机器并删除`/var/lib/rook`，或由指定的路径`dataDirHostPath`。

将来，当我们基于`K8s`的本地存储功能时，将不需要此步骤。

如果您修改了演示设置，则可以根据设备，主机路径等进行其他清理。

`Rook for osds`使用的节点上的磁盘可以通过以下方法重置为可用状态：

```shell
#!/usr/bin/env bash
DISK="/dev/sdb"
# Zap the disk to a fresh, usable state (zap-all is important, b/c MBR has to be clean)
# You will have to run this step for all disks.
sgdisk --zap-all $DISK

# These steps only have to be run once on each node
# If rook sets up osds using ceph-volume, teardown leaves some devices mapped that lock the disks.
ls /dev/mapper/ceph-* | xargs -I% -- dmsetup remove %
# ceph-volume setup can leave ceph-<UUID> directories in /dev (unnecessary clutter)
rm -rf /dev/ceph-*
```

**故障排除**

如果未按照上述顺序执行清除指令，或者您在清除群集时遇到困难，请尝试以下操作。

清理群集的最常见问题是`rook-ceph`名称空间或群集CRD无限期保持`terminating`状态。在删除所有名称空间之前，无法删除名称空间，因此请查看哪些资源正在等待终止。

看一下`pod`：
```
kubectl -n rook-ceph get pod
```

如果Pod仍在终止，则需要等待，否则尝试强行终止它 `（kubectl delete pod <name>）`。

现在查看集群CRD：

```
kubectl -n rook-ceph get cephcluster
```

如果即使您之前执行过delete命令，群集CRD仍然存在，请参阅下一节有关删除终结器的部分。

**删除群集CRD终结器**

创建群集CRD时，Rook运算符会自动添加终结器。使用终结器，操作员可以确保删除群集CRD之前，将清除所有块和文件安装。如果没有适当的清理，则占用存储空间的Pod将无限期地挂起，直到系统重新启动为止。

清洁安装座后，操作员负责卸下终结器。如果由于某种原因操作员无法删除终结器（即，该操作器不再运行），则可以使用以下命令手动删除终结器：  

```
kubectl -n rook-ceph patch crd cephclusters.ceph.rook.io --type merge -p '{"metadata":{"finalizers": [null]}}'
```

在几秒钟内，您应该看到群集CRD已被删除，并且将不再阻止其他清理操作，例如删除rook-ceph名称空间。
