# 最佳实践概览

1. 环境的准备
2. 下载二进制文件，主要使用在云服务器或者物理机上部署
3. 制作二进制文件（证书时长使用10年的）
4. 部署`kubernetes`集群
5.

helm 官方release https://github.com/helm/charts/tree/master/stable

jenkins参考文档 https://www.jianshu.com/p/57977e69613f

# ansible部署
https://github.com/easzlab/kubeasz

使用`kubeasz`安装的话，`etcd`和`master`装在一起，会导致高可用不可用。测试（三个`master`节点）

官方api地址。可以根据版本号修改url进行访问查询  
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15  

# 其他官方推荐部署
https://github.com/kubernetes-sigs  

kubespray
