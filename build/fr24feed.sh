#!/bin/sh
arch=$(uname -m)

case $arch in
  armv7l)
    url=https://repo-feed.flightradar24.com/rpi_binaries/fr24feed_${FR24FEED_VERSION}_armhf.tgz
    dirname=fr24feed_armhf
    ;;
  armv6l)
    url=https://repo-feed.flightradar24.com/rpi_binaries/fr24feed_${FR24FEED_VERSION}_armhf.tgz
    dirname=fr24feed_armhf
    ;;
  *)
    url=https://repo-feed.flightradar24.com/linux_x86_64_binaries/fr24feed_${FR24FEED_VERSION}_amd64.tgz
    dirname=fr24feed_amd64
    ;;
esac

mkdir /fr24feed && \
wget -O /fr24feed/fr24feed.tgz $url && \
cd /fr24feed && \
tar -xzf fr24feed.tgz && \
mv $dirname fr24feed && \
rm /fr24feed/fr24feed.tgz
