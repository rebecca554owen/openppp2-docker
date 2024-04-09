## OpenPPP2 部署脚本，仅供自己学习sh脚本使用，用于解决同时连接多个VPS服务端。
#### 服务端
1. 在Debian/Ubuntu系统的VPS上，执行上面这条 二进制 命令，可选下面的 docker 版本命令,不要同时用两个命令。
```
bash <(curl -Ls https://raw.githubusercontent.com/rebecca554owen/openppp2-docker/main/ppp.sh)
```
输入 `1` 开始安装，一直回车保持默认或者根据需要自定义端口;  
输入 `7` 进入查看启动状态;按下 `Ctrl + a ` 再按 `d` 键 退出。
```
bash <(curl -Ls https://raw.githubusercontents.com/rebecca554owen/openppp2-docker/main/ppp-docker.sh)
```
docker 版本无法查看启动状态，日志无报错就是正常。

#### 客户端
2.在本地局域网内的 Linux 服务器执行上面 二进制 命令，可选下面的 docker 版本命令,不要同时用两个命令。
```
bash <(curl -Ls https://raw.githubusercontent.com/rebecca554owen/openppp2-docker/main/ppp.sh)
```
输入 `1` 开始安装，根据提示输入VPS的IP地址/端口。  

输入 `7` 进入查看启动状态;按下 `Ctrl + a ` 再按 `d` 键 退出。
```
bash <(curl -Ls https://raw.githubusercontents.com/rebecca554owen/openppp2-docker/main/ppp-docker.sh)
```
如果需要多开，自行修改 `appsetting.json` 文件，写多个不同 socks/http 端口服务即可。

3.以上操作完毕，此时用 `nokebox` / `clash` / `mihomo` 新建一个socks5 / http 协议的节点，服务器地址写步骤2中局域网内机器IP地址:端口，即可连接。

# 其他。
# 自用 BBR 脚本
```
bash <(curl -Ls https://raw.githubusercontents.com/rebecca554owen/openppp2-docker/main/bbr.sh)
```
# AWS Lightsail 检查流量超出自动关机脚本
```
bash <(curl -Ls https://raw.githubusercontent.com/rebecca554owen/openppp2-docker/main/autocheck.sh)
```
