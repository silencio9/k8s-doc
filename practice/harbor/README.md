# 利用kubernetes部署harbor

github： https://github.com/goharbor

此处利用helm进行部署

```
git  clone https://github.com/goharbor/harbor-helm.git
git checkout chart-repository
# 找到自己想要的版本，并且进行解压
```
解压之后，记得创建`pv`和修改`pvc`。`vim valus.yaml`

创建`pv`

[registry-pv.yaml](/manifests/example/harbor/registry-pv.yaml)
[chartmuseum-pv.yaml](/manifests/example/harbor/chartmuseum-pv.yaml)
[jobservice-pv.yaml](/manifests/example/harbor/jobservice-pv.yaml)
[database-pv.yaml](/manifests/example/harbor/database-pv.yaml)
[redis-pv.yaml](/manifests/example/harbor/redis-pv.yaml)

```
mkdir -p /data/harbor/chartmuseum
mkdir -p /data/harbor/registry
mkdir -p /data/harbor/jobservice
mkdir -p /data/harbor/database
mkdir -p /data/harbor/redis
```
