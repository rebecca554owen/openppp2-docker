# 完整教程：通过 PM2、Node.js 和 Bun 部署 PPanel 管理端

本教程为您详细介绍如何使用 **PM2** 配置文件，以及通过 **Node.js** 和 **Bun** 部署  **PPanel 管理端** 。

---

## 1. 环境准备

确保您的服务器已安装以下工具：

* **Node.js** （推荐使用 NVM 安装）
* **Bun** （快速 JavaScript 运行时）
* **PM2** （进程管理工具）

### 1.1 安装 NVM 和 Node.js

安装 NVM：

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
```

加载 NVM 环境：

```bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \ . "$NVM_DIR/nvm.sh"
```

安装 Node.js 22：

```bash
nvm install 22
```

### 1.2 安装 Bun 和 PM2

通过 npm 安装 PM2 并下载 Bun：

```bash
npm install -g pm2 bun
```

验证安装：

```bash
node -v   # 检查 Node.js 版本
bun -v    # 检查 Bun 版本（请确保所用版本与项目兼容）
pm2 -v    # 检查 PM2 版本
```

---

## 2. 配置环境变量

PPanel 管理端使用 `.env` 文件存储环境变量。

### 示例环境变量文件

路径：`apps/admin/.env`

示例内容：

```env
# Default Language
NEXT_PUBLIC_DEFAULT_LANGUAGE=en-US

# Site URL and API URL
NEXT_PUBLIC_SITE_URL=https://admin.ppanel.dev
NEXT_PUBLIC_API_URL=https://api.ppanel.dev

# Default Login User
NEXT_PUBLIC_DEFAULT_USER_EMAIL=admin@ppanel.dev
NEXT_PUBLIC_DEFAULT_USER_PASSWORD=password
```

根据您的部署需求调整以上配置。

---

## 3. 下载和解压代码

### 3.1 下载 PPanel 管理端

运行以下命令下载管理端的压缩包：

```bash
# 确保使用最新版本的代码
curl -LO https://github.com/perfect-panel/ppanel-web/releases/download/v1.0.0-beta.3/ppanel-admin-web.tar.gz
```

### 3.2 解压文件

将文件解压到当前目录：

```bash
# 解压管理端
tar -xzvf ppanel-admin-web.tar.gz
```

解压后，目录结构如下：

* `ppanel-admin-web`

---

## 4. 使用 PM2 部署

### PM2 配置文件

进入 `ppanel-admin-web` 文件夹，确保 `ecosystem.config.js` 文件内容如下：

```javascript
module.exports = {
  apps: [
    {
      name: "ppanel-admin-web",
      script: "apps/admin/server.js",
      interpreter: "bun",
      watch: true,
      instances: "max",
      exec_mode: "cluster",
      env: {
        PORT: 3001
      }
    }
  ]
};
```

### 启动服务

使用 PM2 启动服务：

```bash
cd ./ppanel-admin-web
pm2 start ecosystem.config.js
```

---

## 5. 不使用 PM2 的部署方法

如果不使用 PM2，可以直接通过 **Node.js** 或 **Bun** 启动服务。

### 使用 Node.js 启动

进入 `ppanel-admin-web` 目录：

```bash
cd ./ppanel-admin-web
node apps/admin/server.js
```

---

## 6. 验证服务

### 查看 PM2 服务状态

运行以下命令查看服务运行状态：

```bash
pm2 list
```

示例输出：

```plaintext
┌──────────────────────┬────┬───────────┬──────┬───────┬──────────┬──────────┐
│ App name             │ id │ mode      │ pid  │ status│ cpu      │ memory   │
├──────────────────────┼────┼───────────┼──────┼───────┼──────────┼──────────┤
│ ppanel-admin-web     │ 0  │ cluster   │ 1234 │ online│ 0.2%     │ 32.1 MB  │
└──────────────────────┴────┴───────────┴──────┴───────┴──────────┴──────────┘
```

### 手动验证服务

* 打开浏览器访问：
  * 管理端：`http://localhost:3001`
* 检查终端日志，确认服务运行正常。

---

## 7. 服务管理命令（PM2）

### 停止服务

停止所有服务：

```bash
pm2 stop all
```

停止特定服务：

```bash
pm2 stop ppanel-admin-web
```

### 重启服务

重启所有服务：

```bash
pm2 restart all
```

重启特定服务：

```bash
pm2 restart ppanel-admin-web
```

### 删除服务

从 PM2 中移除服务：

```bash
pm2 delete ppanel-admin-web
```

---

## 8. PM2 配置持久化

确保 PM2 在服务器重启后自动启动服务：

```bash
pm2 save
pm2 startup
```

---

您已成功完成 **PPanel 管理端** 的部署！根据您的需求选择最适合的部署方式，建议使用 PM2 实现高效的服务管理和运维。
