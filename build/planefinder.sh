#!/bin/sh
arch=$(dpkg --print-architecture)
case $arch in
  armhf)
    url=http://client.planefinder.net/pfclient_${PLANEFINDER_ARMHF_VERSION}_armhf.tar.gz
    pkg_type="tar.gz"
    ;;
  arm64)
    url=http://client.planefinder.net/pfclient_${PLANEFINDER_ARM64_VERSION}_arm64.deb
    pkg_type="deb"
    ;;
  armel)
    url=http://client.planefinder.net/pfclient_${PLANEFINDER_ARMHF_VERSION}_armhf.tar.gz
    pkg_type="tar.gz"
    ;;
  amd64)
    url=http://client.planefinder.net/pfclient_${PLANEFINDER_AMD64_VERSION}_amd64.tar.gz
    pkg_type="tar.gz"
    ;;
  *)
    exit 1
    ;;
esac

echo "downloading for $arch - $url"
mkdir -p /planefinder

if [ "$pkg_type" = "deb" ]; then
    cd /planefinder && \
    wget -O planefinder.deb "$url" && \
    dpkg -i planefinder.deb && \
    rm planefinder.deb
else
    wget -O /planefinder/planefinder.tgz "$url" && \
    cd /planefinder && \
    tar -xzf planefinder.tgz && \
    rm /planefinder/planefinder.tgz
fi
