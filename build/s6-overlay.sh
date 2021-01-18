#!/bin/sh
arch=$(dpkg --print-architecture)

case $arch in
  armhf)
    url=https://github.com/just-containers/s6-overlay/releases/download/v1.21.8.0/s6-overlay-armhf.tar.gz
    ;;
  armel)
    url=https://github.com/just-containers/s6-overlay/releases/download/v1.21.8.0/s6-overlay-arm.tar.gz
    ;;
  amd64)
    url=https://github.com/just-containers/s6-overlay/releases/download/v1.21.8.0/s6-overlay-amd64.tar.gz
    ;;
  *)
    exit 1
    ;;
esac

wget -O /tmp/s6-overlay.tar.gz $url && \
tar xzf /tmp/s6-overlay.tar.gz -C / && rm /tmp/s6-overlay.tar.gz

