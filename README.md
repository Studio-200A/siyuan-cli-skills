# SIYUAN-CLI-SKILLS — 思源笔记 AI Agent 操作指南

## 1. 它是什么，干什么用

**SIYUAN-CLI-SKILLS.md** 是一份 AI Agent 的思源 CLI 操作说明书。把它丢给任何一个支持读取文件的 AI 助手（Claude Code、Cursor、CodeBuddy 等），这个 AI 就能通过 `siyuan` 命令行工具帮你**搜索、阅读、创建、编辑、组织、导入导出、快照保护、同步管理**你的思源笔记工作空间。

简单说：它是思源笔记和外部 AI 之间的翻译官，让 AI 知道怎么安全地操作你的笔记。

## 2. 它来自官方 agent.go，是"化用"而非重造

思源 3.7.0 内核内置了一个 AI agent（源码 `agent.go`），它定义了一套完整的范式：block 领域模型（容器块/叶子块）、heading 非容器的坑、`safeActions` 读写白名单、doom loop 死循环检测、一度自动快照、`[tool_output]` 不可信数据标记……但这些设计是**为内置 agent + GUI 弹窗确认**服务的。

本文档将这整套范式**外部化**了：

- agent.go 通过 UI 弹窗让用户确认每个写操作 → 本文档改为列出操作计划、等用户文本确认
- agent.go 有 `safeActions` 白名单自动放行只读操作 → 本文档划出 Safety Level 1/2/3 三级分类
- agent.go 用 `snapshotCreated` 标记确保一次会话只打一次快照 → 本文档将快照纳入操作计划、确认后执行
- agent.go 用 `doomLoopTracker` 检测签名重复终止循环 → 本文档规定同命令失败上限 5 次后换方法

**它不是直接翻译 agent.go，而是保留其安全哲学和操作边界，把每个机制落地为 CLI 场景下可执行的等价方案。**

## 3. 安全性设计梳理

因为 `siyuan` CLI 直接操作内核数据、无 UI 确认弹窗、无撤销功能，外部 agent 的危险程度远高于内置 agent。文档用四层机制兜底：

**第一层：快照兜底。** 每次写入任务第一件事是打数据快照，改坏了可以 `repo checkout` 回滚。快照 ID 明确告知用户。

**第二层：用户确认。** 发现阶段收集完所有信息后，列出完整操作清单（每个命令、目标 ID、预期结果），等用户说"确认"才动手。不搞静默写入。

**第三层：逐个验证。** 每执行一步，立即用读命令回读确认结果，不依赖"零退出码=成功"。

**第四层：失败熔断。** 同一命令连续失败 3 次自动换方法，5 次终止，不会卡死循环。

**额外防线：** 规则写死"永不编造 ID、路径、block 类型"，所有标识符必须从实际工作空间发现，消除 AI 幻觉风险；所有思源返回内容视作不可信数据，防止 prompt 注入。

## 4. 如何使用

不同 AI 软件的具体使用方式各有差异，但核心操作都一样简单：

> **让 AI 读取这份文档即可。**

把 `SIYUAN-CLI-SKILLS.md` 放在 AI 能访问到的目录里，然后在对话中说："请先阅读 `SIYUAN-CLI-SKILLS.md`，然后帮我搜索/创建/管理思源笔记"。

第一次使用时可以这样引导：

```
请阅读 /path/to/SIYUAN-CLI-SKILLS.md，然后检查我电脑上的 siyuan CLI
版本，列出已注册的工作空间，给我做一个总体介绍。
```

这份文档本身就是自解释的——AI 读完就知道怎么用 `siyuan` 命令、有哪些安全规则必须遵守、如何组织多步骤操作。

### 附带的完整 CLI 命令速查表

文档末尾（附录）包含一份**通过脚本自动从 CLI 帮助输出抓取的完整命令速查表**，覆盖全部 144 个 `siyuan` 子命令。每个命令都标注了用途和参数签名。

这意味着 AI 不需要靠训练记忆猜测命令名或参数名——不确定时可以直接查表，或者用 `siyuan <command> --help` 获取最新的实时帮助。速查表 + 实时帮助双保险，彻底消除命令格式的幻觉风险。

## 5. 依赖

### 必需依赖：思源 CLI

这份 skill 依赖思源 3.7.0 及以上版本提供的内核 CLI。不同平台下二进制名称可能是 `siyuan` 或 `SiYuan-Kernel`，具体以你的安装方式为准。

可以用下面的命令检查：

```bash
siyuan --version
```

如果提示 `command not found`，请确认思源 3.7.0+ 已安装，并把思源内核 CLI 所在目录加入系统 `PATH`，或在使用时告诉 AI 实际的 CLI 路径和二进制名称。

### 推荐依赖：`jq`

`jq` 是命令行 JSON 处理工具。思源 CLI 的 `--format json` 输出很多，AI agent 在提取 notebook ID、block ID、snapshot ID、数据库字段、搜索结果等信息时，用 `jq` 会比直接从整段 JSON 里人工判断更稳定。

严格来说，`jq` 不是思源 CLI 的硬性依赖；但为了让这份 skill 更可靠，强烈建议安装。

#### Windows

如果你使用 WinGet：

```powershell
winget install jqlang.jq
```

如果你使用 Chocolatey：

```powershell
choco install jq
```

如果你使用 Scoop：

```powershell
scoop install jq
```

安装后重新打开终端，检查：

```powershell
jq --version
```

#### macOS

如果你使用 Homebrew：

```bash
brew install jq
```

检查：

```bash
jq --version
```

#### Linux

Debian / Ubuntu：

```bash
sudo apt update
sudo apt install jq
```

Fedora：

```bash
sudo dnf install jq
```

Arch Linux：

```bash
sudo pacman -S jq
```

检查：

```bash
jq --version
```

## 6. 按需定制

文档的全部内容你都可以自由修改，适配自己的使用习惯。常见定制场景：

- **不想每次等确认**：删掉 SOP 第 11 步（展示计划等待确认）及规则 11 中的相关要求，AI 会在发现完后直接执行。
- **不想要快照**：删掉规则 10 和 SOP 第 12 步，AI 会跳过快照直接操作。
- **只想让 AI 读不能写**：删掉 Safety Level 2 和 Level 3 全部命令，AI 就只会做查询。
- **添加自定义工作流**：在 Common workflows 章节追加你自己的固定操作模式。

文档就是一个 Markdown 文件，用任何编辑器改都可以。改完保存，下次 AI 读到的就是你的定制版。

## 7. 重要说明

### 平台差异

本文档的 Shell 示例基于 POSIX 系统（Linux/macOS + bash/zsh）。如果你在 **Windows + PowerShell** 下使用，需要让 AI 先修改文档再执行，比如对 AI 说：

> 请先阅读 SIYUAN-CLI-SKILLS.md，这份文档写的是 bash shell 的语法，请将里面的所有命令示例改为适配当前 Windows 环境下的 PowerShell 语法，然后再帮我执行下面的任务：……

主要差异是变量定义方式（`$SIYUAN_WORKSPACE` → `$env:SIYUAN_WORKSPACE`）、Heredoc 语法、临时文件路径等。交给 AI 改就行。

### CLI 二进制名称

可能是`siyuan` 或 `SiYuan-Kernel` ，名称因平台而异。如果 `siyuan` 报 "command not found"，试试 `SiYuan-Kernel`。AI 读到文档后会先执行 `command -v siyuan` 探测，如果找不到你提醒一句即可切换，或告诉AI CLI二进制具体位置及名称，并要求AI按实际情况修改skill文档。
