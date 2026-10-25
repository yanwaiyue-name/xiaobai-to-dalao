# 02 环境部署篇 · 第 7 章：MySQL 数据库安装

[← 上一章](06-DockerDesktop安装与国内镜像.md) ｜ [返回目录](../../README.md) ｜ [第 8 章：报错急救手册 →](08-报错急救手册-环境变量端口占用权限问题.md)

## 这章解决什么问题

- 在 Windows 上装好 MySQL 数据库并设置为系统服务
- 用命令行连上它、建第一个数据库
- 选一款可视化工具（不天天敲 SQL 也很好用）

## 前置要求

Windows 10 / 11。⚠️ 如果 3306 端口被别的软件占了（比如之前装过的软件自带 MySQL），先看第 8 章端口占用篇。

## 第 1 步：下载安装器

1. 官网：**https://dev.mysql.com/downloads/installer/** → 下体积大的**离线完整版**（`mysql-installer-community-x.x.xx.msi`，400MB+）。
   - ⚠️ 官网下载要先点 "No thanks, just start my download" 跳过注册。
2. 要不要登录账号？选 **No thanks**。

## 第 2 步：安装（照着选，少踩坑）

运行安装器，类型选 **Custom**（自定义，只装需要的）：

1. 选中 **MySQL Server 8.x (x64)** 移到右边。
2. 再加一个 **MySQL Workbench**（官方可视化工具）。
3. Next → Execute 开始安装。

配置向导（一路默认，只注意这几处）：

| 页面 | 怎么选 |
|---|---|
| Type and Networking | 默认（端口 **3306**） |
| Authentication Method | 默认（强加密）。⚠️ 如果后面老程序连不上，再回来改"Legacy" |
| **Accounts and Roles** | **设置 root 密码——这是数据库最高管理员密码，务必记牢** |
| Windows Service | 默认（服务名 MySQL80，开机自启） |
| Apply | Execute → Finish |

## ✅ 验证

把 MySQL 加入 PATH：环境变量 → `Path` → 新建 `C:\Program Files\MySQL\MySQL Server 8.0\bin`（按实际版本路径）。然后**新开** PowerShell：

```powershell
mysql --version
mysql -u root -p
# 回车后输入你设的 root 密码
```

出现 `mysql>` 提示符 = 连上了。敲第一个 SQL：

```sql
SHOW DATABASES;          -- 能看到 information_schema 等系统库
CREATE DATABASE demo;    -- 建你的第一个库
USE demo;
SELECT NOW();            -- 显示当前时间
EXIT;
```

## 第 3 步：可视化工具（强烈推荐）

命令行适合学习 SQL 语法，日常用可视化工具效率翻倍：

| 工具 | 价格 | 一句话 |
|---|---|---|
| **MySQL Workbench** | 免费官方 | 刚才装过了，先用它 |
| **DBeaver** | 免费 | 开源全能，支持所有数据库，**口碑之选** |
| Navicat | 💰 付费 | 好用但贵，个人慎买 |
| HeidiSQL | 免费 | 轻量老牌 |

连接参数四件套：主机 `localhost`、端口 `3306`、用户 `root`、密码你设的。

## 💡 另一条路：用 Docker 跑 MySQL（学完第 6 章的可以玩）

```powershell
docker run -d --name mysql-test -p 3306:3306 -e MYSQL_ROOT_PASSWORD=123456 mysql:8
```

一条命令一个数据库，删了重开零残留。**学习环境用 Docker 跑，正式项目再本地装服务**，是更优雅的习惯。

## 服务管理速查

MySQL 装完就是个 Windows 服务（名字 MySQL80），开机自启。手动管理：

```powershell
# 管理员 PowerShell
Get-Service MySQL80                 # 看状态
Stop-Service MySQL80                # 停
Start-Service MySQL80               # 起
```

## 常见坑

| 现象 | 解法 |
|---|---|
| 安装器卡在 Starting the server | 3306 被占（第 8 章）或之前残留过 MySQL → 服务里卸干净旧版再装 |
| `Access denied for user 'root'` | 密码输错；或密码忘了 → 搜"MySQL8 root 密码重置"走 skip-grant-tables 流程 |
| `Can't connect... (10061)` | 服务没起来：`Start-Service MySQL80` |
| 老程序连不上报 `caching_sha2_password` | 认证方式太老，用 Workbench 执行：`ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '你的密码';` |
| 命令行里中文乱码 | 连接后执行 `SET NAMES utf8mb4;`，建库建表统一用 utf8mb4 |

## ✅ 验证全部完成

```powershell
mysql --version      # ✓ 有版本
mysql -u root -p     # ✓ 能进入 mysql> 提示符
SHOW DATABASES;      # ✓ 能看到库列表
```

---

[← 上一章](06-DockerDesktop安装与国内镜像.md) ｜ [第 8 章：报错急救手册 →](08-报错急救手册-环境变量端口占用权限问题.md) ｜ [← 返回目录](../../README.md)
