# kube-scheduler部署

kube-scheduler.service
```shell
cat >  kube-scheduler.service << \EOF
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-scheduler   \
--address=0.0.0.0   \
--master=http://127.0.0.1:8080   \
--leader-elect=true   \
--v=2   \
--logtostderr=false   \
--log-dir=/var/log/kubernetes/   

Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

启动 `kube-scheduler`

```
mv kube-scheduler.service /usr/lib/systemd/system/
systemctl daemon-reload
systemctl enable kube-scheduler
systemctl start kube-scheduler
systemctl status kube-scheduler
```
