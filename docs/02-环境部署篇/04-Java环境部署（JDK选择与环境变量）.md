# 02 环境部署篇 · 第 4 章：Java 环境部署（JDK 选择与环境变量）

[← 上一章](03-NodeJS环境部署（nvm管理）.md) ｜ [返回目录](../../README.md) ｜ [第 5 章：VS Code 安装与必备插件 →](05-VSCode安装与必备插件.md)

## 这章解决什么问题

- 知道装哪个 JDK（版本多、发行商多，小白最容易懵）
- 配好 `JAVA_HOME` 和 `Path`——Java 界的经典必修课
- 验证 `java` 和 `javac` 都能跑

## 先搞懂：JDK 怎么选

### 版本（大版本号）

| 版本 | 定位 | 建议 |
|---|---|---|
| JDK 8 | 老项目钉子户 | 只在跑别人老项目时装 |
| JDK 11 / 17 | 企业主流 | 跟课程/教程走 |
| **JDK 21** | 最新 LTS（长期支持） | **新学习项目直接装这个** |

💡 LTS = Long Term Support，官方长期维护的版本，**没有特殊理由就装最新 LTS**。

### 发行商

| 发行商 | 价格 | 说明 |
|---|---|---|
| **Eclipse Temurin（Adoptium）** | 免费 | 社区良心，**推荐**，下载方便 |
| Oracle JDK | 注意授权 | 官方出品，商用授权有坑，学习用也行 |
| Amazon Corretto | 免费 | 亚马逊出品，同样可靠 |

## 第 1 步：下载 Temurin JDK 21

1. 打开 **https://adoptium.net**，页面会自动识别系统，直接点下载按钮（`.msi` 安装包）。
2. ⚠️ 国内直连 adoptium 慢的话：清华镜像 **https://mirrors.tuna.tsinghua.edu.cn/Adoptium/** → `21/jdk/x64/windows/` → 下 `.msi`。

## 第 2 步：安装（记住安装路径）

双击 `.msi` 安装：

- 组件页面把 `Set JAVA_HOME variable` 设为**整行安装**（这步能自动帮你配好环境变量）。
- 安装路径默认类似 `C:\Program Files\Eclipse Adoptium\jdk-21.x.x-hotspot\`，**复制存好**。

## 第 3 步：配置环境变量

装的时候勾了 JAVA_HOME 的话，这步基本自动完成了，但**手动会配是必备技能**（面试也考）：

1. Win 键搜"**编辑系统环境变量**" → 环境变量。
2. **系统变量**区 → 新建：
   - 变量名：`JAVA_HOME`
   - 变量值：`C:\Program Files\Eclipse Adoptium\jdk-21.x.x-hotspot`（你实际的路径）
3. 找到系统变量里的 `Path` → 编辑 → **新建**一行：
   - `%JAVA_HOME%\bin`
4. 一路确定保存。

## ✅ 验证

**新开** PowerShell（改完环境变量必须新开窗口）：

```powershell
java -version     # 输出 openjdk version "21.x.x"
javac -version    # 输出 javac 21.x.x（有这个说明编译器也在）
echo $env:JAVA_HOME   # 输出你配的路径
```

三个都对，Java 环境就绪。

## 第 4 步：跑第一个程序

建 `C:\code\java-demo\Hello.java`（**文件名必须和类名一致**）：

```java
public class Hello {
    public static void main(String[] args) {
        System.out.println("Hello, Java!");
    }
}
```

```powershell
cd C:\code\java-demo
javac Hello.java    # 编译，生成 Hello.class
java Hello          # 运行，输出 Hello, Java!
```

## 💡 多版本共存

要同时有 JDK 8 和 21？装两份、`JAVA_HOME` 指向哪个用哪个。真正开发后建议用 IDEA / VS Code 的 JDK 管理功能按项目切换，命令行层不用折腾。

## 常见坑

| 现象 | 解法 |
|---|---|
| `'javac' 不是内部或外部命令`（但 java 有） | Path 里没 `%JAVA_HOME%\bin`，或写的具体路径拼错了 |
| 改了环境变量还是不行 | 没重开终端；实在不行注销重登 |
| `错误: 找不到或无法加载主类` | 类名与文件名不一致 / 在错误目录里执行 / 带了 `.class` 后缀（运行时不带） |
| 装了 Oracle JDK 提示授权 | 学习用途没影响；介意就换 Temurin |
| IDE 里选不到 JDK | IDEA/VS Code 里手动指向 `%JAVA_HOME%` 路径 |

## ✅ 验证全部完成

```powershell
java -version     # ✓
javac -version    # ✓
java Hello        # 输出 Hello, Java!
```

---

[← 上一章](03-NodeJS环境部署（nvm管理）.md) ｜ [第 5 章：VS Code 安装与必备插件 →](05-VSCode安装与必备插件.md) ｜ [← 返回目录](../../README.md)
