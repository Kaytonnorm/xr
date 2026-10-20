# xr

基于 [Xray-core](https://github.com/XTLS/Xray-core) 的 Docker 代理服务。

默认提供一个 SOCKS5 入站（1080）和一个 HTTP 入站（8080），出站为 `freedom` 直连。

## 文件说明

| 文件 | 说明 |
| --- | --- |
| `Dockerfile` | 多架构构建，自动根据 `uname -m` 下载对应 Xray-core 发行包 |
| `config.json` | Xray 配置（入站、出站、路由） |
| `start.sh` | 容器入口，先做 `-test` 配置校验再启动 |
| `.dockerignore` | 构建忽略文件 |

## 构建

```bash
docker build -t xr:latest .
```

指定 Xray 版本：

```bash
docker build --build-arg XRAY_VERSION=v26.3.27 -t xr:latest .
```

## 运行

```bash
docker run -d --name xr \
  -p 1080:1080 \
  -p 8080:8080 \
  --restart unless-stopped \
  xr:latest
```

使用自定义配置：

```bash
docker run -d --name xr \
  -p 1080:1080 \
  -v "$PWD/config.json:/etc/xray/config.json:ro" \
  xr:latest
```

## 测试

```bash
curl -x socks5h://127.0.0.1:1080 https://www.example.com -I
curl -x http://127.0.0.1:8080 https://www.example.com -I
```

## 配置

`config.json` 主要字段：

- `log`：日志级别与访问日志，默认 `warning` 且关闭 access log
- `inbounds`：入站列表
  - `socks-in`：SOCKS5，`0.0.0.0:1080`，开启 UDP 与流量嗅探
  - `http-in`：HTTP 代理，`0.0.0.0:8080`
- `outbounds`：`direct`（freedom 直连）与 `block`（blackhole）
- `routing`：私有 IP 直连
- `policy`：连接超时等策略

如需改为代理转发（例如 VLESS / VMess 客户端），把 `outbounds` 中的 `direct` 换成对应协议的出站配置，并把 `routing` 默认出站指向它。支持的地理数据文件由 `XRAY_LOCATION_ASSET` 指定，默认 `/usr/local/share/xray`。

## 环境变量

| 变量 | 默认值 | 说明 |
| --- | --- | --- |
| `XRAY_BIN` | `/usr/local/share/xray/xray` | xray 可执行文件路径 |
| `XRAY_CONFIG` | `/etc/xray/config.json` | 配置文件路径 |
| `XRAY_LOCATION_ASSET` | `/usr/local/share/xray` | `geoip.dat` / `geosite.dat` 所在目录 |
