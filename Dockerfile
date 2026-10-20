FROM alpine:3.20

ARG XRAY_VERSION=v26.3.27

RUN apk add --no-cache ca-certificates tzdata curl unzip \
    && case "$(uname -m)" in \
         x86_64)          XRAY_ARCH=64 ;; \
         aarch64)         XRAY_ARCH=arm64-v8a ;; \
         armv7l)          XRAY_ARCH=arm32-v7a ;; \
         armv6l)          XRAY_ARCH=arm32-v6 ;; \
         i386|i686)       XRAY_ARCH=32 ;; \
         riscv64)         XRAY_ARCH=riscv64 ;; \
         s390x)           XRAY_ARCH=s390x ;; \
         ppc64le)         XRAY_ARCH=ppc64le ;; \
         *) echo "unsupported arch: $(uname -m)" >&2; exit 1 ;; \
       esac \
    && curl -fsSL -o /tmp/xray.zip \
       "https://github.com/XTLS/Xray-core/releases/download/${XRAY_VERSION}/Xray-linux-${XRAY_ARCH}.zip" \
    && mkdir -p /usr/local/share/xray \
    && unzip -o /tmp/xray.zip -d /usr/local/share/xray \
    && chmod +x /usr/local/share/xray/xray \
    && rm -rf /tmp/xray.zip /var/cache/apk/*

ENV XRAY_LOCATION_ASSET=/usr/local/share/xray

WORKDIR /etc/xray

COPY config.json /etc/xray/config.json
COPY start.sh /etc/xray/start.sh

RUN chmod +x /etc/xray/start.sh

EXPOSE 1080

ENTRYPOINT ["/etc/xray/start.sh"]
