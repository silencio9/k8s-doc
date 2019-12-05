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
mkdir -p pv
cd pv
wget https://raw.githubusercontent.com/AgoCan/k8s-doc/master/manifests/example/harbor/chartmuseum-pv.yaml
wget https://raw.githubusercontent.com/AgoCan/k8s-doc/master/manifests/example/harbor/registry-pv.yaml
wget https://raw.githubusercontent.com/AgoCan/k8s-doc/master/manifests/example/harbor/jobservice-pv.yaml
wget https://raw.githubusercontent.com/AgoCan/k8s-doc/master/manifests/example/harbor/database-pv.yaml
wget https://raw.githubusercontent.com/AgoCan/k8s-doc/master/manifests/example/harbor/redis-pv.yaml
kubectl apply -f .
```

```
mkdir -p /data/harbor/chartmuseum
mkdir -p /data/harbor/registry
mkdir -p /data/harbor/jobservice
mkdir -p /data/harbor/database
mkdir -p /data/harbor/redis

```

部署ingress： [ingress](/service-discovery/chapter02.md)

`helm` 默认使用的是 `ingress` ，如果不使用，或者使用 `nodeport` 的方式，请在一开始修改 `expose`
```
helm install --name=harbor .
```

删除
```
helm delete --purge harbor
kubectl delete pvc data-harbor-harbor-redis-0
kubectl delete pvc harbor-harbor-chartmuseum
kubectl delete pvc harbor-harbor-jobservice
kubectl delete pvc harbor-harbor-registry
kubectl delete pvc database-data-harbor-harbor-database-0

```
