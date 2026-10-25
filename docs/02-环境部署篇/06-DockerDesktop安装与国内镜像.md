# 02 环境部署篇 · 第 6 章：Docker Desktop 安装与国内镜像

[← 上一章](05-VSCode安装与必备插件.md) ｜ [返回目录](../../README.md) ｜ [第 7 章：MySQL 数据库安装 →](07-MySQL数据库安装.md)

## 这章解决什么问题

- 在 Windows 上装好 Docker Desktop（含 WSL2 前置条件）
- 解决国内 `docker pull` 拉不动镜像的经典难题

## Docker 是什么（30 秒版）

把软件和它的全部依赖打包成一个**集装箱（镜像）**，任何装了 Docker 的电脑都能原样跑起来——"在我电脑上是好的"这句话从此失效。小白阶段你只需要会 `run` 就够。

## 前置要求（两道门槛）

1. **系统**：Windows 10/11 64 位。
2. **虚拟化**：BIOS 里开启（大多数电脑默认已开）。任务管理器 → 性能 → CPU → 右下角看"**虚拟化：已启用**"。显示"已禁用"就去搜"你的电脑型号 + BIOS 开启虚拟化"。

## 第 1 步：装 WSL2（Docker 的地基）

管理员 PowerShell 执行：

```powershell
wsl --install
```

它会自动装好 WSL2 和 Ubuntu。**执行完重启电脑**。

重启后可能让你给 Ubuntu 设个用户名密码（随便设，记住即可）。验证：

```powershell
wsl --status    # 默认版本显示 2 即成功
```

💡 报 `wsl --update` 相关错？执行 `wsl --update --web-download`，或手动从 https://github.com/microsoft/WSL/releases 下载最新的 `.msi`。

## 第 2 步：安装 Docker Desktop

1. 官网：**https://www.docker.com/products/docker-desktop/** → Download for Windows。
2. 双击安装，勾选 **Use WSL 2 instead of Hyper-V**，一路下一步。
3. 装完启动，右下角托盘出现鲸鱼图标且不报错 = 运行中。

## ✅ 验证

```powershell
docker --version
docker run hello-world
```

第二条会先拉镜像再输出 `Hello from Docker!`——**如果拉不下来，就是第 3 步要解决的事**。

## 第 3 步：配置国内镜像加速（必做）

国内直连 Docker Hub 基本拉不动，需要配**镜像加速器**。

⚠️ **重要认知**：加速地址经常失效（历史原因，你懂的），**别背具体网址，学会配置方法 + 会找最新可用地址**。搜"Docker Hub 国内镜像加速 可用"，挑近三个月内文章里验证过的。

配置方法：Docker Desktop → 设置（齿轮）→ **Docker Engine**，把 JSON 改成：

```json
{
  "builder": {
    "gc": {
      "defaultKeepStorage": "20GB",
      "enabled": true
    }
  },
  "experimental": false,
  "registry-mirrors": [
    "https://docker.1ms.run",
    "https://docker.xuanyuan.me"
  ]
}
```

点 **Apply & restart**，再跑一次 `docker run hello-world`。

💡 还有两条备选路：
- 镜像站挂了就搜"docker hub 镜像"换新的地址；
- 实在不行，给 Docker 挂代理：设置 → Resources → Proxies，填你客户端的 `http://127.0.0.1:7897`。

## 第 4 步：跑第一个真实容器

```powershell
docker run -d -p 8080:80 --name my-nginx nginx
```

浏览器打开 **http://localhost:8080**，看到 Nginx 欢迎页 = 你在本地跑起了一个网站服务器。用完清理：

```powershell
docker stop my-nginx
docker rm my-nginx
```

## 常用命令速查

```powershell
docker ps                # 看在跑的容器
docker ps -a             # 看所有容器（含停止的）
docker images            # 看本地镜像
docker logs 容器名        # 看容器日志（排错第一入口）
docker stop/rm 容器名     # 停止/删除容器
docker rmi 镜像名         # 删除镜像
```

## 常见坑

| 现象 | 解法 |
|---|---|
| 安装时报"WSL 2 installation is incomplete" | `wsl --update` 后重启电脑 |
| Docker Desktop 一直转圈起不来 | 确认虚拟化已启用；托盘退出重开；重启大法 |
| `pull` 一直超时 | 镜像加速地址失效，换新的（第 3 步） |
| `port is already allocated` | 8080 被占，换端口 `-p 8888:80`，或看第 8 章杀进程 |
| C 盘被吃掉几十 GB | 设置 → Resources → Advanced 把磁盘镜像位置挪到 D 盘 |

## ✅ 验证全部完成

```powershell
docker --version        # ✓
docker run hello-world  # 输出 Hello from Docker!
docker run -d -p 8080:80 nginx  # localhost:8080 有欢迎页
```

---

[← 上一章](05-VSCode安装与必备插件.md) ｜ [第 7 章：MySQL 数据库安装 →](07-MySQL数据库安装.md) ｜ [← 返回目录](../../README.md)
