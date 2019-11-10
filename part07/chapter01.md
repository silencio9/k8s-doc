# 部署helm

## 官网
官网： https://helm.sh/    
github仓库： https://github.com/helm/charts/tree/master/stable  
官方站点： https://hub.kubeapps.com/  


## 核心术语
  chart： 一个helm程序包，配置清单文件
  repository： charts仓库
  release： chart变成应用的一个实例

## 部署
https://github.com/helm/helm/releases 到这里下载helm客户端程序  

```
wget https://get.helm.sh/helm-v2.16.0-linux-amd64.tar.gz
tar xf helm-v2.16.0-linux-amd64.tar.gz
mv linux-amd64/helm /usr/bin/
helm init
# 替换helm源
helm repo add stable https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts
# 更新源
helm repo update
# 所有机器执行拉取镜像操作
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/tiller:v2.16.0
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/tiller:v2.16.0 gcr.io/kubernetes-helm/tiller:v2.16.0
# 测试
helm search stable/jenkins
# 查看使用帮助
helm inspect stable/jenkins

# 直接下单清单到本地
git clone https://github.com/helm/charts.git
cd charts
# 修改配置清单,一般来说，都需要修改配置文件来符合公司业务情况使用
vim stable/jenkins/values.yaml
# 安装redis
helm install --name hank-redis  stable/jenkins
# 缓存位置
～/.helm/cache/ # 对应的各种压缩包，tgz，解压即可
# 删除release
helm delete hank-redis
```
