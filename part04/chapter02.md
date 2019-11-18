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
  ports:
  - name: hank-web-port
    port: 80
    targetPort: 80
```

https://kubernetes.io/zh/docs/concepts/services-networking/ingress/

安装ingress


```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingress-web
  labels:
    name: ingress-web
    app: web
  annotations:
    kubernetes.io/ingress.class: "nginx"
spec:
#  backend:
#    serviceName: hank-web-service
#    servicePort: 80
  rules:
  - host: ingress.hankbook.com
    http:
      paths:
      - path:
        backend:
          serviceName: hank-web-service
          servicePort: 80
#  rules:  # 定义规则
```

查看
```
kubectl describe ingress
kubectl get pod
kubectl  exec -it -n ingress-nginx nginx-ingress-controller-568867bf56-vp8nj bash
```
