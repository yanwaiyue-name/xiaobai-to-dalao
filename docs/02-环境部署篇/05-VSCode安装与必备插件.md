# 02 环境部署篇 · 第 5 章：VS Code 安装与必备插件

[← 上一章](04-Java环境部署（JDK选择与环境变量）.md) ｜ [返回目录](../../README.md) ｜ [第 6 章：Docker Desktop →](06-DockerDesktop安装与国内镜像.md)

## 这章解决什么问题

- 装好 VS Code（编辑器界的"万能瑞士军刀"）
- 按语言配好必备插件，装完就是顺手的开发环境

## 为什么选 VS Code

免费、轻、插件生态无敌：Python、前端、Java、Go、Markdown 全都能写。小白阶段先用它，以后深入某语言再考虑重型 IDE（如 IDEA）。

## 第 1 步：下载安装

1. 官网：**https://code.visualstudio.com** → 点 Download for Windows。
2. 国内下载慢：优先挂代理（科学上网篇）或换手机热点重试。⚠️ 网上流传的"腾讯 VS Code 镜像"等第三方镜像地址经常失效或根本不存在，**不要用来路不明的下载站**，认准官网域名。
3. 安装时把这两项勾上（默认已勾）：
   - ☑ 将"通过 Code 打开"操作添加到资源管理器目录上下文菜单
   - ☑ 将"通过 Code 打开"操作添加到文件资源管理器文件上下文菜单

（勾了以后任何文件夹右键就能用 VS Code 打开，超实用。）

## ✅ 验证

打开 VS Code，`Ctrl+Shift+P` 输入 `terminal`，选 **Terminal: Create New Terminal**，底部弹出终端即正常。

## 第 2 步：第一波插件（装完就有 80% 战斗力）

左侧扩展图标（四个方块）→ 搜索名字 → Install：

### 通用必装

| 插件 | 干什么 |
|---|---|
| **Chinese (Simplified) Language Pack** | 界面变中文 |
| **Prettier - Code formatter** | 代码自动排版（`Shift+Alt+F` 一键美化） |
| **Error Lens** | 报错直接显示在行内，小白找错神器 |
| **GitLens** | Git 历史一目了然 |
| **Path Intellisense** | 文件路径自动补全 |

### 按语言选装

| 你写什么 | 装 |
|---|---|
| Python | **Python**（微软官方）+ **Pylance** |
| 前端 JS/TS | **ESLint** + **Live Server**（HTML 一键起本地服务器） |
| Java | **Extension Pack for Java**（微软官方全家桶，含调试/Maven） |
| Markdown | **Markdown All in One** |
| 远程开发 | **WSL** / **Remote - SSH**（以后连服务器用） |

⚠️ 插件不是越多越好：装一堆冲突插件会让 VS Code 变卡变怪。用啥装啥。

## 第 3 步：设置同步（换电脑不丢配置）

左下角齿轮 → 打开账号 → 用 GitHub 账号登录 → 开启 **Settings Sync**。插件、主题、快捷键全部云端备份。

## 第 4 步：三个立刻能用的技巧

1. **集成终端**：`` Ctrl+` ``（反引号，Tab 上面那个键）直接在编辑器里开 PowerShell——之前各章的命令都可以在这敲。
2. **命令面板**：`Ctrl+Shift+P`，所有功能搜着用，不用背菜单。
3. **主题**：`Ctrl+Shift+P` → 输入 `theme` → 挑个顺眼的（推荐 One Dark Pro / GitHub Theme）。

## 常见坑

| 现象 | 解法 |
|---|---|
| 装插件转圈装不上 | 网络问题，走代理或搜"vscode 插件离线安装"（下载 .vsix 后扩展面板 `···` → 从 VSIX 安装） |
| 中文乱码/终端中文变问号 | 设置里搜 `encoding`，终端字符集改 UTF-8；`chcp 65001` 临时救急 |
| 代码一保存就乱改格式 | 关掉或重配 Prettier 的"保存时自动排版"设置（formatOnSave） |
| 双开打不开同一个文件夹 | 正常限制，一个窗口一个文件夹 |

## ✅ 验证全部完成

- 界面是中文 ✓
- 装了通用必装五件套 ✓
- `` Ctrl+` `` 能开终端，敲 `git --version` 有输出 ✓
- Settings Sync 已登录 GitHub ✓

---

[← 上一章](04-Java环境部署（JDK选择与环境变量）.md) ｜ [第 6 章：Docker Desktop →](06-DockerDesktop安装与国内镜像.md) ｜ [← 返回目录](../../README.md)
