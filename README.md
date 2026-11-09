# scnet-tui

预编译版 `scnet`：SCNet 账户登录、免费模型、科学计算作业、云端会话、领域智能体的终端客户端。

## 安装

```bash
curl -fsSL https://raw.githubusercontent.com/lql341/scnet-tui/main/install.sh | bash
```

会自动识别平台（linux/darwin × x64/arm64），下载对应 release，校验 sha256，
安装到 `~/.local/share/scnet` 并软链到 `~/.local/bin/scnet`。

可选环境变量：

```bash
SCNET_VERSION=0.1.0
SCNET_INSTALL_DIR=$HOME/.local/share/scnet
SCNET_BIN_DIR=$HOME/.local/bin
```

## 首次使用

```bash
scnet doctor
scnet login
scnet
```

## 说明

- 本仓库只分发预编译产物和安装脚本，不包含源码。
- 非官方项目，与曙光智算 / 国家超算互联网无隶属关系。
- 使用受 SCNet 平台条款约束；请只使用你有权访问的账号和资源。
