FROM golang:1.24-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

# 扫描代码并自动下载缺失的依赖包
RUN go mod tidy

ARG VERSION=dev
ARG COMMIT=none
ARG BUILD_DATE=unknown

# 关键修改：增加 GOGC=50 (让垃圾回收更积极) 和 -p 1 (单核排队编译，防止内存飙升)
RUN CGO_ENABLED=0 GOOS=linux GOGC=50 go build -p 1 \
  -ldflags="-s -w -X 'main.Version=${VERSION}' -X 'main.Commit=${COMMIT}' -X 'main.BuildDate=${BUILD_DATE}'" \
  -o ./CLIProxyAPI ./cmd/server/

FROM alpine:3.22.0

RUN apk add --no-cache tzdata

RUN mkdir -p /CLIProxyAPI

COPY --from=builder /app/CLIProxyAPI /CLIProxyAPI/CLIProxyAPI
COPY config.example.yaml /CLIProxyAPI/config.example.yaml

# 把启动脚本放进镜像
COPY start.sh /start.sh
RUN chmod +x /start.sh

WORKDIR /CLIProxyAPI

EXPOSE 8317

ENV TZ=Asia/Shanghai
RUN cp /usr/share/zoneinfo/${TZ} /etc/localtime && echo "${TZ}" > /etc/timezone

# 用脚本当入口，脚本里会把只读配置复制到 /tmp 可写副本再启动
ENTRYPOINT ["/start.sh"]
