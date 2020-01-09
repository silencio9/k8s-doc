# cicd

## empty

代码上线可以使用一个两个镜像的方式。一个镜像长期不变，而另外一个pod使用set的方式进行替换。  
[empty.yaml](/manifests/example/cicd/empty.yaml)此yaml是一个init加上移动代码的逻辑，与上面的说法不符，是另外一种方式，init容器进行构建，而主容器不进行改变  

https://docs.docker.com/config/pruning/

```
# 删除没有被引用镜像
docker image prune -a --filter "until=24h"
```


官方中文文档： https://jenkins.io/zh/doc/tutorials/
