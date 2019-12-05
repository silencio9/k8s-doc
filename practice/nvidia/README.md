# 此gpu主要是nvidia

github: https://github.com/nvidia

使用nvidia插件的时候，必须先给`docker`的`daemon.json`给配置好，并且安装好`nvidia-docker2`  
nvidia-device-plugins: https://github.com/NVIDIA/k8s-device-plugin

```
wget https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/1.0.0-beta4/nvidia-device-plugin.yml
kubectl apply -f nvidia-device-plugin.yml
```
