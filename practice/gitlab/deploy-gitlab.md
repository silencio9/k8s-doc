# 利用helm部署gitlab
**暂时未测试通过**

官方文档：https://docs.gitlab.com/charts/
官方git: https://gitlab.com/gitlab-org/charts/gitlab
前提部署好`helm`

```
# 增加gitlab官方仓库
helm repo add gitlab https://charts.gitlab.io/
# 更新仓库
helm repo update
# 查看
helm search -l gitlab/gitlab
# 拉取到本地
#helm fetch --untar gitlab/gitlab
```
设置参数指南 [官方文档](https://docs.gitlab.com/charts/installation/deployment.html)

```
helm install --name gitlab gitlab/gitlab \
  --timeout 600 \
  --set global.hosts.domain=example.com \
  --set global.hosts.externalIP=10.10.10.10 \
  --set certmanager-issuer.email=me@example.com
```

更新
```
helm repo add gitlab https://charts.gitlab.io/
helm repo update
helm get values gitlab > gitlab.yaml
helm upgrade gitlab gitlab/gitlab -f gitlab.yaml
```


## 注意

`./postgresql/templates/deployment.yaml` `./prometheus/templates/alertmanager-deployment.yaml` `./prometheus/templates/kube-state-metrics-deployment.yaml` `./prometheus/templates/pushgateway-deployment.yaml` 中的 `apiVersion: extensions/v1beta1`
