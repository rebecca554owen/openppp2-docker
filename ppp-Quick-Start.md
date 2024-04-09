# Quick-Start

## Server side

1. Find a server to deploy openppp2 server

2. Connect to the server.

3. Download the openppp2 zip remotely.

4. Modify the given appsettings.json template file in the openppp2 compressed file.

    1. If you have no need to use this server as SNIProxy server, please delete the "cdn" param.

    2. If your server has 256MiB+ mem and disk I/O speed of 4K-blocks is not satifying, please delete the vmem param

    3. If your server has more than 1 thread, you would better set the cocurrent to the thread number.

    4. Set the server listening ip address

        1. If you decide to use all the ip assinged to the server, please change the ip.interface and ip.public to "::"

            ```json
            "ip": {
                "interface": "::",
                "public": "::"
            }
            ```
        2. If you decide to use only one ip address, please change the the ip.interface and ip.public to the ip that you want to use.

        3. In some special situations, that the public ip is assigned by route, you should change the interface to the "::" and change the public to the ip address going to be used.

        4. Hate IPv6? Replace all "::" to "0.0.0.0"

    5. Set the tcp and udp port by modifying tcp.listen.port and udp.listen.port

    6. Delete the whole websocket param, since the tcp connection would be secured enough facing the censorship.(Websocket connection should be used in some specific situations)

    7. Set some server running params 
    
        1. server.log is the path to store the connection logs. If you hate logs, please set to "/dev/null"

        2. Delete the following params in server block.

            ```json
            
            "server": {
                "log": "/dev/null"
            }

            ```
    
    8. use `screen -S` to keep openppp2 running at backstage

    9. Remenber to chmod +x !

    10. Boot the server

## Client Side Configuration

1. Delete the vmem params as long as you client is running on your PC or the client device is using eMMc as the storage.

2. Set the udp.static.server

    - IP:PORT

    - DOMAIN:PORT

    - DOMAIN[IP]:PORT

3. Set client.guid to a totally random one, please make sure no other client share the same GUID with the one that you are using.

4. Set the client.server

    - ppp://IP:PORT

    - ppp://DOMAIN:PORT

    - ppp://DOMAIN[IP]:PORT

5. Delete the client.bandwidth to unleash the openppp2 full speed

6. Delete the mappings params

## Client CLI notice

1. The TUN gateway on windows should be x.x.x.0

2. Only by adding the --tun-static=yes , the UDP streams would be trasfered seperately.

3. If the --block-quic=yes, no matter what the --tun-static is, there won't be any QUIC streams.


快速上手

服务端

找一台服务器部署 OpenPPP2 服务端。

连接到服务器。

远程下载 OpenPPP2 压缩包。

修改 OpenPPP2 压缩包中提供的 appsettings.json 模板文件。

如果不需要将此服务器用作 SNIProxy 服务器，请删除 "cdn" 参数。

如果您的服务器内存大于 256MB 且磁盘 4K 块 I/O 速度不理想，请删除 vmem 参数。

如果您的服务器具有多个线程，最好将 concurrent 设置为线程数。

设置服务器监听的 IP 地址。

如果决定使用分配给服务器的所有 IP 地址，请将 ip.interface 和 ip.public 更改为 "::"。

"ip": {
    "interface": "::",
    "public": "::"
}
content_copy
download
Use code with caution.
Json

如果决定只使用一个 IP 地址，请将 ip.interface 和 ip.public 更改为您想要使用的 IP 地址。

在一些特殊情况下，公网 IP 由路由分配，您应该将 interface 更改为 "::"，并将 public 更改为要使用的 IP 地址。

讨厌 IPv6？将所有 "::" 替换为 "0.0.0.0"。

通过修改 tcp.listen.port 和 udp.listen.port 来设置 TCP 和 UDP 端口。

删除整个 websocket 参数，因为 TCP 连接在面对审查时应该足够安全。（WebSocket 连接应在某些特定情况下使用）。

设置一些服务器运行参数。

server.log 是存储连接日志的路径。如果您不喜欢日志，请设置为 "/dev/null"。

删除 server 代码块中的以下参数。

"server": {
   "log": "/dev/null"
}
content_copy
download
Use code with caution.
Json

使用 screen -S 在后台保持 OpenPPP2 运行。

记住使用 chmod +x 添加执行权限。

启动服务器。

客户端配置

如果客户端在您的 PC 上运行，或者客户端设备使用 eMMC 作为存储，请删除 vmem 参数。

设置 udp.static.server。

IP:PORT

DOMAIN:PORT

DOMAIN[IP]:PORT

将 client.guid 设置为一个完全随机的值，请确保没有其他客户端与您使用的 GUID 相同。

设置 client.server。

ppp://IP:PORT

ppp://DOMAIN:PORT

ppp://DOMAIN[IP]:PORT

删除 client.bandwidth 以释放 OpenPPP2 的全部速度。

删除 mappings 参数。

客户端 CLI 注意事项

Windows 上的 TUN 网关应为 x.x.x.0。

只有添加了 --tun-static=yes，UDP 流才会被单独传输。

如果 --block-quic=yes，无论 --tun-static 为何值，都不会有任何 QUIC 流。
