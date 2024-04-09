# 完整教程：通过 PM2、Node.js 和 Bun 部署 PPanel 用户端

本教程完整涵盖如何使用 **PM2** 配置文件，以及直接通过 **Node.js** 和 **Bun** 部署 **PPanel 用户端**。

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
[ -s "$NVM_DIR/nvm.sh" ] && \ . "$NVM_DIR/nvm.sh"
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
bun -v    # 检查 Bun 版本（请确保所用版本与项目兼容，避免潜在问题）
pm2 -v    # 检查 PM2 版本
```

---

## 2. 环境变量说明

PPanel 用户端使用 `.env` 文件来存储环境变量配置。

### 用户端环境变量文件

路径：`apps/user/.env`

示例内容：

```env
# Default Language
NEXT_PUBLIC_DEFAULT_LANGUAGE=en-US

# Site URL and API URL
NEXT_PUBLIC_SITE_URL=https://your-custom-domain.dev
NEXT_PUBLIC_API_URL=https://api.ppanel.dev

# Contact Email
NEXT_PUBLIC_EMAIL=support@ppanel.dev
# Community Links
NEXT_PUBLIC_TELEGRAM_LINK=https://t.me/ppanel
NEXT_PUBLIC_TWITTER_LINK=https://github.com/perfect-panel/ppanel-web
NEXT_PUBLIC_DISCORD_LINK=https://github.com/perfect-panel/ppanel-web
NEXT_PUBLIC_INSTAGRAM_LINK=https://github.com/perfect-panel/ppanel-web
NEXT_PUBLIC_LINKEDIN_LINK=https://github.com/perfect-panel/ppanel-web
NEXT_PUBLIC_FACEBOOK_LINK=https://github.com/perfect-panel/ppanel-web
NEXT_PUBLIC_GITHUB_LINK=https://github.com/perfect-panel/ppanel-web

# Default Login User
NEXT_PUBLIC_DEFAULT_USER_EMAIL=admin@ppanel.dev
NEXT_PUBLIC_DEFAULT_USER_PASSWORD=password
```

根据需要修改以上变量以匹配您的部署环境。

---

## 3. 下载和解压代码

### 3.1 下载 PPanel 用户端

运行以下命令下载 PPanel 用户端的压缩包：

```bash
# 建议确认链接是否为最新版本，确保下载的代码为最新稳定版本
curl -LO https://github.com/perfect-panel/ppanel-web/releases/download/v1.0.0-beta.3/ppanel-user-web.tar.gz
```

### 3.2 解压文件

解压文件到当前目录，压缩包中已包含对应文件夹：

```bash
# 解压用户端
tar -xzvf ppanel-user-web.tar.gz
```

解压完成后，当前目录将包含以下文件夹：

- `ppanel-user-web`

---

## 4. 使用 PM2 部署

### 用户端的 PM2 配置文件

进入 `ppanel-user-web` 文件夹，确保 `ecosystem.config.js` 文件内容如下：

```javascript
module.exports = {
  apps: [
    {
      name: "ppanel-user-web",
      script: "apps/user/server.js",
      interpreter: "bun",
      watch: true,
      instances: "max",
      exec_mode: "cluster",
      env: {
        PORT: 3002
      }
    }
  ]
};
```

### 启动服务

进入用户端目录并使用 PM2 启动：

```bash
cd ./ppanel-user-web
pm2 start ecosystem.config.js
```

---

## 5. 使用 Node.js 和 Bun 部署（非 PM2）

如果您选择不使用 PM2，可以直接使用 **Node.js** 和 **Bun** 启动服务。

### 部署用户端

进入 `ppanel-user-web` 目录：

#### 使用 Bun 启动用户端：

```bash
cd ./ppanel-user-web
bun apps/user/server.js
```

#### 使用 Node.js 启动用户端：

```bash
cd ./ppanel-user-web
node apps/user/server.js
```

---

## 6. 验证服务

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
└──────────────────────┴────┴───────────┴──────┴───────┴──────────┴──────────┘
```

### 手动验证（Node.js 和 Bun）

- 打开浏览器访问服务所在的端口：
  - 用户端端口：`http://localhost:3002`
- 检查终端日志，确认服务正常运行。

---

## 7. 服务管理命令（PM2）

### 停止服务

停止所有 PM2 管理的服务：

```bash
pm2 stop all
```

停止单个服务：

```bash
pm2 stop ppanel-user-web
```

### 重启服务

重启所有服务：

```bash
pm2 restart all
```

重启单个服务：

```bash
pm2 restart ppanel-user-web
```

### 删除服务

从 PM2 中移除服务：

```bash
pm2 delete ppanel-user-web
```

---

## 8. 持久化 PM2 配置

确保 PM2 在服务器重启后自动启动服务：

```bash
pm2 save
pm2 startup
```

---

至此，您已成功通过 **PM2**、**Node.js** 和 **Bun** 部署了 **PPanel 用户端**！根据需求选择最适合的方式运行服务，推荐使用 PM2 进行统一管理以实现高效运维。

