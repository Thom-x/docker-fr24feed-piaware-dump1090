#!/bin/sh
arch=$(dpkg --print-architecture)

case $arch in
  armhf)
    url=https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-armhf-${S6_OVERLAY_VERSION}.tar.xz
    ;;
  arm64)
    url=https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-aarch64-${S6_OVERLAY_VERSION}.tar.xz
    ;;
  armel)
    url=https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-armhf-${S6_OVERLAY_VERSION}.tar.xz
    ;;
  amd64)
    url=https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64-${S6_OVERLAY_VERSION}.tar.xz
    ;;
  *)
    exit 1
    ;;
esac

wget -O /tmp/s6-overlay-noarch.tar.gz https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch-${S6_OVERLAY_VERSION}.tar.xz /tmp
tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.gz && rm /tmp/s6-overlay-noarch.tar.gz
wget -O /tmp/s6-overlay.tar.gz $url && \
tar -C / -Jxpf /tmp/s6-overlay.tar.gz && rm /tmp/s6-overlay.tar.gz

