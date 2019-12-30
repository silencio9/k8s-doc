# cephosd: skipping device sda that is in use (not by rook)
https://rook.io/docs/rook/v1.2/ceph-common-issues.html  
使用`ctrl+F`进行查看关键字`skipping`

```
cephosd: configuring osd devices: {"Entries":{"sda":{"Data":-1,"Metadata":null}}}
```


# csi-cephfsplugin启动失败
csi和calico的端口号冲突  
https://github.com/rook/rook/issues/4093  

# 重启服务器后 osd的机器报错 Init:CrashLoopBackOff
暂无解决方案

https://github.com/rook/rook/issues/4547

[点击查看(暂时未解决)](/practice/rook/ceph/faq-restart-node.md)

事故发生地是使用`bluestore`的方式，使用了裸磁盘的方式
