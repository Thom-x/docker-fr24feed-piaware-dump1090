#!/bin/sh
arch=$(dpkg --print-architecture)
case $arch in
  armhf)
    url=http://client.planefinder.net/pfclient_5.0.161_armhf.tar.gz
    ;;
  arm64)
    url=http://client.planefinder.net/pfclient_5.0.161_armhf.tar.gz
    dpkg --add-architecture armhf
    apt update
    apt install libc6:armhf libstdc++6:armhf libusb-1.0-0:armhf
    ;;
  armel)
    url=http://client.planefinder.net/pfclient_5.0.161_armhf.tar.gz
    ;;
  amd64)
    url=http://client.planefinder.net/pfclient_5.0.162_amd64.tar.gz
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
