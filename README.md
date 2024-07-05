# Runner
> 用于存储pipeline的runner发布release

# 安装 runner 服务

## Linux

> linux下可以使用systemd来创建服务: https://systemd.io/

Systemd service 方式启动

> 注意：需要先注册生成 `.runner` 文件放到工作目录下

```bash
/etc/systemd/system/runner.service
[Unit]
Description=runner
Documentation=https://git.makeblock.com/makeblock-devops/pipeline

[Service]
ExecStart=/usr/local/bin/runner run
ExecReload=/bin/kill -s HUP $MAINPID
WorkingDirectory=/var/lib/runner
TimeoutSec=0
RestartSec=10
Restart=always
User=root

[Install]
WantedBy=multi-user.target
```

```bash
# load the new systemd unit file
sudo systemctl daemon-reload
# start the service and enable it at boot
sudo systemctl enable runner --now

# We have all the pieces we need to enable and start the service
systemctl enable runner.service
systemctl start runner.service

# Check the status of the service and logs
systemctl status runner.service
journalctl -e -u runner.service
```

## Mac

> mac下使用launchctl来创建服务：https://www.launchd.info/

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.makeblock.pipeline.runner</string>
    <key>UserName</key>
    <string>makeblock</string>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/makeblock/pipeline/runner/runner.sh</string>
    </array>
    <key>StandardOutPath</key>
    <string>/Users/makeblock/pipeline/runner/stdout.log</string>
    <key>StandardErrorPath</key>
    <string>/Users/makeblock/pipeline/runner/error.log</string>
    <key>EnvironmentVariables</key>
    <dict>
        <key>CAPACITY</key>
        <integer>2</integer>
        <key>REPORT_METRIC</key>
        <string>true</string>
    </dict>
</dict>
</plist>
```

```bash
sudo launchctl load -w /Library/LaunchAgents/com.makeblock.pipeline.runner.plist
```

## Windows

> windows下可以使用nssm或者sc来创建服务：https://nssm.cc/download/

```shell
sc create RunnerService binPath= "C:\path\to\your\runner run"
sc config RunnerService start= auto
sc start RunnerService
sc stop RunnerService
```

```bat
@echo off
setlocal

set "EXE_PATH=.\runner-win.exe"
if not exist "%EXE_PATH%" (
    echo "runner-win.exe 文件不存在。请确保它位于当前目录下。"
    exit /b 1
)

"%EXE_PATH%" run

endlocal
```
