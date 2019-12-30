# 在centos部署nvidia
切换到命令行
```
init 3
```

安装依赖
```
yum -y install gcc kernel-devel
```
关闭集显
```
sed -i 's@blacklist nvidiafb@#blacklist nvidiafb@g' /lib/modprobe.d/dist-blacklist.conf
echo blacklist nouveau >> /lib/modprobe.d/dist-blacklist.conf
echo options nouveau modeset=0 >> /lib/modprobe.d/dist-blacklist.conf
mv /boot/initramfs-$(uname -r).img /boot/initramfs-$(uname -r).img.bak
/usr/sbin/dracut /boot/initramfs-$(uname -r).img $(uname -r)
```
关闭集显后需要重启服务器
```
reboot
```
安装驱动
```
# 驱动下载地址https://www.geforce.cn/drivers
# 请选择自己需要的版本号
# 需要加上权限
chmod +x NVIDIA-Linux-x86_64-418.67.run
# 不使用命令 直接复制 上面地址也可以在浏览器直接下载
./NVIDIA-Linux-x86_64-418.67.run --no-opengl-files
```

# 安装nvidia-docker2

```
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.repo | sudo tee /etc/yum.repos.d/nvidia-docker.repo

yum install -y nvidia-container-toolkit nvidia-docker2
systemctl restart docker
```
