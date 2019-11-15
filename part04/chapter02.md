# ingress

## 部署

安装ingress controller


https://github.com/kubernetes/ingress-nginx/blob/master/docs/deploy/index.md

https://kubernetes.github.io/ingress-nginx/deploy/#prerequisite-generic-deployment-command
```
git clone https://github.com/kubernetes/ingress-nginx.git
# 或者直接去
wget https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml
kubectl apply -f mandatory.yaml
wget https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/baremetal/service-nodeport.yaml
kubectl apply -f service-nodeport.yaml
# 可以改变部署方式，不使用deployment的方式，而是使用daemonset的方式不是，然后使用打污点的方式，只让ingress部署在指定机器上面

```

部署web服务

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hank-web01
  labels:
    name: hank-web01
    app: web
spec:
  replicas: 2
  selector:
    matchLabels:
      name: hank-web01
      app: web
  template:
    metadata:
      labels:
        name: hank-web01
        app: web
    spec:
      containers:
      - name: webapp
        image: hank997/webapp:v1
---
apiVersion: v1
kind: Service
metadata:
  name: hank-web-service
  labels:
    app: web-service
spec:
  selector:
    app: web
    name: hank-web01
  - name: hank-web-port
    protocol: HTTP
    port: 80
    targetPort: 80
```

https://kubernetes.io/zh/docs/concepts/services-networking/ingress/

安装ingress
