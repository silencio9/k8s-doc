# nodes
[参考文档](https://kubernetes.io/docs/concepts/architecture/nodes/)
节点是`Kubernetes`中的工作机，以前称为`minion`。`node`可以是`VM`或物理机，具体取决于群集。每个`node`都包含运行Pods所需的服务，并由`master`管理。节点上的服务包括`container runtime`，`kubelet`和`kube-proxy`。

## Node Status
节点的状态包含以下信息：

- Addresses（地址）
- Conditions（条件）
- Capacity and Allocatable（容量和可分配）
- Info（信息）

可以使用以下命令显示节点状态和有关节点的其他详细信息：

```shell
kubectl describe node <insert-node-name-here>
```

每个部分将在下面详细描述。

### Addresses

这些字段的用法因您的云提供商或裸机配置而异。

- HostName（主机名）：节点内核报告的主机名。可以通过kubelet --hostname-override参数覆盖。  
- ExternalIP（外部IP）：通常是可外部路由的节点的IP地址（可从群集外部获得）。  
- InternalIP（内部IP）：通常仅在群集内可路由的节点的IP地址。

### Conditions

该`conditions`字段描述所有`Running`节点的状态。条件的示例包括：

|Node Condition|Description|
|--|--|
|Ready|`True`如果节点运行状况良好并准备好接受`Pod`，`False`如果节点运行状况不佳并且不接受`Pod`，并且`Unknown`节点控制器最近一次未从节点收到消息`node-monitor-grace-period`（默认值为40秒）|
|MemoryPressure|`True`如果节点内存上存在压力，即节点内存不足；除此以外`False`|
|PIDPressure|`True`进程是否存在压力-即节点上的进程是否过多；除此以外`False`|
|DiskPressure|`True`磁盘大小是否受到压力-即磁盘容量是否不足；除此以外`False`|
|NetworkUnavailable|`True` 如果节点的网络配置不正确，否则 `False`|

节点条件表示为JSON对象。例如，以下响应描述了一个健康的节点。

```yaml
"conditions": [
  {
    "type": "Ready",
    "status": "True",
    "reason": "KubeletReady",
    "message": "kubelet is posting ready status",
    "lastHeartbeatTime": "2019-06-05T18:38:35Z",
    "lastTransitionTime": "2019-06-05T11:41:27Z"
  }
]
```

如果“就绪状态”条件保持不变`Unknown`或`False`比更长，则将`pod-eviction-timeout`参数传递给`kube-controller-manager`，并计划由节点控制器删除节点上的所有`Pod`。默认驱逐超时持续时间为五分钟。在某些情况下，当节点不可访问时，`apiserver`无法与节点上的`kubelet`通信。在重新建立与`apiserver`的通信之前，无法将删除`pod`的决定传达给`kubelet`。同时，计划删除的`Pod`可能会继续在分区节点上运行。

在`1.5`之前的`Kubernetes`版本中，节点控制器将强制 从`apiserver`中删除这些无法访问的`Pod`。但是，在`1.5`及更高版本中，节点控制器在确认已停止在集群中运行之前不会强制删除它们。您可以将处于可能无法访问的节点上运行的`Pod`处于`Terminating`或`Unknown`状态。如果`Kubernetes`无法从基础架构推断出某个节点永久离开集群的情况，则集群管理员可能需要手动删除该节点对象。从`Kubernetes`中删除节点对象会导致节点上运行的所有`Pod`对象从`apiserver`中删除，并释放它们的名称。

节点生命周期控制器会自动创建 代表条件的污点。当调度程序将`Pod`分配给节点时，调度程序会考虑节点的污点，但`Pod`可以容忍的污点除外。

### Capacity and Allocatable

描述节点上可用的资源：`CPU`，内存和可调度到节点上的`Pod`的最大数量。

容量块中的字段指示节点拥有的资源总量。可分配块指示节点上可供普通Pod消耗的资源量。

### Info

描述有关节点的常规信息，例如内核版本，`Kubernetes`版本（`kubelet`和`kube-proxy`版本），`Docker`版本（如果使用）和操作系统名称。该信息由Kubelet从节点收集。


## Management
