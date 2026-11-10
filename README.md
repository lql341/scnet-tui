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
| Linux | arm64 | ⬜ 可构建，未发布 |

只支持 Linux。安装器在其他系统上会直接退出。

## 说明

- 非官方项目，与曙光智算 / 国家超算互联网无隶属关系。
- 使用受 SCNet 平台条款约束；只使用你有权访问的账号与资源。
- 打包内含 pi 组件，遵循其 MIT 许可证（见 release 内 `LICENSE.pi`）。
