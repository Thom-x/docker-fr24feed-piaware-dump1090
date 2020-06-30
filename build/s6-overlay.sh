#!/bin/sh
arch=$(uname -m)

case $arch in
  armv7l)
    url=https://github.com/just-containers/s6-overlay/releases/download/v1.21.8.0/s6-overlay-armhf.tar.gz
    ;;
  *)
    url=https://github.com/just-containers/s6-overlay/releases/download/v1.21.8.0/s6-overlay-amd64.tar.gz
    ;;
esac

wget -O /tmp/s6-overlay.tar.gz $url && \
tar xzf /tmp/s6-overlay.tar.gz -C / && rm /tmp/s6-overlay.tar.gz

