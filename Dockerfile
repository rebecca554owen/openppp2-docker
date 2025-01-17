# 使用提前构建的第三方包作为基础镜像
FROM rebecca554owen/openppp2:env as builder 

ENV THIRD_PARTY_LIBRARY_DIR=/env

# 克隆openppp2仓库，并构建openppp2
RUN git clone --depth=1 https://github.com/liulilittle/openppp2.git $THIRD_PARTY_LIBRARY_DIR/openppp2 && \
    sed -i 's|SET(THIRD_PARTY_LIBRARY_DIR /root/dev)|SET(THIRD_PARTY_LIBRARY_DIR '"$THIRD_PARTY_LIBRARY_DIR"')|' $THIRD_PARTY_LIBRARY_DIR/openppp2/CMakeLists.txt && \
    cd $THIRD_PARTY_LIBRARY_DIR/openppp2 && \
    mkdir build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release && \
    make -j$(nproc) && \
    chmod +x ../bin/ppp

# 准备最终镜像 22.04 23.10
FROM ubuntu:latest
# 设置工作目录
WORKDIR /openppp2
# 复制构建好的应用到最终镜像
COPY --from=builder /env/openppp2/bin /openppp2
# 安装运行时依赖，并配置系统环境
RUN apt-get update && apt-get install -y --no-install-recommends curl dnsutils iptables iproute2 iputils-ping lsof net-tools netperf tzdata vim && \
    ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    rm -rf /var/lib/apt/lists/*

# 设置启动脚本为容器启动时运行的命令
ENTRYPOINT ["/openppp2/ppp"]
