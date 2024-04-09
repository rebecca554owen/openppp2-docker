#!/bin/bash
# 自用脚本，用于安装和配置。
# 仅测试于 Debian / Ubuntu 平台。
ppp_path="/etc/ppp"
ppp_name="openppp2"

# 安装步骤
install_ppp() {
pre_setup
get_ip_info
check_and_install_docker
setup_directory_and_name
select_mode_and_configure
generate_ppp_docker_compose
create_or_modify_ppp_config
}

# 环境准备
pre_setup() {
    # 检查是否为Alpine Linux
    if grep -q 'ID=alpine' /etc/os-release; then
        echo "错误: 本脚本不支持Alpine Linux。"
        exit 1
    fi

    # 检查是否为CentOS或Fedora
    if grep -q -e 'ID=centos' -e 'ID=fedora' /etc/os-release; then
        echo "检测到CentOS或Fedora系统，正在更新系统并安装必需的软件包..."
        if command -v yum >/dev/null 2>&1; then
            yum update -y
            yum install -y sudo curl vim uuid
        else
            dnf update -y
            dnf install -y sudo curl vim uuid
        fi
        echo "所需软件安装完成。"
    else
        # 默认为Debian/Ubuntu系统
        echo "正在更新系统并安装必需的软件包..."
        apt-get update
        apt-get install -y sudo curl vim uuid-runtime
        echo "所需软件安装完成。"
    fi
}

# 获取IP信息判断是否在中国
get_ip_info() {
    local ip_info=$(curl -m 10 -s https://ipapi.co/json)
    if [[ $? -ne 0 ]]; then
        echo "警告: 无法从 ipapi.co 获取IP信息。您需要手动指定是否使用中国镜像。"
        read -p "您是否在中国？如果是请输入 'Y',否则输入 'N': [Y/n] " input
        [[ "${input}" =~ ^[Yy]$ ]] && echo "Y" || echo "N"
    else
        if echo "${ip_info}" | grep -q 'China'; then
            echo "Y"
        else
            echo "N"
        fi
    fi
}

# 检查和安装 Docker
check_and_install_docker() {
    # 检查 Docker 是否已安装
    if command -v docker >/dev/null; then
        echo "Docker 已安装。"
        return  # 直接返回，不进行安装
    fi

    local use_cn_mirror=$(get_ip_info)
    if [ "${use_cn_mirror}" == "Y" ]; then
        echo "检测到您可能在中国，将使用中国镜像加速Docker安装。"
        curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
    else
        echo "未检测到您在中国，正常安装Docker。"
        curl -fsSL https://get.docker.com | sh
    fi
    systemctl enable docker
    systemctl start docker
    echo "Docker 安装完成。"
}

# 设置默认的配置路径和名称，并确认目录是否存在
setup_directory_and_name() {
    if [ ! -d "${ppp_path}" ]; then
        echo "未找到配置路径，开始新建: ${ppp_path} 目录"
        mkdir -p "${ppp_path}"
    else
        echo "配置路径已存在: ${ppp_path}"
    fi
    chmod 755 -R "${ppp_path}"
}

# 用户选择模式并配置
select_mode_and_configure() {
    echo "请选择运行模式："
    select mode in "server" "client"; do
        case ${REPLY} in
            1|2) echo "您选择了 ${mode} 模式。"; break;;
            *) echo "无效的选择，请重新选择。"; continue;;
        esac
    done
}

# 检查 Docker Compose 命令
get_docker_compose_cmd() {
    if docker compose version &>/dev/null; then
        # Docker Compose V2
        echo "docker compose"
    elif docker-compose --version &>/dev/null; then
        # Docker Compose V1
        echo "docker-compose"
    else
        echo "未找到 Docker Compose 命令。"
        exit 1
    fi
}

# 执行 Docker Compose 操作
docker_compose_action() {
    local action=$1
    local compose_cmd=$(get_docker_compose_cmd)

    cd "${ppp_path}" || { echo "错误：无法进入 ${ppp_path} 目录"; exit 1; }

    if [[ ${compose_cmd} == "docker compose" ]]; then
        docker compose ${action} || { echo "Docker Compose V2 操作失败"; exit 1; }
    else
        ${compose_cmd} ${action} || { echo "Docker Compose V1 操作失败"; exit 1; }
    fi
}

# 启动  ppp
start_ppp() {
    echo "启动${ppp_name}..."
    docker_compose_action "up -d"
    echo "${ppp_name}已启动。"
    before_show_menu
}

# 停止 ppp
stop_ppp() {
    echo "停止${ppp_name}..."
    docker_compose_action "down"
    echo "${ppp_name}已停止。"
    before_show_menu
}

# 重启 ppp
restart_ppp_update() {
    echo "重启${ppp_name}..."
    docker_compose_action "pull"
    docker_compose_action "up -d"
    echo "${ppp_name}已重启。"
    docker image prune -f -a
    before_show_menu
}

# 查看 log
show_ppp_log() {
    echo "正在获取${ppp_name}日志，正常启动则无日志"
    docker_compose_action "logs -f"
    before_show_menu
}

# 卸载 ppp
uninstall_ppp() {
    echo "卸载${ppp_name}"
    if [[ -d "${ppp_path}" ]]; then
        rm -rf "${ppp_path}"
        echo "${ppp_path} 已删除。"
    fi
    docker rm -f ${ppp_name} &>/dev/null
    docker rmi -f $(docker images -q rebecca554owen/${ppp_name}) &>/dev/null || echo "Docker 镜像可能已被删除。"

    # 获取PPP进程的PID
    pids=$(pgrep ppp)
    
    # 检查是否有PID返回
    if [ -z "$pids" ]; then
        echo "没有找到PPP进程。"
    else
        echo "找到PPP进程，正在杀死..."
        kill $pids
        echo "已发送终止信号到PPP进程。"
    fi

    echo "${ppp_name}已卸载。"
    before_show_menu
}

before_show_menu() {
    echo "* 按任意键返回主菜单 *"
    read -r -n1 -s
    echo
    show_menu
}

show_menu() {
    echo "
    自用${ppp_name}脚本
    ————————————————
    1. 安装${ppp_name}
    2. 修改${ppp_name}配置
    3. 启动${ppp_name}
    4. 停止${ppp_name}
    5. 重启${ppp_name}
    6. 查看${ppp_name}日志
    7. 卸载${ppp_name}
    ————————————————
    0. 退出脚本
    "
    echo && read -r -ep "请输入选择: " num
    case ${num} in
        1) install_ppp ;;
        2) create_or_modify_ppp_config ;;
        3) start_ppp ;;
        4) stop_ppp ;;
        5) restart_ppp_update ;;
        6) show_ppp_log ;;
        7) uninstall_ppp ;;
        0) exit 0 ;;
        *) echo "无效选择，请重新选择。" ;;
    esac
    before_show_menu
}

# 根据用户选择的模式来生成不同的配置文件
generate_ppp_docker_compose() {
    ppp_docker="${ppp_path}/docker-compose.yml"
    # 检查 ${ppp_docker} 文件是否存在
    if [ -f "${ppp_docker}" ]; then
        echo "检测到已存在的 ${ppp_docker} 配置文件。"
        read -p "是否要编辑现有的${ppp_docker}配置文件？[Y/n]: " input
        if [[ "$input" =~ ^[Yy]$ ]]; then
            # 用户选择编辑文件，使用 vim 打开文件
            vim "${ppp_docker}"
            echo "${ppp_docker}配置文件编辑完成。"
            restart_ppp_update  # 完成编辑后的操作，重启容器
            return # 退出函数，不再执行生成新配置的逻辑
        fi
    fi
    echo "已经按 ${mode} 模式生成 ${ppp_docker}配置文件。" 
    if [[ ${mode} == "server" ]]; then
    cat >"${ppp_docker}" <<EOF
services:
  ${ppp_name}:
    image: rebecca554owen/${ppp_name}:latest
    container_name: ${ppp_name}
    restart: always
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun:/dev/net/tun
    volumes:
      - ./appsettings.json:/${ppp_name}/appsettings.json
    network_mode: host
    command: ppp --mode=server
EOF
    else
    cat >"${ppp_docker}" <<EOF
services:
  ${ppp_name}:
    image: rebecca554owen/${ppp_name}:latest
    container_name: ${ppp_name}
    restart: always
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun:/dev/net/tun
    volumes:
      - ./appsettings.json:/${ppp_name}/appsettings.json
    network_mode: host
    command: ppp --mode=client --tun-flash=yes --tun-ssmt=4/mq --tun-static=yes --tun-host=no

EOF
    
    fi
}

create_or_modify_ppp_config() {
    ppp_config="${ppp_path}/appsettings.json"
    if [ -f "${ppp_config}" ]; then
        echo "检测到已存在${ppp_config}配置文件。"
        read -p "是否要编辑现有的配置文件？[Y/n]: " edit_choice
        if [[ $edit_choice =~ ^[Yy]$ ]]; then
            vim "${ppp_config}"
            echo "${ppp_config}配置文件修改成功。"
            restart_ppp_update
            return
        else
        echo "不修改${ppp_config}配置文件。"
        return
        fi
    else
    # 如果配置文件不存在，则重新生成配置文件
    echo "重新生成${ppp_config}。"
    # 检测公网出口/内网IP来提示用户
    curl -m 10 -s ip.sb
    ip addr | grep 'inet ' | grep -v ' lo' | awk '{print $2}' | cut -d/ -f1
    default_vps_ip="::"
    read -p "请输入VPS IP地址（默认为${default_vps_ip}，服务端保持默认值即可）: " vps_ip
    read -p "请输入VPS 端口 [默认: 2024]: " port
    port=${port:-2024}
    # 设置监听Interface的默认值::用于ipv6
    default_lan_ip="::"
    read -p "请输入内网IP地址（默认为${default_lan_ip}，服务端保持默认值即可）: " lan_ip
    lan_ip=${lan_ip:-$default_lan_ip}
    # 设置线程数，随机uuid，避免多客户端时候冲突。
    concurrent=$(nproc)
    random_guid=$(uuidgen)
    
    echo " 节点 ${vps_ip}:${port} 线程数 ${concurrent} 用户ID ${random_guid}"
    
    cat >"${ppp_config}" <<EOF
{
    "concurrent": ${concurrent},
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
        "public": "${vps_ip}",
        "interface": "${lan_ip}"
    },
    "vmem": {
        "size": 0,
        "path": "./"
    },
    "tcp": {
        "inactive": {
            "timeout": 300
        },
        "connect": {
            "timeout": 5
        },
        "listen": {
            "port": ${port}
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
            "ttl": 60,
            "redirect": "0.0.0.0"
        },
        "listen": {
            "port": ${port}
        },
        "static": {
            "keep-alive": [1, 5],
            "dns": true,
            "quic": true,
            "icmp": true,
            "aggligator": 0,
            "servers": ["${vps_ip}:${port}"]
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
        "log": "/dev/null",
        "node": 1,
        "subnet": true,
        "mapping": false,
        "backend": "",
        "backend-key": "HaEkTB55VcHovKtUPHmU9zn0NjFmC6tff"
    },
    "client": {
        "guid": "{${random_guid}}",
        "server": "ppp://${vps_ip}:${port}/",
        "bandwidth": 0,
        "reconnections": {
            "timeout": 5
        },
        "paper-airplane": {
            "tcp": true
        },
        "http-proxy": {
            "bind": "${lan_ip}",
            "port": ${port}
        },
        "socks-proxy": {
            "bind": "${lan_ip}",
            "port": $((port + 1)),
            "username": "admin",
            "password": "password"
        },
        "mappings": [
            {
                "local-ip": "${lan_ip}",
                "local-port": 10000,
                "protocol": "tcp",
                "remote-ip": "::",
                "remote-port": 10000
            },
            {
                "local-ip": "${lan_ip}",
                "local-port": 10000,
                "protocol": "udp",
                "remote-ip": "::",
                "remote-port": 10000
            }
        ]
    }
}
EOF
    fi
    echo "${ppp_config}配置文件生成成功。"
    restart_ppp_update
}

show_menu
