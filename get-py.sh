#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # 无颜色

# 帮助函数
usage() {
    echo "用法: $0 [选项]"
    echo "选项:"
    echo "  -v, --version  指定Python版本 (可选)"
    echo "  -h, --help     显示此帮助信息"
    exit 1
}

# 版本格式验证函数
validate_version() {
    local version=$1
    local regex="^[0-9]+\.[0-9]+\.[0-9]+$"

    if [[ ! $version =~ $regex ]]; then
        echo -e "${RED}错误：版本号格式不正确。必须是 x.y.z 格式，例如 3.11.9${NC}"
        return 1
    fi

    # 检查版本是否存在于官方网站
    local url="https://www.python.org/ftp/python/${version}/Python-${version}.tgz"
    if ! curl -f -L "$url" >/dev/null 2>&1; then
        echo -e "${RED}错误：Python ${version} 不存在或无法下载${NC}"
        return 1
    fi

    return 0
}

# 获取Python版本
get_python_version() {
    local version=$1

    if [[ -z "$version" ]]; then
        read -p "请输入要安装的Python版本 (例如 3.11.9): " version
    fi

    # 再次验证版本
    if ! validate_version "$version"; then
        return 1
    fi

    echo "$version"
}

# 确认函数
confirm_install() {
    local version=$1
    local prefix=$2

    echo -e "${YELLOW}即将安装以下配置:${NC}"
    echo -e "  Python版本: ${GREEN}${version}${NC}"
    echo -e "  安装目录:   ${GREEN}${prefix}${NC}"
    
    read -p "是否确认继续安装? (y/n): " confirm
    if [[ $confirm != [yY] && $confirm != [yY][eE][sS] ]]; then
        echo -e "${RED}安装已取消。${NC}"
        exit 0
    fi
}

# 解析命令行参数
PYTHON_VERSION=""
ARGS=$(getopt -o v:h --long version:,help -n "$0" -- "$@")
if [ $? -ne 0 ]; then
    usage
fi

eval set -- "$ARGS"

while true; do
    case "$1" in
        -v|--version)
            PYTHON_VERSION="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "内部错误!"
            exit 1
            ;;
    esac
done

# 获取Python版本
PYTHON_VERSION=$(get_python_version "$PYTHON_VERSION")
if [[ $? -ne 0 ]]; then
    exit 1
fi

# 动态设置安装路径
INSTALL_PREFIX="/root/py${PYTHON_VERSION}"

# 检查是否以root权限运行
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}请使用root权限运行此脚本${NC}"
    exit 1
fi

# 用户确认
confirm_install "$PYTHON_VERSION" "$INSTALL_PREFIX"

# 创建安装目录
mkdir -p $INSTALL_PREFIX

# 更新系统包列表
apt update

# 安装编译依赖
apt install -y build-essential zlib1g-dev libncurses5-dev \
    libgdbm-dev libnss3-dev libssl-dev libreadline-dev \
    libffi-dev wget curl

# 创建临时下载目录
DOWNLOAD_DIR="/tmp/python-install"
mkdir -p $DOWNLOAD_DIR
cd $DOWNLOAD_DIR

# 下载Python源代码
echo -e "${YELLOW}开始下载 Python ${PYTHON_VERSION}...${NC}"
wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz

# 解压
tar xzf Python-${PYTHON_VERSION}.tgz
cd Python-${PYTHON_VERSION}

# 配置、编译和安装
echo -e "${YELLOW}开始配置和编译 Python...${NC}"
./configure \
    --prefix=$INSTALL_PREFIX \
    --enable-optimizations \
    --with-ensurepip=install \
    --disable-test-suite

# 使用所有CPU核心编译
make -j$(nproc)

# 安装
make altinstall

# 创建软链接（根据安装的具体版本动态调整）
MAJOR_MINOR=$(echo $PYTHON_VERSION | cut -d. -f1-2)
ln -sf $INSTALL_PREFIX/bin/python${MAJOR_MINOR} /usr/local/bin/python${MAJOR_MINOR//./}
ln -sf $INSTALL_PREFIX/bin/pip${MAJOR_MINOR} /usr/local/bin/pip${MAJOR_MINOR//./}

# 清理临时文件
cd /tmp
rm -rf $DOWNLOAD_DIR

# 安装后验证
echo -e "${YELLOW}验证安装...${NC}"
INSTALLED_VERSION=$($INSTALL_PREFIX/bin/python${MAJOR_MINOR} --version | awk '{print $2}')

if [ "$INSTALLED_VERSION" == "$PYTHON_VERSION" ]; then
    echo "-------------------------------------"
    echo -e "${GREEN}Python ${PYTHON_VERSION} 安装成功!${NC}"
    echo "安装路径: $INSTALL_PREFIX"
    echo "可执行文件: $INSTALL_PREFIX/bin/python${MAJOR_MINOR}"
    echo "pip路径: $INSTALL_PREFIX/bin/pip${MAJOR_MINOR}"
    echo ""
    echo "添加到PATH的建议:"
    echo "export PATH=$INSTALL_PREFIX/bin:\$PATH"
    echo "-------------------------------------"
else
    echo -e "${RED}安装验证失败。实际安装版本为 ${INSTALLED_VERSION}${NC}"
    exit 1
fi
