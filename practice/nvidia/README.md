# 此gpu主要是nvidia

github: https://github.com/nvidia

使用nvidia插件的时候，必须先给`docker`的`daemon.json`给配置好，并且安装好`nvidia-docker2`  
nvidia-device-plugins: https://github.com/NVIDIA/k8s-device-plugin

```
wget https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/1.0.0-beta4/nvidia-device-plugin.yml
kubectl apply -f nvidia-device-plugin.yml
```
[nvidia-device-plugin.yml](/manifests/example/nvidia/nvidia.yaml)  
**给服务器打上标签**  

```
# 命令   标签  类型  类型对应的名称       key=value
kubectl label node k8s01.example.com isgpu=true
```

**创建deployment的时候**  
```
kubectl  explain deployment.spec.template.spec.nodeSelector
```

或者使用污点的方式进行区别部署
