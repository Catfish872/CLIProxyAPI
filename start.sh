#!/bin/sh
set -e

CFG=/tmp/config.yaml

# secrets 是只读挂载，复制到 /tmp 变成可写副本
if [ -f /etc/secrets/config.yaml ]; then
  cp /etc/secrets/config.yaml "$CFG"
fi

chmod u+rw "$CFG" 2>/dev/null || true

# 用绝对路径启动，彻底避免工作目录不一致导致找不到二进制
exec /CLIProxyAPI/CLIProxyAPI -config "$CFG"
