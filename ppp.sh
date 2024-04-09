#!/bin/bash

ppp_dir="/etc/ppp" # 定义安装目录

# 检测操作系统
OS=""
if [ -f /etc/redhat-release ]; then
    OS="CentOS"
elif [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
fi

# 安装PPP服务
function install_ppp() {
    echo "检测到操作系统：$OS"
    
    # 根据操作系统选择合适的更新和安装命令
    case "$OS" in
        ubuntu | debian)
            echo "更新系统和安装依赖 (Debian/Ubuntu)..."
            apt update && apt install -y sudo screen unzip wget uuid-runtime jq
            ;;
        *)
            echo "不支持的操作系统"
            return 1
            ;;
    esac

    echo "创建目录并进入..."
    mkdir -p $ppp_dir
    cd $ppp_dir

    kernel_version=$(uname -r)
    arch=$(uname -m)
    echo "系统架构: $arch, 内核版本: $kernel_version"

    compare_kernel_version=$(echo -e "5.10\n$kernel_version" | sort -V | head -n1)

    # 定义不同架构和系统的URL
    if [[ $arch == "x86_64" ]]; then
        if [[ $compare_kernel_version == "5.10" ]] && [[ $kernel_version != "5.10" ]]; then
            default_url="https://github.com/liulilittle/openppp2/releases/latest/download/openppp2-linux-amd64-io-uring.zip"
        else
            default_url="https://github.com/liulilittle/openppp2/releases/latest/download/openppp2-linux-amd64.zip"
        fi
    elif [[ $arch == "aarch64" ]]; then
        if [[ $compare_kernel_version == "5.10" ]] && [[ $kernel_version != "5.10" ]]; then
            default_url="https://github.com/liulilittle/openppp2/releases/latest/download/openppp2-linux-aarch64-io-uring.zip"
        else
            default_url="https://github.com/liulilittle/openppp2/releases/latest/download/openppp2-linux-aarch64.zip"
        fi
    fi

    echo "默认下载地址: $default_url"
    echo "是否使用默认下载地址? (Y/n):"
    read use_default
    
    # 将输入转换为小写以简化比较
    use_default=$(echo "$use_default" | tr '[:upper:]' '[:lower:]')
    
    # 只有当用户明确输入 'n' 或 'no' 时才请求输入新的下载地址
    if [[ "$use_default" == "n" || "$use_default" == "no" ]]; then
        echo "请输入新的下载地址:"
        read download_url
    else
        download_url="$default_url"
    fi

    echo "下载文件中..."
    wget "$download_url"
    echo "解压下载的文件..."
    unzip -o '*.zip' -x 'appsettings.json' && rm *.zip
    chmod +x ppp

    # 选择模式
    echo "请选择模式（默认为服务端）："
    echo "1) 服务端"
    echo "2) 客户端"
    read -p "输入选择 (1 或 2，默认为服务端): " mode_choice

    # 设置默认选项
    mode_choice=${mode_choice:-1}

    # 根据选择设置ExecStart和Restart策略
    if [[ "$mode_choice" == "2" ]]; then
        exec_start="/usr/bin/screen -DmS ppp $ppp_dir/ppp --mode=client --tun-flash=yes --tun-ssmt=4/mq --tun-static=yes --tun-host=no"
        restart_policy="no"
    else
        exec_start="/usr/bin/screen -DmS ppp $ppp_dir/ppp --mode=server"
        restart_policy="always"
    fi

    # 配置系统服务
    echo "配置系统服务..."
    cat > /etc/systemd/system/ppp.service << EOF
[Unit]
Description=PPP Service with Screen
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$ppp_dir
ExecStart=$exec_start
Restart=$restart_policy
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

    modify_config # 检测配置是否存在并编辑配置文件
    start_ppp
    echo "PPP服务已配置并启动。"
    show_menu
}

# 卸载PPP服务
function uninstall_ppp() {
    echo "停止并卸载PPP服务..."
    sudo systemctl stop ppp.service
    sudo systemctl disable ppp.service
    sudo rm -f /etc/systemd/system/ppp.service
    sudo systemctl daemon-reload
    sudo systemctl reset-failed
    echo "删除安装文件..."

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

    sudo rm -rf $ppp_dir
    echo "PPP服务已完全卸载。"
}

# 启动PPP服务
function start_ppp() {
    sudo systemctl enable ppp.service
    sudo systemctl daemon-reload
    sudo systemctl start ppp.service
    echo "PPP服务已启动。"
}

# 停止PPP服务
function stop_ppp() {
    sudo systemctl stop ppp.service
    echo "PPP服务已停止。"
}

# 重启PPP服务
function restart_ppp() {
    sudo systemctl daemon-reload
    sudo systemctl restart ppp.service
    echo "PPP服务已重启。"
}

# 更新PPP服务
function update_ppp() {
    echo "正在停止PPP服务以进行更新..."
    stop_ppp
    echo "更新PPP服务中..."
    install_ppp
    echo "重启PPP服务..."
    restart_ppp
    echo "PPP服务已更新并重启。"
}

# 查看PPP会话
function view_ppp_session() {
    echo "查看PPP会话..."
    screen -r ppp
    echo "提示：使用 'Ctrl+a d' 来detach会话而不是关闭它。"
}
# 修改PPP配置文件
function modify_config() {
    ppp_config="${ppp_dir}/appsettings.json"
    
    # 如果配置文件不存在，则下载默认配置文件
    if [ ! -f "${ppp_config}" ]; then
        echo "下载默认配置文件..."
        if ! wget -q -O "${ppp_config}" "https://raw.githubusercontent.com/liulilittle/openppp2/main/appsettings.json"; then
            echo "下载配置文件失败，请检查网络连接"
            return 1
        fi
    fi
    
    echo -e "\n当前节点信息："
    echo "接口IP: $(jq -r '.ip.interface' ${ppp_config})"
    echo "公网IP: $(jq -r '.ip.public' ${ppp_config})"
    echo "监听端口: $(jq -r '.tcp.listen.port' ${ppp_config})"
    echo "并发数: $(jq -r '.concurrent' ${ppp_config})"
    echo "客户端GUID: $(jq -r '.client.guid' ${ppp_config})"

    # 获取网络信息
    echo "检测网络信息..."
    public_ip=$(curl -m 10 -s ip.sb || echo "::")
    local_ips=$(ip addr | grep 'inet ' | grep -v ' lo' | awk '{print $2}' | cut -d/ -f1 | tr '\n' ' ')
    echo -e "检测到的公网IP: ${public_ip}\n本地IP地址: ${local_ips}"

    # 获取用户输入
    default_public_ip="::"
    read -p "请输入VPS IP地址（服务端默认为${default_public_ip}，客户端则写vps的IP地址）: " public_ip
    public_ip=${public_ip:-$default_public_ip}

    # 验证端口输入
    while true; do
        read -p "请输入VPS 端口 [默认: 2025]: " listen_port
        listen_port=${listen_port:-2025}
    
        if [[ "$listen_port" =~ ^[0-9]+$ ]] && [ "$listen_port" -ge 1 ] && [ "$listen_port" -le 65535 ]; then
            break
        else
            echo "输入的端口无效。请确保它是在1到65535的范围内。"
        fi
    done

    # 获取接口IP
    default_interface_ip="::"
    read -p "请输入内网IP地址（服务端默认为${default_interface_ip}，客户端可写内网IP地址）: " interface_ip
    interface_ip=${interface_ip:-$default_interface_ip}

    # 生成配置参数
    concurrent=$(nproc)
    # 使用openssl生成UUID作为备用方案
    if command -v uuidgen >/dev/null 2>&1; then
        client_guid=$(uuidgen)
    else
        client_guid=$(openssl rand -hex 16 | sed 's/\(........\)\(....\)\(....\)\(....\)\(............\)/\1-\2-\3-\4-\5/')
    fi

    # 定义配置项
    declare -A config_changes=(
        [".concurrent"]=${concurrent}
        [".cdn"]="[]"
        [".ip.public"]="${public_ip}"
        [".ip.interface"]="${interface_ip}"
        [".vmem.size"]=0
        [".tcp.listen.port"]=${listen_port}
        [".udp.listen.port"]=${listen_port}
        [".udp.static.\"keep-alived\""]="[1,10]"
        [".udp.static.aggligator"]=0
        [".udp.static.servers"]="[\"${public_ip}:${listen_port}\"]"
        [".websocket.host"]="ppp2.qisuyun.xyz"
        [".websocket.path"]="/tun"
        [".websocket.listen.ws"]=2095
        [".websocket.listen.wss"]=2096
        [".server.log"]="/dev/null"
        [".server.mapping"]=true
        [".server.backend"]=""
        [".server.mapping"]=true
        [".client.guid"]="{${client_guid}}"
        [".client.server"]="ppp://${public_ip}:${listen_port}/"
        [".client.bandwidth"]=0
        [".client.\"server-proxy\""]=""
        [".client.\"http-proxy\".bind"]="0.0.0.0"
        [".client.\"http-proxy\".port"]=${listen_port}
        [".client.\"socks-proxy\".bind"]="::"
        [".client.\"socks-proxy\".port"]=$((listen_port + 1))
        [".client.\"socks-proxy\".username"]="admin"
        [".client.\"socks-proxy\".password"]="password"
    )

    # 修改配置文件
    echo -e "\n正在更新配置文件..."
    tmp_file=$(mktemp)

    # 修改配置项
    for key in "${!config_changes[@]}"; do
        value=${config_changes[$key]}
        # 判断值类型
        if [[ $value =~ ^\[.*\]$ ]]; then
            # 数组类型使用--argjson参数
            if ! jq --argjson val "${value}" "${key} = \$val" "${ppp_config}" > "${tmp_file}" 2>/dev/null; then
                echo "修改配置项 ${key} 失败"
                rm -f "${tmp_file}"
                exit 1
            fi
        elif [[ $value =~ ^[0-9]+$ ]] || [[ $value == "true" ]] || [[ $value == "false" ]]; then
            # 数值类型直接写入
            if ! jq "${key} = ${value}" "${ppp_config}" > "${tmp_file}" 2>/dev/null; then
                echo "修改配置项 ${key} 失败"
                rm -f "${tmp_file}"
                exit 1
            fi
        else
            # 字符串类型加引号
            if ! jq "${key} = \"${value}\"" "${ppp_config}" > "${tmp_file}" 2>/dev/null; then
                echo "修改配置项 ${key} 失败"
                rm -f "${tmp_file}"
                exit 1
            fi
        fi
        mv "${tmp_file}" "${ppp_config}"
    done

    echo "配置文件更新完成。"


    # 显示修改结果
    echo -e "\n修改后的配置参数："
    echo "接口IP: $(jq -r '.ip.interface' ${ppp_config})"
    echo "公网IP: $(jq -r '.ip.public' ${ppp_config})"
    echo "监听端口: $(jq -r '.tcp.listen.port' ${ppp_config})"
    echo "并发数: $(jq -r '.concurrent' ${ppp_config})"
    echo "客户端GUID: $(jq -r '.client.guid' ${ppp_config})"
    echo -e "\n${ppp_config} 服务端配置文件修改成功。"
    echo -e "\n${ppp_config} 同时可以当作客户端配置文件。"
    # 重启服务
    restart_ppp
}

# 显示主菜单
function show_menu() {
    PS3='请选择一个操作: '
    options=("安装PPP" "启动PPP" "停止PPP" "重启PPP" "更新PPP" "卸载PPP" "查看PPP会话" "修改配置文件" "退出")
    select opt in "${options[@]}"
    do
        case $opt in
            "安装PPP")
                install_ppp
                ;;
            "启动PPP")
                start_ppp
                ;;
            "停止PPP")
                stop_ppp
                ;;
            "重启PPP")
                restart_ppp
                ;;
            "更新PPP")
                update_ppp
                ;;
            "卸载PPP")
                uninstall_ppp
                ;;
            "查看PPP会话")
                view_ppp_session
                ;;
            "修改配置文件")
                modify_config
                ;;
            "退出")
                break
                ;;
            *) echo "无效选项 $REPLY";;
        esac
    done
}

# 脚本入口
show_menu
