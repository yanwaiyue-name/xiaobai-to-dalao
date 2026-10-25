# 02 环境部署篇 · 第 9 章：社区精选问答（GitHub / Stack Overflow 高频问题）

[← 上一章](08-报错急救手册-环境变量端口占用权限问题.md) ｜ [返回目录](../../README.md)

## 这章解决什么问题

本章整理自 GitHub 官方文档、Stack Overflow、CSDN、知乎、微软官方文档上的**真实高频提问**——都是被问过成千上万次、有标准答案的经典问题。每题附出处链接可溯源。

⚠️ 外部链接会随时间失效，打不开时用报错原文搜索即可。

---

## 一、Git / GitHub 类

### Q1：`git push` 报 `! [rejected] ... (non-fast-forward)`，推不上去

**答**：远程仓库有你本地没有的提交（同事推过，或你在网页上改过文件）。**不要急着重装 Git**，先拉再推：

```powershell
git pull --rebase origin main
git push origin main
```

实在确定要覆盖远程（团队协作中慎用）：用 `git push --force-with-lease`，比直接用 `git push --force` 多一道保险——万一远程在这期间又有了新提交，它会拒绝执行，防止你误删别人的工作。

> 📎 出处：[GitHub 官方文档：处理非快进错误](https://docs.github.com/zh/get-started/using-git/dealing-with-non-fast-forward-errors) ｜ [Stack Overflow: What does "non-fast-forward updates were rejected" mean](https://stackoverflow.com/questions/4684352/what-does-git-push-non-fast-forward-updates-were-rejected-mean) ｜ [CSDN：git push rejected 解决](https://blog.csdn.net/index20001/article/details/99764558) ｜ [知乎：git push 出现 ! [rejected] 错误](https://zhuanlan.zhihu.com/p/707863606)

### Q2：`fatal: not a git repository`

**答**：你在**不是仓库的目录**里运行了 git 命令。`cd` 到项目根目录（里面藏着 `.git` 文件夹的那层）；目录里确实没有 `.git` 就先 `git init`。用 `ls -a` 确认。

> 📎 出处：[Pro Git 中文版（官方书，Git 问题终极字典）](https://git-scm.com/book/zh/v2)

### Q3：`git clone` / `git push` 超时，报 `Failed to connect to github.com port 443`

**答**：本仓库第 1 章给了完整代理方案，社区文章里还有一个**进阶技巧值得收录**——只让 GitHub 走代理、其他仓库直连：

```powershell
git config --global http.https://github.com.proxy http://127.0.0.1:7897
```

（端口换成你自己客户端的。公司内网 GitLab 等不受影响，这招在"代理软件时开时关"的场景也更好用。）其余方法：改 hosts 绑定 IP、镜像加速前缀。

> 📎 出处：[CSDN：Github 可以访问但 git clone 报 443 超时](https://blog.csdn.net/caiji00001/article/details/142302401) ｜ [CSDN：git 连接 443 超时解决](https://blog.csdn.net/weixin_62703679/article/details/136610236) ｜ [知乎：解决 Github port 443 Timed out](https://zhuanlan.zhihu.com/p/636418854)

### Q4：`.gitignore` 写了却还在被跟踪（不生效）

**答**：`.gitignore` 只对**未跟踪**的文件生效。文件已经被 commit 过，加进 .gitignore 也没用。解法（`--cached` 参数保证**不删本地文件**）：

```powershell
git rm -r --cached .
git add .
git commit -m "chore: 应用 .gitignore"
```

> 📎 出处：[Stack Overflow: Git still tracks files in gitignore file](https://stackoverflow.com/questions/64807023/git-still-tracks-files-in-gitignore-file) ｜ [CSDN：.gitignore 不生效解决](https://blog.csdn.net/liuruiaaa/article/details/145950703)

### Q5：git 里中文文件名显示成 `\346\226\207\344\273\256` 乱码

**答**：一条命令关闭转义显示：

```powershell
git config --global core.quotepath false
```

终端里还乱的话再配 `git config --global i18n.logoutputencoding utf-8` 并把终端编码调成 UTF-8。

> 📎 出处：[miniasp 博客：Git for Windows 中文显示问题](https://blog.miniasp.com/post/2017/09/17/Git-for-Windows-Command-Prompt-Display-Chinese-Issues)

## 二、WSL / Docker 类

### Q6：装 WSL2 报错 `0x80370102`

**答**：这是"虚拟化没启用或虚拟机平台没开"的专用错误码，三步修：

1. BIOS 里开 CPU 虚拟化（Intel VT-x / AMD-V；任务管理器 → 性能 → CPU 看是否"已启用"）
2. Windows 功能里勾选"**虚拟机平台**"和"**适用于 Linux 的 Windows 子系统**"，重启
3. `wsl --update` 更新内核

> 📎 出处：[微软官方文档：排查 WSL 问题](https://learn.microsoft.com/zh-cn/windows/wsl/troubleshooting)

### Q7：`docker pull` 报 EOF / failed to copy / 一直卡住

**答**：国内直连 Docker Hub 基本拉不动。配镜像加速器（地址经常失效，失效就搜新的换上）：

```json
{ "registry-mirrors": ["https://docker.1ms.run", "https://docker.m.daocloud.io"] }
```

Docker Desktop 在设置 → Docker Engine 里改；Linux 在 `/etc/docker/daemon.json` 改后 `systemctl restart docker`。最后兜底手段是给 Docker 配代理（设置 → Resources → Proxies）。

> 📎 出处：[CSDN：WSL2 Docker Desktop 拉取镜像报错](https://blog.csdn.net/blink182007/article/details/151062752) ｜ [CSDN：WSL 中无法访问 registry-1.docker.io](https://blog.csdn.net/qq_31362767/article/details/149616105)

### Q8：Docker Desktop 一直转圈起不来（WSL 环境）

**答**：社区验证过的重启三连：

```powershell
wsl --update
wsl --shutdown
# 然后重新打开 Docker Desktop
```

> 📎 出处：[CSDN：Docker 在 WSL 环境启动失败](https://blog.csdn.net/2303_80806493/article/details/147874710)

### Q9：WSL 安装/启动报配置相关错误（`.wslconfig`）

**答**：安装程序**不会自动生成** `.wslconfig`，需要时手动创建 `C:\Users\你的用户名\.wslconfig`；旧的残缺配置文件反而会引发安装失败，删掉重配。

> 📎 出处：[CSDN：安装 WSL2 报错与 .wslconfig](https://blog.csdn.net/usstmiracle/article/details/161613196)

---

## 💡 顺便学一下：在 Stack Overflow / GitHub 提问的正确姿势

- 标题直接写**完整报错原文**（搜索引擎和回答者都靠它匹配）
- 附上：操作系统、软件版本、复现步骤、已试过什么
- 先搜后问：你的报错 99% 有人问过，**会搜索本身就是大佬核心技能**

---

[← 上一章](08-报错急救手册-环境变量端口占用权限问题.md) ｜ [← 返回目录](../../README.md)
