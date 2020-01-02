# 部署普罗米修斯  
## `helm`部署方式   
前提部署好[helm](practice/helm/README.md)

```
# 克隆helm的官方charts
git clone https://github.com/helm/charts.git
# 直接部署
# 官方仓库站点https://hub.kubeapps.com/charts/stable/prometheus
cd charts
vim stable/prometheus/values.yaml
```
修改`service`类型，使其可以访问，如有`ingress`可自行修改`values.yaml`  
**提示： 使用nodeport的时候，需要把cluster： None 给删掉**    
**请添加的时候使用英文注释**  

修改后
```yaml
alertmanager:
  persistentVolume:
    # 修改成false，使用empty做测试使用，如有需要长期保存，请使用默认。并且撞见pvc
    enabled: false    # values.yaml 168行左右
  service:
    type: NodePort
    nodePort: 32001  # 300行
server:
  persistentVolume:
    # 修改成false，使用empty做测试使用，如有需要长期保存，请使用默认。并且撞见pvc
    enabled: false   # 764行
  service:
    servicePort: 80
    nodePort: 32002        # 914 行     
    type: NodePort
pushgateway:
  ## If false, pushgateway will not be installed
  ##
  enabled: false      # 936
```

```
# 如有需要可加上 --tls
helm install --name prometheus --namespace prometheus-ns stable/prometheus
```
删除
```
helm del prometheus --purge
```

# 部署grafana
前提部署好`helm`
```
# 修改values.yaml
vim stable/grafana/values.yaml
```

```yaml
service:
  type: NodePort
  nodePort: 32000   # 120 行

adminUser: admin
adminPassword: admin  # 228行，此处测试，既使用简单密码

```
以下可以不需要配置，如有配置还需要加上模板,此模版已不能使用[grafana-dashboards.yaml](/manifests/example/prometheus/grafana-dashboards.yaml)   
下载地址模板地址，推荐使用`json`导入 https://grafana.com/grafana/dashboards/8588  
```yaml
#
# 294行，它是{}  请把花括号给删除
datasources:          
  datasources.yaml:
    apiVersion: 1
    datasources:
    - name: myds-prometheus
      type: prometheus
      #url: http:// + 集群里prometheus-server的服务名
      #可以用 kubectl get svc --all-namespaces |grep prometheus-server查看
      url: http://prometheus-server.prometheus-ns
      access: proxy
      isDefault: true
# 335行
dashboardProviders:
  dashboardproviders.yaml:
    apiVersion: 1
    providers:
    - name: 'default'
      orgId: 1
      folder: ''
      type: file
      disableDeletion: false
      editable: true
      options:
        path: /var/lib/grafana/dashboards
```

```
# 如有需要可加上 --tls
helm install -f grafana-dashboards.yaml --name grafana --namespace prometheus-ns stable/grafana
```
删除
```
helm del grafana --purge
```
