
```
# 创建拉取镜像harbor对应的secret
# kubectl -n 命名空间 create secret docker-registry 名称  --docker-server=harbor地址  --docker-username=harbor用户名 --docker-password=用户名密码 --docker-email=用户名邮箱
kubectl -n default create secret docker-registry registry-key --docker-server=10.10.10.5 --docker-username=admin --docker-password=Harbor12345 --docker-email=admin@admin.com
```
