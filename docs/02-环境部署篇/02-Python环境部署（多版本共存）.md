# 02 环境部署篇 · 第 2 章：Python 环境部署（多版本共存）

[← 上一章](01-Git安装配置与GitHub连接（含代理加速）.md) ｜ [返回目录](../../README.md) ｜ [第 3 章：Node.js 环境部署 →](03-NodeJS环境部署（nvm管理）.md)

## 这章解决什么问题

- 从零装好 Python，并且**装完就能在命令行里用**
- 搞懂"为什么我装了却报'python' 不是内部或外部命令"
- 学会用虚拟环境（venv），不再污染全局

## 前置要求

Windows 10 / 11，无其他要求。

## 第 1 步：下载安装

1. 官网：**https://www.python.org/downloads/** → 黄色大按钮下载最新版（写作时是 3.12/3.13 系列）。
2. 国内下载慢：华为镜像 **https://mirrors.huaweicloud.com/python/** → 找对应版本 → `amd64.exe` 结尾的安装包。

## ⚠️ 安装界面上唯一的生死选项

双击安装包后的**第一个界面**，务必勾选：

> ☑ **Add python.exe to PATH**

然后再点 Install Now。

**90% 的"装完不能用"都因为漏了这一勾。** 漏了怎么办？别慌，看第 8 章（急救手册）补 PATH，或者卸载重装一遍（最快）。

## ✅ 验证安装

**新开** PowerShell：

```powershell
python --version
pip --version
```

分别输出版本号（如 `Python 3.13.1`）即成功。

⚠️ 如果输 `python` 弹出了**微软商店**：这是 Windows 的"应用执行别名"在捣乱。设置 → 应用 → 高级应用设置 → 应用执行别名 → 把 `python.exe` / `python3.exe` 两个开关**关掉**，再重开终端试试。

## 第 2 步：把 pip 换成国内源（装库快 10 倍）

```powershell
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
```

从此 `pip install` 默认走清华源。验证：随便装个小东西

```powershell
pip install requests
```

几秒内完成即配置生效。

## 第 3 步：跑第一个程序

```powershell
# 建个工作目录（路径别带中文！）
mkdir C:\code\hello
cd C:\code\hello
```

新建 `hello.py` 内容一行：

```python
print("Hello, 大佬之路开始！")
```

运行：

```powershell
python hello.py
```

## 第 4 步：虚拟环境（venv）——每个项目独立一套

为什么需要：A 项目要 `requests 2.x`，B 项目要 `3.x`，装一起必打架。虚拟环境就是给每个项目一个独立的"包柜子"。

```powershell
cd C:\code\hello
python -m venv venv          # 创建（首次约 10 秒）
.\venv\Scripts\activate      # 激活：命令行前面出现 (venv) 字样
pip install requests         # 此时装的包只属于这个项目
deactivate                   # 退出虚拟环境
```

⚠️ PowerShell 首次执行 activate 报"禁止运行脚本"？开一个管理员 PowerShell 执行一次：

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

然后重开终端再 activate。

## 💡 多版本共存怎么办

- 官方安装包多装几个版本时，用启动器调用：`py -3.12 hello.py`、`py -3.13 hello.py`（`py --list` 查看装了哪些）。
- 需要频繁切换版本搞 AI / 数据科学？直接上 **Miniconda**（https://docs.conda.io/en/latest/miniconda.html），`conda create -n py312 python=3.12` 一条命令一个环境。新手先不装，等真有需要再说。

## 常见坑

| 现象 | 解法 |
|---|---|
| `'python' 不是内部或外部命令` | 漏勾 Add to PATH → 第 8 章补 PATH 或重装 |
| 输 python 弹微软商店 | 关闭"应用执行别名"（上文） |
| `pip install` 半天没动静/超时 | 没换国内源，回第 2 步 |
| `error: Microsoft Visual C++ 14.0 is required` | 某些库要编译，先试 `pip install --only-binary :all: 包名`；还不行就装个 [VS Build Tools](https://visualstudio.microsoft.com/visual-cpp-build-tools/) |
| 项目代码里 venv 传给了别人 | venv 文件夹不该进 git，写进 `.gitignore` |

## ✅ 验证全部完成

```powershell
python --version     # 版本号
pip --version        # 版本号，且路径在 Python 目录下
python hello.py      # 打印出欢迎语
python -m venv venv  # 能建虚拟环境
```

---

[← 上一章](01-Git安装配置与GitHub连接（含代理加速）.md) ｜ [第 3 章：Node.js 环境部署 →](03-NodeJS环境部署（nvm管理）.md) ｜ [← 返回目录](../../README.md)
