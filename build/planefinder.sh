#!/bin/sh
arch=$(dpkg --print-architecture)
case $arch in
  armhf)
    url=http://client.planefinder.net/pfclient_${PLANEFINDER_ARMHF_VERSION}_armhf.tar.gz
    ;;
  arm64)
    url=http://client.planefinder.net/pfclient_${PLANEFINDER_ARM64_VERSION}_arm64.tar.gz
    ;;
  amd64)
    url=http://client.planefinder.net/pfclient_${PLANEFINDER_AMD64_VERSION}_amd64.tar.gz
    ;;
  *)
    exit 1
    ;;
esac

echo 'downloading for $arch - $url'
mkdir /planefinder && \
wget -O /planefinder/planefinder.tgz $url && \
cd /planefinder && \
tar -xzf planefinder.tgz && \
rm /planefinder/planefinder.tgz