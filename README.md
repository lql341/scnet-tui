# scnet-tui

预编译版 `scnet` 终端客户端：SCNet 账户登录、免费模型、科学计算作业、云端会话、领域智能体。

> 本仓库只分发**预编译产物和安装脚本**，不包含源码。源码仓库为私有。

## 安装

```bash
curl -fsSL https://raw.githubusercontent.com/lql341/scnet-tui/main/install.sh | bash
```

安装器会：

1. 识别 Linux x64 / arm64；
2. 优先读取 `version.txt` 并直连 release 下载（不消耗 GitHub API 限额）；
3. 断点续传，校验 sha256；
4. 解压到 `~/.local/share/scnet`，软链到 `~/.local/bin/scnet`。

可选环境变量：

```bash
SCNET_VERSION=0.1.10                # 指定版本
GITHUB_TOKEN=ghp_xxx                # 提升 GitHub API 限额（可选）
SCNET_INSTALL_DIR=$HOME/.local/share/scnet
SCNET_BIN_DIR=$HOME/.local/bin
```

## 升级

```bash
scnet update --check    # 只看有没有新版本
scnet update            # 下载最新 release 并原地替换
```

## Shell 补全

```bash
scnet completion bash > ~/.local/share/bash-completion/completions/scnet
scnet completion zsh > "${fpath[1]}/_scnet"
scnet completion fish > ~/.config/fish/completions/scnet.fish
```

## 首次使用

```bash
scnet doctor
scnet login            # 没有账号：scnet login --register
scnet                  # 进入 TUI
```

常用命令：

```bash
scnet exec "总结这个仓库"        # 非交互
scnet review                    # 非交互代码审查
scnet sci status                # 区域/队列/配额（--json 供脚本）
scnet agents --industry         # 七类行业智能体
scnet cloud list                # 云端会话
scnet hpc status                # 集群凭据状态
scnet mcp serve                 # 作为只读 MCP server
```

## 支持平台

| 平台 | 架构 | 状态 |
| --- | --- | --- |
| Linux | x64 | ✅ |
| Linux | arm64 | ✅ |
| macOS | arm64 | ✅ |
| macOS | x64 | ✅ |

安装器按 `uname` 与 `uname -m` 选择对应资产；未提供的组合会明确报错。

## 说明

- 本项目为内部提前测试版本，仅用于授权范围内的功能评估与验证。
- 使用受 SCNet 平台条款约束；仅使用已授权的账号与资源。
- 打包内含 pi 组件，遵循其 MIT 许可证（见 release 内 `LICENSE.pi`）。
