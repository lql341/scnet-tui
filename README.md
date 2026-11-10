# scnet-tui

`scnet` 预编译版分发仓库。包含安装脚本、版本文件和 Release 资产，不包含源码。

## 安装

```bash
curl -fsSL https://raw.githubusercontent.com/lql341/scnet-tui/main/install.sh | bash
```

安装器行为：

1. 识别 `linux`/`darwin` 与 `x64`/`arm64`；
2. 读取 `version.txt`，直连 release 下载，不消耗 GitHub API 限额；
3. 断点续传并校验 `.sha256`；
4. 解压到 `~/.local/share/scnet`，软链到 `~/.local/bin/scnet`；
5. 直连失败时回退到 GitHub API。

可选环境变量：

```bash
SCNET_VERSION=<version>
GITHUB_TOKEN=<token>
SCNET_INSTALL_DIR=$HOME/.local/share/scnet
SCNET_BIN_DIR=$HOME/.local/bin
SCNET_RELEASE_BASE=file://$HOME/scnet-mirror
```

支持平台：

| 平台 | 架构 |
| --- | --- |
| Linux | x64、arm64 |
| macOS | x64、arm64 |

未提供的组合会明确报错。

## 升级

```bash
scnet update --check
scnet update
```

## 首次使用

```bash
scnet doctor
scnet login
scnet
```

## 常用命令

```bash
scnet exec "总结这个仓库"
scnet review
scnet sci status
scnet sci jobs
scnet files ls /public/home/<user>
scnet files download /public/home/<user>/out ./out --transport shared
scnet agents --industry
scnet cloud list
scnet hpc status
scnet mcp serve
```

模型凭据通过 `scnet login` 配置；HPC AK/SK 通过
`scnet hpc login <user> <AK> <SK>` 配置。两者独立。

## Shell 补全

```bash
scnet completion bash > ~/.local/share/bash-completion/completions/scnet
scnet completion zsh > "${fpath[1]}/_scnet"
scnet completion fish > ~/.config/fish/completions/scnet.fish
```

## 说明

- 本项目为内部提前测试版本，仅用于授权范围内的功能评估与验证。
- 使用受 SCNet 平台条款约束，仅使用已授权的账号与资源。
- 分发包内含 pi 组件，遵循 MIT 许可证，见包内 `LICENSE.pi`。
