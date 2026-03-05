#!/bin/sh
set -e

CFG=/tmp/config.yaml

# 第一次启动：把只读 secrets 配置复制到 /tmp
if [ -f /etc/secrets/config.yaml ]; then
  cp /etc/secrets/config.yaml "$CFG"
fi

# 确保可写
chmod u+rw "$CFG" 2>/dev/null || true

# 用可写副本启动
exec ./CLIProxyAPI -config "$CFG"
