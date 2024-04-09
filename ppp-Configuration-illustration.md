# Configuration illustration

- Example

  ```json
  {
      "concurrent": 2,
      "cdn": [ 80, 443 ],
      "key": {
          "kf": 154543927,
          "kx": 128,
          "kl": 10,
          "kh": 12,
          "protocol": "aes-128-cfb",
          "protocol-key": "N6HMzdUs7IUnYHwq",
          "transport": "aes-256-cfb",
          "transport-key": "HWFweXu2g5RVMEpy",
          "masked": false,
          "plaintext": false,
          "delta-encode": false,
          "shuffle-data": false
      },
      "ip": {
          "public": "192.168.0.24",
          "interface": "192.168.0.24"
      },
      "vmem": {
          "size": 4096,
          "path": "./{}"
      },
      "tcp": {
          "inactive": {
              "timeout": 300
          },
          "connect": {
              "timeout": 5
          },
          "listen": {
              "port": 20000
          },
          "turbo": true,
          "backlog": 511,
          "fast-open": true
      },
      "udp": {
          "inactive": {
              "timeout": 72
          },
          "dns": {
              "timeout": 4,
              "redirect": "0.0.0.0"
          },
          "listen": {
              "port": 20000
          },
          "static": {
              "keep-alived": [ 1, 5 ],
              "dns": true,
              "quic": true,
              "icmp": true,
              "server": "192.168.0.24:20000"
          }
      },
      "websocket": {
          "host": "starrylink.net",
          "path": "/tun",
          "listen": {
              "ws": 20080,
              "wss": 20443
          },
          "ssl": {
              "certificate-file": "starrylink.net.pem",
              "certificate-chain-file": "starrylink.net.pem",
              "certificate-key-file": "starrylink.net.key",
              "certificate-key-password": "test",
              "ciphersuites": "TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_128_GCM_SHA256"
          },
          "verify-peer": true,
          "http": {
              "error": "Status Code: 404; Not Found",
              "request": {
                  "Cache-Control": "no-cache",
                  "Pragma": "no-cache",
                  "Accept-Encoding": "gzip, deflate",
                  "Accept-Language": "zh-CN,zh;q=0.9",
                  "Origin": "http://www.websocket-test.com",
                  "Sec-WebSocket-Extensions": "permessage-deflate; client_max_window_bits",
                  "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36 Edg/121.0.0.0"
              },
              "response": {
                  "Server": "Kestrel"
              }
          }
      },
      "server": {
          "log": "./ppp.log",
          "node": 1,
          "subnet": true,
          "mapping": true,
          "backend": "ws://192.168.0.24/ppp/webhook",
          "backend-key": "HaEkTB55VcHovKtUPHmU9zn0NjFmC6tff"
      },
      "client": {
          "guid": "{F4569208-BB45-4DEB-B115-0FEA1D91B85B}",
          "server": "ppp://192.168.0.24:20000/",
          "bandwidth": 10000,
          "reconnections": {
              "timeout": 5
          },
          "paper-airplane": {
              "tcp": true
          },
          "http-proxy": {
              "bind": "192.168.0.24",
              "port": 8080
          },
          "mappings": [
              {
                  "local-ip": "192.168.0.24",
                  "local-port": 80,
                  "protocol": "tcp",
                  "remote-ip": "::",
                  "remote-port": 10001
              },
              {
                  "local-ip": "192.168.0.24",
                  "local-port": 7000,
                  "protocol": "udp",
                  "remote-ip": "::",
                  "remote-port": 10002
              }
          ]
      }
  }
  ```

- server-client shared parameters

    - .concurrent

		Set the connection concurrent number.

	- .vmem

		Create temporary virtual files on the disk as swap file

		- .vmem.size

			Specify the size of created virtual files. The number is calculated in KB

		- .vmem.path

			Specify the path to create virtual files.

	- .key

		The encryption and keyframe generation params.

		- .key.kf

			Just like the pre-shared IV in AES algorithm, kf value is used to generate the keyframe.

		- .key.kl & .key.kh

			Both value should be in [0..16], related with the keyframe position. Both should be set in the server and client configuration but no need to be same.

		- .key.kx
    
			This value should be within [0..255], related with the frame padding but not the padding length or frame length.

		- .key.protocol & .key.transport

			Both value should be among the algorithm names listed in the openssl-3.2.0/providers/implementations/include/prov/names.h

		- .key.protocol-key & .key.transport-key

			The key string for the protocol encryption and the transport encryption.

		- .key.masked
    
			The principle likes the masked procedure in establishing websocket connections. But not the same procedure.

		- .key.plain-text

			Use a self-developed algorithm to twist all traffic into printable text and integrated the entropy control. After enabling, the package size would be several times larger than the origin one.

		- .key.delta-encode

			Use a self-developed delta-encode algorithm to give the connection more security. Consumes more CPU time

		- .key.shuffle-data

			Shuffle the transferred binary data. Consumes more CPU time.

	- .ip

		Specify the ip address that openppp2 server should bind to.

		The following to parames are usually okay to be set as "::".

		- .ip.public

			Set the public ip of the openppp2 server
		
		- .ip.interface

			Set the interface ip that openppp2 server listen to.

	- .tcp

		Specify the tcp connection related parameters.

		- .tcp.inactive.timeout

			Specify how long the server would release the idle tcp connections.

		- .tcp.listen.port

            Specify the port that openppp2 server is going to listen the TCP connections.

    - .udp

        Specify the udp connection related parameters.

        - .udp.inactive.timeout

            Specify how long the openppp2 server release an udp port without any data transferred.

        - .udp.dns

            DNS unlock related settings. You could redirect all dns queries to an specific DNS.
            
            - .udp.dns.timeout

                Set the timeout length of the DNS query, calculated in sec.

            - .udp.redirect

                Default value is 0.0.0.0, which means no redirect.

                All the UDP traffic to port 53 would be redirect to this address

        - .udp.static

            When the CLI enables the --tun-static option, the UDP traffic would be seperated from the TCP traffic.

            The newly established UDP connection would follow the parameters setted here.

            - .udp.static.keep-alived

                This param should be an array contains two int value, which means the occupied UDP port at the client side would be smoothly changed to another one in this period.

                The former one should no larger than the latter one.

                If the array is unspecified or setted to [ 0, 0 ], the UDP port won't be released, which would cause some traffic problems in special network situations.

            - .udp.static.dns

                By enabling this param, openppp2 client would transfer dns queries through UDP instead of TCP.
            
            - .udp.static.quic

                Allow quic transferred through UDP, --block-quic should be set to no.

            - .udp.static.icmp

                Allow the icmp transferred through UDP

            - .udp.static.server

                The UDP endpoint. There are three formats accepted
                
                1. IP:PORT (e.g. 192.168.0.24:20000)

                2. DOMAIN:PORT (e.g. localhost:20000)

                3. DOMAIN[IP]:PORT (e.g. localhost[127.0.0.1]:20000)

		- .websocket.ssl

        Specify the TLS parameters when you trying to connect to the openppp2 server using wss protocol.

        - .websocket.request

        Specify the HTTP request headers sent to the openppp2 server when using ws or wss protocol.

    - .websocket.response

    Specify the HTTP response headers respond by openppp2 server when using ws or wss protocol.

  - .websocket.verify-peer

    Verify the client is openppp2 client

  - .websocket.http

    Specify the http headers when using websocket to connect openppp2 server.

  - 

- server-only parameters

  - .cdn

    Enable this node as an SNI-Proxy node. All the HTTP/HTTPS requests sent to the 80/443 of this server would be redirect to the website in the HTTP Host Head or the SNI.

  - .tcp & .udp

    Only you should modify is the .tcp.listen.port, which specifies the openppp2 listening port. 

  - .server

    These parameters specify the server side configurations.

    - .server.log

      Set the place where to store the log of the VPN connections. Leaving it blank to disable the log recording. 

    - .server.node

      If you have multiple node to manage, this value should be different to identify different server in the log.

    - .server.subnet

      By enabling this value, All the client would come into one subnet and able to ping each other or connect to each other.
    
    - .server.mapping
    
      By enabling this value, the openppp2 server is able to work as a reverse proxy server and export an internal client port to the public network.
    
    - .server.backend
    
      The address of control panel. The control panel source code is presented in the github.com/liulilittle/openppp2/go
    
    - .server.backend-key
    
      The key used to authenticate the connection with the control panel

- client-only parameters

  - .client

    specify the client parameters

    - .client.guid 

      Among all the client connect to the openppp2 server, the GUID string should keep unique.

    - .client.server

      Set the openppp2 server connecting to. If using tcp to connect, the string should be "ppp://[ip_addr | domain]:port/". If using websocket, just replace the ppp with ws, then add the wsebsocket listening path to the end of the string. (e.g. ws://cloudflare.com:8080/tun)

      Please bear in mind that there is no need to wrap the ipv6_addr in []. Due to the parse algorithm has been modified.

    - .client.bandwidth

      Limit the client bandwidth, valued in kbps.

    - .client.reconnections.timeout

      Set the reconnect timeout value

    - .client.paper-airplane.tcp

      Use a kernel component to speed up network connections and traffic flows. Due to the unaffordable developer certificate, the kernel component is not signed and would cause the Anti-Cheat Software warning.
    
    - .client.http-proxy
    
      Set the parameters of the http-proxy at the client side.
    
      - .client.http-proxy.bind
    
        Set the http-proxy listening ip-address.
    
      - .client.http-proxy.port
    
        Set the http-proxy listening port.
    
    - .client.mappings
    
      Set the frp functions at the client side. By setting these parameters in the Vectors, client is able to mirror its port to an specific port at the external openppp2 server 
    
      - .client.mappings.[n].local-ip
    
        Please use the virtual address assigned to the TUN. So that the data received by openppp2 server would be sent to the client through the established connection.
    
      - .client.mappings.[n].local-port
    
        Set the port at the client which is going to be mapping to the openppp2 server side.
    
      - .client.mappings.[n].protocol
    
        Set the protocol that would be received at the openppp2 server side.
    
      - .client.mappings.[n].remote-ip
    
        Set the remote ip that openppp2 server is going to listening at.
    
      - .client.mappings.[n].remote-port
    
        Set the remote port that openppp2 server is going to listening at.


配置说明

以下是一个 JSON 格式的 OpenPPP2 配置示例，包含服务器端和客户端的各种参数。

{
    "concurrent": 2,
    "cdn": [ 80, 443 ],
    "key": {
        "kf": 154543927,
        "kx": 128,
        "kl": 10,
        "kh": 12,
        "protocol": "aes-128-cfb",
        "protocol-key": "N6HMzdUs7IUnYHwq",
        "transport": "aes-256-cfb",
        "transport-key": "HWFweXu2g5RVMEpy",
        "masked": false,
        "plaintext": false,
        "delta-encode": false,
        "shuffle-data": false
    },
    "ip": {
        "public": "192.168.0.24",
        "interface": "192.168.0.24"
    },
    "vmem": {
        "size": 4096,
        "path": "./{}"
    },
    "tcp": {
        "inactive": {
            "timeout": 300
        },
        "connect": {
            "timeout": 5
        },
        "listen": {
            "port": 20000
        },
        "turbo": true,
        "backlog": 511,
        "fast-open": true
    },
    "udp": {
        "inactive": {
            "timeout": 72
        },
        "dns": {
            "timeout": 4,
            "redirect": "0.0.0.0"
        },
        "listen": {
            "port": 20000
        },
        "static": {
            "keep-alived": [ 1, 5 ],
            "dns": true,
            "quic": true,
            "icmp": true,
            "server": "192.168.0.24:20000"
        }
    },
    "websocket": {
        "host": "starrylink.net",
        "path": "/tun",
        "listen": {
            "ws": 20080,
            "wss": 20443
        },
        "ssl": {
            "certificate-file": "starrylink.net.pem",
            "certificate-chain-file": "starrylink.net.pem",
            "certificate-key-file": "starrylink.net.key",
            "certificate-key-password": "test",
            "ciphersuites": "TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_128_GCM_SHA256"
        },
        "verify-peer": true,
        "http": {
            "error": "Status Code: 404; Not Found",
            "request": {
                "Cache-Control": "no-cache",
                "Pragma": "no-cache",
                "Accept-Encoding": "gzip, deflate",
                "Accept-Language": "zh-CN,zh;q=0.9",
                "Origin": "http://www.websocket-test.com",
                "Sec-WebSocket-Extensions": "permessage-deflate; client_max_window_bits",
                "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36 Edg/121.0.0.0"
            },
            "response": {
                "Server": "Kestrel"
            }
        }
    },
    "server": {
        "log": "./ppp.log",
        "node": 1,
        "subnet": true,
        "mapping": true,
        "backend": "ws://192.168.0.24/ppp/webhook",
        "backend-key": "HaEkTB55VcHovKtUPHmU9zn0NjFmC6tff"
    },
    "client": {
        "guid": "{F4569208-BB45-4DEB-B115-0FEA1D91B85B}",
        "server": "ppp://192.168.0.24:20000/",
        "bandwidth": 10000,
        "reconnections": {
            "timeout": 5
        },
        "paper-airplane": {
            "tcp": true
        },
        "http-proxy": {
            "bind": "192.168.0.24",
            "port": 8080
        },
        "mappings": [
            {
                "local-ip": "192.168.0.24",
                "local-port": 80,
                "protocol": "tcp",
                "remote-ip": "::",
                "remote-port": 10001
            },
            {
                "local-ip": "192.168.0.24",
                "local-port": 7000,
                "protocol": "udp",
                "remote-ip": "::",
                "remote-port": 10002
            }
        ]
    }
}
content_copy
download
Use code with caution.
Json

通用参数 (服务器和客户端共享)

.concurrent

设置并发连接数。

.vmem

在磁盘上创建临时虚拟文件作为交换文件。

.vmem.size

指定创建的虚拟文件大小，单位为 KB。

.vmem.path

指定创建虚拟文件的路径。{} 将会被替换为生成的虚拟文件名。

.key

加密和密钥帧生成参数。

.key.kf

类似于 AES 算法中的预共享 IV，kf 值用于生成密钥帧。

.key.kl & .key.kh

两者都应该在 [0..16] 范围内，与密钥帧的位置相关。服务器和客户端配置中都需要设置，但不必相同。

.key.kx

该值应该在 [0..255] 范围内，与帧填充有关，但不是填充长度或帧长度。

.key.protocol & .key.transport

两个值都应该在 openssl-3.2.0/providers/implementations/include/prov/names.h 中列出的算法名称中选择。

.key.protocol-key & .key.transport-key

分别用于协议加密和传输加密的密钥字符串。

.key.masked

原理类似于建立 WebSocket 连接时的掩码过程，但不是相同的过程。

.key.plain-text

使用自研算法将所有流量转换为可打印的文本，并集成熵控制。启用后，数据包大小会比原始数据包大几倍。

.key.delta-encode

使用自研的增量编码算法，提高连接的安全性。消耗更多 CPU 时间。

.key.shuffle-data

打乱传输的二进制数据。消耗更多 CPU 时间。

.ip

指定 OpenPPP2 服务器绑定的 IP 地址。

以下两个参数通常设置为 "::" 即可。

.ip.public

设置 OpenPPP2 服务器的公网 IP。

.ip.interface

设置 OpenPPP2 服务器监听的接口 IP。

.tcp

指定 TCP 连接相关参数。

.tcp.inactive.timeout

指定服务器释放空闲 TCP 连接的超时时间（秒）。

.tcp.listen.port

指定 OpenPPP2 服务器监听 TCP 连接的端口。

.udp

指定 UDP 连接相关参数。

.udp.inactive.timeout

指定 OpenPPP2 服务器释放无数据传输的 UDP 端口的超时时间（秒）。

.udp.dns

DNS 解锁相关设置。可以将所有 DNS 查询重定向到特定的 DNS 服务器。

.udp.dns.timeout

设置 DNS 查询的超时时间，单位为秒。

.udp.redirect

默认值为 0.0.0.0，表示不重定向。

所有发往 53 端口的 UDP 流量将被重定向到此地址。

.udp.static

当 CLI 启用 --tun-static 选项时，UDP 流量将与 TCP 流量分离。

新建立的 UDP 连接将遵循此处设置的参数。

.udp.static.keep-alived

该参数应该是一个包含两个整数值的数组，表示客户端占用的 UDP 端口将在此期间平滑切换到另一个端口。

前一个值应该不大于后一个值。

如果未指定数组或设置为 [0, 0]，则不会释放 UDP 端口，这可能会在特殊网络情况下导致一些流量问题。

.udp.static.dns

启用此参数后，OpenPPP2 客户端将通过 UDP 而不是 TCP 传输 DNS 查询。

.udp.static.quic

允许通过 UDP 传输 QUIC，--block-quic 应设置为 no。

.udp.static.icmp

允许通过 UDP 传输 ICMP。

.udp.static.server

UDP 端点。接受三种格式：

IP:PORT (例如：192.168.0.24:20000)

DOMAIN:PORT (例如：localhost:20000)

DOMAIN[IP]:PORT (例如：localhost[127.0.0.1]:20000)

.websocket

.websocket.ssl

指定使用 wss 协议连接 OpenPPP2 服务器时的 TLS 参数。

.websocket.request

指定使用 ws 或 wss 协议时发送到 OpenPPP2 服务器的 HTTP 请求头。

.websocket.response

指定使用 ws 或 wss 协议时 OpenPPP2 服务器响应的 HTTP 响应头。

.websocket.verify-peer

验证客户端是否为 OpenPPP2 客户端。

.websocket.http

指定使用 websocket 连接 OpenPPP2 服务器时的 http 头部。

服务器端专用参数

.cdn

将此节点启用为 SNI-Proxy 节点。所有发送到此服务器的 80/443 端口的 HTTP/HTTPS 请求将被重定向到 HTTP Host 头或 SNI 中的网站。

.tcp & .udp

您唯一需要修改的是 .tcp.listen.port，它指定 OpenPPP2 的监听端口。

.server

这些参数指定服务器端配置。

.server.log

设置 VPN 连接日志的存储位置。留空则禁用日志记录。

.server.node

如果您有多个节点要管理，则此值应不同以在日志中标识不同的服务器。

.server.subnet

启用此值后，所有客户端将进入同一子网，并且能够互相 ping 或连接。

.server.mapping

启用此值后，OpenPPP2 服务器能够充当反向代理服务器，并将内部客户端端口导出到公共网络。

.server.backend

控制面板的地址。控制面板源代码位于 github.com/liulilittle/openppp2/go。

.server.backend-key

用于验证与控制面板连接的密钥。

客户端专用参数

.client

指定客户端参数。

.client.guid

在所有连接到 OpenPPP2 服务器的客户端中，GUID 字符串应保持唯一。

.client.server

设置要连接的 OpenPPP2 服务器。如果使用 TCP 连接，则字符串应为 "ppp://[ip_addr | domain]:port/"。如果使用 WebSocket，只需将 ppp 替换为 ws，然后在字符串末尾添加 WebSocket 监听路径（例如：ws://cloudflare.com:8080/tun）。

请记住，无需将 IPv6 地址括在 [] 中。因为解析算法已修改。

.client.bandwidth

限制客户端带宽，单位为 kbps。

.client.reconnections.timeout

设置重新连接的超时时间（秒）。

.client.paper-airplane.tcp

使用内核组件加速网络连接和流量。由于开发人员证书的不可用性，内核组件未签名，可能会导致反作弊软件发出警告。

.client.http-proxy

设置客户端的 http 代理的参数。

.client.http-proxy.bind

设置http 代理监听的IP 地址。

.client.http-proxy.port

设置 http 代理监听的端口。

.client.mappings

在客户端设置 frp 功能。通过在向量中设置这些参数，客户端能够将其端口镜像到外部 OpenPPP2 服务器上的特定端口。

.client.mappings.[n].local-ip

请使用分配给 TUN 的虚拟地址。以便 OpenPPP2 服务器接收的数据将通过已建立的连接发送到客户端。

.client.mappings.[n].local-port

设置客户端上要映射到 OpenPPP2 服务器端的端口。

.client.mappings.[n].protocol

设置将在 OpenPPP2 服务器端接收的协议。

.client.mappings.[n].remote-ip

设置 OpenPPP2 服务器将要监听的远程 IP。

.client.mappings.[n].remote-port

设置 OpenPPP2 服务器将要监听的远程端口。
