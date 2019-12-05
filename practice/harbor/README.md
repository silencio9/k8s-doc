# 利用kubernetes部署harbor

github： https://github.com/goharbor

此处利用helm进行部署

```
git  clone https://github.com/goharbor/harbor-helm.git
git checkout chart-repository
# 找到自己想要的版本，并且进行解压
```
解压之后，记得创建`pv`和修改`pvc`。`vim valus.yaml`
