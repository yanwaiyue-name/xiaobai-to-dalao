# macOS 环境配置补充

[← 返回目录](../README.md)

主教程以 Windows 为第一视角。这一页只列 macOS 上**真正不一样**的地方，避免照着 Windows 命令硬套。

## 1. 包管理器：用 Homebrew

macOS 没有官方的 `winget` 类工具，社区标准是 [Homebrew](https://brew.sh/)。

```bash
# 安装 Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 验证
brew --version
```

常用命令对照：

| 操作 | Windows（Scoop 为例） | macOS（Homebrew） |
|---|---|---|
| 安装 | `scoop install git` | `brew install git` |
| 更新 | `scoop update git` | `brew upgrade git` |
| 卸载 | `scoop uninstall git` | `brew uninstall git` |
| 搜索 | `scoop search vim` | `brew search vim` |

## 2. 环境变量：`$env:` 换成 `$`

PowerShell 与 zsh 的写法不同，这是最容易照搬出错的地方：

| 目的 | Windows PowerShell | macOS zsh |
|---|---|---|
| 读变量 | `$env:PATH` | `$PATH` |
| 临时设变量 | `$env:FOO = "bar"` | `export FOO=bar` |
| 永久配置 | 系统属性 → 环境变量 | 写进 `~/.zshrc` |
| 生效 | 重开终端 | `source ~/.zshrc` |

编辑配置：

```bash
nano ~/.zshrc
# 加入一行，例如：
export PATH="$HOME/.local/bin:$PATH"
# 保存后
source ~/.zshrc
```

## 3. Python：Homebrew 或 pyenv

```bash
# 直接装最新稳定版
brew install python

# 需要多版本共存时用 pyenv
brew install pyenv
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(pyenv init -)"' >> ~/.zshrc
source ~/.zshrc

pyenv install 3.12
pyenv global 3.12
```

注意：macOS 自带的 `/usr/bin/python3` 是系统组件，不要删、不要覆盖。

## 4. Node.js：nvm 或 Homebrew

```bash
# nvm 方式
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
# 重开终端后
nvm install 22
nvm use 22
nvm alias default 22
```

## 5. Git 与代理

```bash
# HTTPS 代理
git config --global http.proxy http://127.0.0.1:7897
git config --global https.proxy http://127.0.0.1:7897

# 取消代理
git config --global --unset http.proxy
git config --global --unset https.proxy
```

SSH 走代理需要在 `~/.ssh/config` 里单独配置（端口按你的客户端实际设置改）。

## 6. 权限：`sudo` 与 `chmod`

- macOS 对系统目录有保护，普通用户不能直接写入 `/usr/local`、`/Library` 等位置。
- 安装到系统级位置时才用 `sudo`；Homebrew 安装的软件一般**不需要** `sudo`。
- 脚本没有执行权限时：

```bash
chmod +x ./script.sh
./script.sh
```

## 7. 自检清单

```bash
echo "Shell: $SHELL"
git --version
python3 --version
node --version
brew --version
echo "$PATH" | tr ':' '\n'
```

## 和主教程的对应关系

| 主教程章节 | macOS 差异 |
|---|---|
| 02 环境部署篇 · Git | 用 Homebrew 装，代理命令相同 |
| 02 环境部署篇 · Python | 用 Homebrew / pyenv，激活命令为 `source .venv/bin/activate` |
| 02 环境部署篇 · Node.js | 用 nvm，`.zshrc` 而非 PowerShell Profile |
| 02 环境部署篇 · 报错急救 | 权限问题用 `chmod` / `sudo`，路径分隔符是 `/` |

---

[← 返回目录](../README.md)
