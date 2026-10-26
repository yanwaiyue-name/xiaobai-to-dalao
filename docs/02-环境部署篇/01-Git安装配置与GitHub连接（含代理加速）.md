# 02 环境部署篇 · 第 1 章：Git 安装配置与 GitHub 连接（含代理加速）

[← 返回目录](../../README.md) ｜ [第 2 章：Python 环境部署 →](02-Python环境部署（多版本共存）.md)

## 这章解决什么问题

- 从零装好 Git
- Git 关联上你的 GitHub 账号（HTTPS 和 SSH 两种方式）
- **`git clone` / `git push` 一直卡住转圈、连接超时**——用代理一次解决

## 前置要求

- Windows 10 / 11
- 有一个 [GitHub](https://github.com) 账号（没有就先注册一个）
- 建议：先把科学上网篇跑通（连 GitHub 会顺很多），但没条件也照样能装

## 第 1 步：下载安装 Git

1. 官网：**https://git-scm.com/downloads** → 点 Windows → 下载 "64-bit Git for Windows Setup"。
2. 官网下载慢？用国内镜像：**https://registry.npmmirror.com/binary.html?path=git-for-windows/** → 挑版本号最新的 → 下载 `Git-x.x.x-64-bit.exe`。
3. 双击安装，**一路 Next 用默认选项即可**（默认就够好），最后 Install。

## ✅ 验证安装

**新开一个** PowerShell（一定要新开，旧窗口不认新装软件）：

```powershell
git --version
```

输出类似 `git version 2.47.0` 即成功。

## 第 2 步：报上你的名号（首次必做）

```powershell
git config --global user.name "你的名字"
git config --global user.email "你的GitHub注册邮箱"
git config --global init.defaultBranch main
git config --global core.quotepath false
```

💡 最后一条让中文文件名在 git 里正常显示，不配置的话会显示成 `\346\226\207` 这种乱码。

验证：

```powershell
git config --global --list
```

## 第 3 步：让 GitHub 认识你（二选一）

### 方式 A：HTTPS + 专用钥匙 Token（最简单，推荐小白）

💡 先看一眼：Git for Windows 默认带 **Git Credential Manager**，第一次 `git push` 很可能直接弹出**浏览器授权窗口**，登录授权一次就完事——那样就不用管下面的 token 了。只有弹出来的是"用户名 + 密码"输入框时，才需要走方式 A。

现在 GitHub 不让 HTTPS 提交时填登录密码了，要改用一把"专用钥匙"：**Personal Access Token**（个人访问令牌——一把只能用来操作仓库的钥匙，比主密码更安全）：

1. GitHub → 右上角头像 → Settings → Developer settings → Personal access tokens → **Tokens (classic)**。
2. Generate new token (classic) → 备注随便填 → 勾选 `repo` → 生成。
3. **立刻复制保存**（只显示一次）。
4. 以后 `git push` 时：用户名填 GitHub 用户名，密码栏**粘贴这个 token**。

### 方式 B：SSH 密钥（一次配置，永远免密）

```powershell
ssh-keygen -t ed25519 -C "你的邮箱"
```

一路回车（默认路径、空密码）。然后：

```powershell
notepad "$env:USERPROFILE\.ssh\id_ed25519.pub"
```

复制打开的**整行内容**（`ssh-` 开头）→ GitHub → Settings → SSH and GPG keys → New SSH key → 粘贴 → Add。

验证：

```powershell
ssh -T git@github.com
```

出现 `Hi 你的用户名! You've successfully authenticated` 即成功。（首次连接问 `Are you sure...` 输 `yes` 回车。）

## 第 4 步：GitHub 连不上 / 超时（本仓库最高频问题）

症状：`clone` 卡在 Receiving objects、报 `Failed to connect to github.com`、`Operation timedout`、443 超时。

**你已经能科学上网的话（强烈推荐）**——给 Git 单独挂代理：

```powershell
# 端口改成你客户端的 HTTP 端口！Clash Verge Rev 默认 7897，老版 Clash 是 7890；v2rayN 是 socks 10808 / http 10809，这里要填 10809——以客户端设置页显示为准
git config --global http.proxy http://127.0.0.1:7897
git config --global https.proxy http://127.0.0.1:7897
```

💡 进阶技巧（社区高频问答，详见第 9 章）：**只让 GitHub 走代理**——公司内网 GitLab 不受影响，代理软件时开时关也不影响其他仓库：

```powershell
git config --global http.https://github.com.proxy http://127.0.0.1:7897
```

撤销这条：`git config --global --unset http.https://github.com.proxy`

⚠️ 代理软件没开的时候，Git 会因此连不上网。不用代理的那天记得撤销：

```powershell
git config --global --unset http.proxy
git config --global --unset https.proxy
```

**没有代理条件的话**，两条备选：

1. **修改 hosts 绑定 IP**：在 https://www.ipaddress.com 查询 `github.com` 和 `github.global.ssl.fastly.net` 的 IP，追加到 `C:\Windows\System32\drivers\etc\hosts`（需管理员权限编辑），然后刷新 DNS：

```powershell
ipconfig /flushdns
```

2. **用镜像加速下载**：`https://gh-proxy.com/https://github.com/用户名/仓库` 这类加速前缀（此类站点经常变动，失效就搜"GitHub 加速"找最新可用的）。仅建议用于 clone 公开仓库。

## 💡 第 5 步：装个官方 CLI（可选但好用）

[GitHub CLI](https://cli.github.com) 让你不用开网页就能建仓库、提 PR。装好后 `gh auth login` 按提示走完即可，比如一条命令建仓库并推送：

```powershell
gh repo create my-repo --public --source=. --push
```

## 常见坑

| 现象 | 解法 |
|---|---|
| `git push` 要密码，输了对也不行 | HTTPS 方式要填 **token** 不是密码（方式 A 第 3 条） |
| 配了代理反而全部超时 | 代理软件没开；或端口填错。开了软件、核对端口 |
| `Permission denied (publickey)` | 用的是 SSH 地址但没配密钥，走方式 B；或改用 HTTPS 地址 |
| 中文文件名乱码 | `git config --global core.quotepath false` |
| 公司/学校网络啥都连不上 | 大概率网络本身限制，先解决科学上网篇 |

## ✅ 验证全部完成

```powershell
git --version          # 有版本号
ssh -T git@github.com  # Hi xxx（SSH 用户）
# 或任意 clone 一个小仓库成功
git clone https://github.com/octocat/Hello-World.git
```

三条都通过，Git 这关毕业。

---

[← 返回目录](../../README.md) ｜ [第 2 章：Python 环境部署 →](02-Python环境部署（多版本共存）.md)
