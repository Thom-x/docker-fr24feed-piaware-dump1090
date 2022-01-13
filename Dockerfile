FROM debian:buster as dump1090

ENV DUMP1090_VERSION v7.1

# DUMP1090
RUN apt-get update && \
    apt-get install -y \
    sudo \
    git-core \
    build-essential \
    debhelper \
    librtlsdr-dev \
    pkg-config \
    dh-systemd \
    libncurses5-dev \
    libbladerf-dev && \
    rm -rf /var/lib/apt/lists/*

ADD patch /patch
WORKDIR /tmp
RUN git clone -b ${DUMP1090_VERSION} --depth 1 https://github.com/flightaware/dump1090 && \
    cd dump1090 && \
    cp /patch/resources/fr24-logo.svg $PWD/public_html_merged/images && \
    patch --ignore-whitespace -p1 -ru --force -d $PWD < /patch/flightradar24.patch && \
    make CPUFEATURES=no

FROM debian:buster as piaware

ENV DEBIAN_VERSION buster
ENV PIAWARE_VERSION v7.1

# PIAWARE
WORKDIR /tmp
RUN apt-get update && \
    apt-get install -y \
    sudo \
    git-core \
    wget \
    build-essential \
    devscripts \
    debhelper \
    tcl8.6-dev \
    autoconf \
    python3-dev \
    python-virtualenv \
    libz-dev \
    dh-systemd \
    net-tools \
    tclx8.4 \
    tcllib \
    tcl-tls \
    itcl3 \
    python3-venv \
    dh-systemd \
    init-system-helpers \
    libboost-system-dev \
    libboost-program-options-dev \
    libboost-regex-dev \
    libboost-filesystem-dev && \
    rm -rf /var/lib/apt/lists/*

RUN git config --global http.sslVerify false && git config --global http.postBuffer 1048576000
RUN git clone -b ${PIAWARE_VERSION} --depth 1 https://github.com/flightaware/piaware_builder.git piaware_builder
WORKDIR /tmp/piaware_builder
RUN ./sensible-build.sh ${DEBIAN_VERSION} && \
	cd package-${DEBIAN_VERSION} && \
	dpkg-buildpackage -b

# CONF
FROM golang:1.9-alpine as confd

ARG CONFD_VERSION=0.16.0

ADD https://github.com/kelseyhightower/confd/archive/v${CONFD_VERSION}.tar.gz /tmp/

RUN apk add --no-cache \
    bzip2 \
    build-base \
    make && \
  mkdir -p /go/src/github.com/kelseyhightower/confd && \
  cd /go/src/github.com/kelseyhightower/confd && \
  tar --strip-components=1 -zxf /tmp/v${CONFD_VERSION}.tar.gz && \
  go install github.com/kelseyhightower/confd && \
  rm -rf /tmp/v${CONFD_VERSION}.tar.gz

FROM debian:buster-slim as serve

ENV DEBIAN_VERSION buster
ENV RTL_SDR_VERSION 0.6.0

ENV FR24FEED_AMD64_VERSION 1.0.25-3
# force version 1.0.25-3 for armhf and armel because of broken version for these architectures
ENV FR24FEED_ARMHF_VERSION 1.0.25-3
ENV FR24FEED_ARMEL_VERSION 1.0.25-3
ENV S6_OVERLAY_VERSION v2.1.0.2

LABEL maintainer="maugin.thomas@gmail.com"

RUN apt-get update && \
    # rtl-sdr
    apt-get install -y \
    wget \
    devscripts \
    libusb-1.0-0-dev \
    pkg-config \
    ca-certificates \
    git-core \
    cmake \
    build-essential \
    # piaware
    libboost-system-dev \
    libboost-program-options-dev \
    libboost-regex-dev \
    libboost-filesystem-dev \
    libtcl \
    net-tools \
    tclx \
    tcl \
    tcllib \
    itcl3 \
    librtlsdr-dev \
    pkg-config \
    libncurses5-dev \
    libbladerf-dev && \
    rm -rf /var/lib/apt/lists/*

# RTL-SDR
WORKDIR /tmp
RUN mkdir -p /etc/modprobe.d && \
    echo 'blacklist r820t' >> /etc/modprobe.d/raspi-blacklist.conf && \
	echo 'blacklist rtl2832' >> /etc/modprobe.d/raspi-blacklist.conf && \
	echo 'blacklist rtl2830' >> /etc/modprobe.d/raspi-blacklist.conf && \
	echo 'blacklist dvb_usb_rtl28xxu' >> /etc/modprobe.d/raspi-blacklist.conf && \
    git clone -b ${RTL_SDR_VERSION} --depth 1 https://github.com/osmocom/rtl-sdr.git && \
    mkdir rtl-sdr/build && \
    cd rtl-sdr/build && \
    cmake ../ -DINSTALL_UDEV_RULES=ON -DDETACH_KERNEL_DRIVER=ON && \
    make && \
    make install && \
    ldconfig && \
    rm -rf /tmp/rtl-sdr

# Build & Install dependency tcl-tls from source code.
# Install dependencies
RUN apt-get update && \
    apt-get install -y \
    libssl-dev \
    tcl-dev \
    chrpath \
    netcat && \
    rm -rf /var/lib/apt/lists/*

## Clone source code, build & Install tcl-tls
RUN cd /tmp && \
    git clone --depth 1 http://github.com/flightaware/tcltls-rebuild.git && \
    cd tcltls-rebuild && \
    ./prepare-build.sh ${DEBIAN_VERSION} && \
    cd package-${DEBIAN_VERSION} && \
    dpkg-buildpackage -b --no-sign && \
    cd ../ && \
    dpkg -i tcl-tls_*.deb

# DUMP1090
RUN mkdir -p /usr/lib/fr24/public_html/data
COPY --from=dump1090 /tmp/dump1090/dump1090 /usr/lib/fr24/
COPY --from=dump1090 /tmp/dump1090/public_html_merged /usr/lib/fr24/public_html
RUN rm /usr/lib/fr24/public_html/config.js
RUN rm /usr/lib/fr24/public_html/layers.js

# PIAWARE
COPY --from=piaware /tmp/piaware_builder /tmp/piaware_builder
RUN cd /tmp/piaware_builder && dpkg -i piaware_*_*.deb && rm -rf /tmp/piaware && rm /etc/piaware.conf

ADD build /build

# FR24FEED
RUN /build/fr24feed.sh

# CONFD
COPY --from=confd /go/bin/confd /opt/confd/bin/confd

# S6 OVERLAY
RUN /build/s6-overlay.sh

COPY /root /

EXPOSE 8754 8080 30001 30002 30003 30004 30005 30104

ENTRYPOINT ["/init"]
