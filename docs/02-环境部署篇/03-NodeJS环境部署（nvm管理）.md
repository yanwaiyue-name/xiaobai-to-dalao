# 02 环境部署篇 · 第 3 章：Node.js 环境部署（nvm 管理）

[← 上一章](02-Python环境部署（多版本共存）.md) ｜ [返回目录](../../README.md) ｜ [第 4 章：Java 环境部署 →](04-Java环境部署（JDK选择与环境变量）.md)

## 这章解决什么问题

- 用 **nvm** 装 Node.js：以后新版本随便升、旧项目随时切，不用卸了装装了卸
- npm 换国内源，装依赖不再龟速

## 为什么用 nvm 而不是官网安装包

Node.js 版本碎片化严重：新项目要 20.x，老项目只跑得动 16.x。官网安装包一次只能一个版本，nvm（Node Version Manager）让你**多条版本共存、一条命令切换**。

## 第 1 步：卸载已有的 Node（如果装过）

控制面板 → 卸载 `Node.js`。⚠️ nvm 切版本的原理要求它全权接管 Node，残留的官方安装版会让切换失效，所以必须先卸干净。

## 第 2 步：安装 nvm-windows

1. 下载：**https://github.com/coreybutler/nvm-windows/releases** → `nvm-setup.exe`。
2. 双击安装，路径保持默认（或全英文路径），完成。

## ✅ 验证

**以管理员身份**打开 PowerShell：

```powershell
nvm version
```

输出版本号即成功。

⚠️ nvm-windows 的很多操作需要管理员权限，**以后凡是用 nvm，都用管理员 PowerShell**。

## 第 3 步：先给 nvm 换国内源（重要）

```powershell
nvm node_mirror https://npmmirror.com/mirrors/node/
nvm npm_mirror https://npmmirror.com/mirrors/npm/
```

不换的话，下一步下载 Node 大概率龟速或失败。

## 第 4 步：安装 Node.js LTS 版本

```powershell
nvm list available        # 看看有哪些版本（找 LTS 标记的）
nvm install 20.18.0       # 装 LTS 大版本（版本号以 list 里最新 LTS 为准）
nvm use 20.18.0           # 启用它
```

## ✅ 验证

```powershell
node --version    # v20.18.0
npm --version     # 10.x.x
```

💡 以后新项目来了：`nvm install 22.x.x` 装新版本，`nvm use` 一秒切换，互不影响。

## 第 5 步：npm 换国内源

```powershell
npm config set registry https://registry.npmmirror.com
```

验证：

```powershell
npm config get registry    # 应输出 npmmirror 地址
```

## 第 6 步：跑第一个程序

```powershell
mkdir C:\code\node-demo
cd C:\code\node-demo
npm init -y                # 生成 package.json
npm install axios          # 装第一个依赖
node -e "console.log('Node 跑起来了')"
```

## 常见坑

| 现象 | 解法 |
|---|---|
| `nvm use` 后 `node` 仍不是内部命令 | 没用管理员权限，或第一步的旧 Node 没卸干净 |
| `nvm install` 下载失败/超时 | 第 3 步的镜像没配，回去配置 |
| `npm install` 卡住 | 换源（第 5 步）；还不行删掉项目里的 `node_modules` 和 `package-lock.json` 重装 |
| 项目报 `node-sass` 安装失败 | 老项目依赖，`npm config set sass_binary_site https://npmmirror.com/mirrors/node-sass/` 再装 |
| 全局装的包找不到 | `npm config get prefix` 看路径，确认该路径在 PATH 里（nvm 路径会自动接管） |

## ✅ 验证全部完成

```powershell
nvm list          # 能看到你装的版本且带 * 号（当前使用）
node --version    # 有版本号
npm --version     # 有版本号
npm config get registry   # npmmirror 地址
```

---

[← 上一章](02-Python环境部署（多版本共存）.md) ｜ [第 4 章：Java 环境部署 →](04-Java环境部署（JDK选择与环境变量）.md) ｜ [← 返回目录](../../README.md)
