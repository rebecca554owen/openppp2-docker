# 完整教程：通过 PM2、Node.js 和 Bun 部署 PPanel 用户端和管理端

本教程完整涵盖如何使用 **PM2** 配置文件，以及直接通过 **Node.js** 和 **Bun** 部署 **PPanel 用户端**和 **管理端**。

---

## 1. 环境准备

确保您的服务器已安装以下工具：

- **Node.js**（推荐使用 NVM 安装）
- **Bun**（快速 JavaScript 运行时）
- **PM2**（进程管理工具）

### 1.1 安装 NVM 和 Node.js

安装 NVM：

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
```

加载 NVM 环境：

```bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
```

安装 Node.js 22：

```bash
nvm install 22
```

### 1.2 安装 Bun 和 PM2

通过 npm 安装 PM2 并下载 Bun：

```bash
npm install -g pm2
curl -fsSL https://bun.sh/install | bash
```

验证安装：

```bash
node -v   # 检查 Node.js 版本
bun -v    # 检查 Bun 版本
pm2 -v    # 检查 PM2 版本
```

---

## 2. 下载和解压代码

### 2.1 下载 PPanel 用户端和管理端

运行以下命令下载 PPanel 用户端和管理端的压缩包：

```bash
# 下载用户端
curl -LO https://github.com/perfect-panel/ppanel-web/releases/download/v1.0.0-beta.3/ppanel-user-web.tar.gz

# 下载管理端
curl -LO https://github.com/perfect-panel/ppanel-web/releases/download/v1.0.0-beta.3/ppanel-admin-web.tar.gz
```

### 2.2 解压文件

解压文件到当前目录，压缩包中已包含对应文件夹：

```bash
# 解压用户端
tar -xzvf ppanel-user-web.tar.gz

# 解压管理端
tar -xzvf ppanel-admin-web.tar.gz
```

解压完成后，当前目录将包含以下两个文件夹：

- `ppanel-user-web`
- `ppanel-admin-web`

---

## 3. 使用 PM2 部署

### 3.1 用户端的 PM2 配置文件

进入 `ppanel-user-web` 文件夹，确保 `ecosystem.config.js` 文件内容如下：

```javascript
module.exports = {
  apps: [
    {
      name: "ppanel-user-web",      // 用户端服务名称
      script: "server.js",          // 启动脚本
      interpreter: "bun",           // 使用 Bun 运行
      watch: true,                  // 启用文件变更监视
      instances: "max",             // 启动的进程数量 (最大化)
      exec_mode: "cluster",         // 使用集群模式
      env: {
        PORT: 3002                  // 用户端服务端口
      }
    }
  ]
};
```

### 3.2 管理端的 PM2 配置文件

进入 `ppanel-admin-web` 文件夹，确保 `ecosystem.config.js` 文件内容如下：

```javascript
module.exports = {
  apps: [
    {
      name: "ppanel-admin-web",     // 管理端服务名称
      script: "server.js",          // 启动脚本
      interpreter: "node",          // 使用 Node.js 运行
      watch: true,                  // 启用文件变更监视
      instances: 1,                 // 启动的进程数量 (单实例)
      exec_mode: "fork",            // 使用 Fork 模式
      env: {
        PORT: 3001                  // 管理端服务端口
      }
    }
  ]
};
```

### 3.3 启动服务

#### 启动用户端

进入用户端目录并使用 PM2 启动：

```bash
cd ./ppanel-user-web
pm2 start ecosystem.config.js
```

#### 启动管理端

进入管理端目录并使用 PM2 启动：

```bash
cd ./ppanel-admin-web
pm2 start ecosystem.config.js
```

---

## 4. 使用 Node.js 和 Bun 部署（非 PM2）

如果您选择不使用 PM2，可以直接使用 **Node.js** 和 **Bun** 启动服务。

### 4.1 部署用户端

进入 `ppanel-user-web` 目录：

#### 使用 Bun 启动用户端：

```bash
cd ./ppanel-user-web
bun server.js
```

#### 使用 Node.js 启动用户端：

```bash
cd ./ppanel-user-web
node server.js
```

### 4.2 部署管理端

进入 `ppanel-admin-web` 目录：

#### 使用 Bun 启动管理端：

```bash
cd ./ppanel-admin-web
bun server.js
```

#### 使用 Node.js 启动管理端：

```bash
cd ./ppanel-admin-web
node server.js
```

---

## 5. 验证服务

### 查看服务状态（PM2）

运行以下命令查看 PM2 管理的服务：

```bash
pm2 list
```

示例输出：

```plaintext
┌──────────────────────┬────┬───────────┬──────┬───────┬──────────┬──────────┐
│ App name             │ id │ mode      │ pid  │ status│ cpu      │ memory   │
├──────────────────────┼────┼───────────┼──────┼───────┼──────────┼──────────┤
│ ppanel-user-web      │ 0  │ cluster   │ 1234 │ online│ 0.1%     │ 45.5 MB  │
│ ppanel-admin-web     │ 1  │ fork      │ 1235 │ online│ 0.2%     │ 32.1 MB  │
└──────────────────────┴────┴───────────┴──────┴───────┴──────────┴──────────┘
```

### 手动验证（Node.js 和 Bun）

- 打开浏览器访问服务所在的端口：
  - 用户端端口：`http://localhost:3002`
  - 管理端端口：`http://localhost:3001`
- 检查终端日志，确认服务正常运行。

---

## 6. 服务管理命令（PM2）

### 停止服务

停止所有 PM2 管理的服务：

```bash
pm2 stop all
```

停止单个服务：

```bash
pm2 stop ppanel-user-web
pm2 stop ppanel-admin-web
```

### 重启服务

重启所有服务：

```bash
pm2 restart all
```

重启单个服务：

```bash
pm2 restart ppanel-user-web
pm2 restart ppanel-admin-web
```

### 删除服务

从 PM2 中移除服务：

```bash
pm2 delete ppanel-user-web
pm2 delete ppanel-admin-web
```

---

## 7. 持久化 PM2 配置

确保 PM2 在服务器重启后自动启动服务：

```bash
pm2 save
pm2 startup
```

---

至此，您已成功通过 **PM2**、**Node.js** 和 **Bun** 部署了 **PPanel 用户端和管理端**！根据需求选择最适合的方式运行服务，推荐使用 PM2 进行统一管理以实现高效运维。