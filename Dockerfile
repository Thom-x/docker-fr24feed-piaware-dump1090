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
    patch --ignore-whitespace -p1 -ru --force --no-backup-if-mismatch -d $PWD < /patch/flightradar24.patch && \
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
    python3-setuptools \
    patchelf \
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

#ADSBEXCHANGE
# pinned commits, feel free to update to most recent commit, no major versions usually

FROM debian:buster as adsbexchange_packages

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
WORKDIR /tmp
RUN set -x && \
    apt-get update && \
    apt-get install -y --no-install-suggests --no-install-recommends \
    jq \
    uuid-runtime \
    wget \
    make \
    gcc \
    ncurses-dev \
    ncurses-bin \
    zlib1g-dev \
    zlib1g \
    python3-venv \
    python3-dev

FROM adsbexchange_packages as adsbexchange
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
WORKDIR /tmp
RUN set -x && \
    mkdir -p /usr/local/share/adsbexchange/ && \
    SRCTMP=/srctmp && \
    # readsb as a feed client
    URL=https://github.com/adsbxchange/readsb && \
    COMMIT=da57fe341a2485fbeb645147f3738c565c38c312 && \
    mkdir -p $SRCTMP && wget -O ${SRCTMP}.tar.gz ${URL}/archive/${COMMIT}.tar.gz && tar xf ${SRCTMP}.tar.gz -C ${SRCTMP} --strip-components=1 && \
    pushd ${SRCTMP} && \
    echo "$COMMIT" > READSB_VERSION && \
    cat READSB_VERSION && \
    make -j "$(nproc)" AIRCRAFT_HASH_BITS=12 && \
    cp -v -T readsb /usr/local/share/adsbexchange/readsb && \
    popd && \
    rm -rf ${SRCTMP} ${SRCTMP}.tar.gz && \
    # mlat-client
    URL=https://github.com/adsbxchange/mlat-client &&\
    COMMIT=8d8b5a784727526620d5608c6d581fe3082deb79 && \
    mkdir -p $SRCTMP && wget -O ${SRCTMP}.tar.gz ${URL}/archive/${COMMIT}.tar.gz && tar xf ${SRCTMP}.tar.gz -C ${SRCTMP} --strip-components=1 && \
    pushd ${SRCTMP} && \
    VENV="/usr/local/share/adsbexchange/venv" && \
    python3 -m venv "${VENV}" && \
    source "${VENV}/bin/activate" && \
    ./setup.py build && \
    ./setup.py install && \
    deactivate && \
    popd && \
    ldconfig && \
    rm -rf ${SRCTMP} ${SRCTMP}.tar.gz && \
    # adsbexchange-stats
    URL=https://github.com/adsbxchange/adsbexchange-stats && \
    COMMIT=6b9fe07ba728de5e732fe87fa3ae0afdbb390709 && \
    mkdir -p $SRCTMP && wget -O ${SRCTMP}.tar.gz ${URL}/archive/${COMMIT}.tar.gz && tar xf ${SRCTMP}.tar.gz -C ${SRCTMP} --strip-components=1 && \
    cp -v -T ${SRCTMP}/json-status /usr/local/share/adsbexchange/json-status && \
    rm -rf ${SRCTMP} ${SRCTMP}.tar.gz && \
    # readsb: simple tests
    /usr/local/share/adsbexchange/readsb --version && \
    # mlat-client: simple test
    /usr/local/share/adsbexchange/venv/bin/python3 -c 'import mlat.client'

# THTTPD
FROM alpine:3.13.2 AS thttpd

ENV THTTPD_VERSION=2.29

# Install all dependencies required for compiling thttpd
RUN apk add gcc musl-dev make

# Download thttpd sources
RUN wget http://www.acme.com/software/thttpd/thttpd-${THTTPD_VERSION}.tar.gz \
    && tar xzf thttpd-${THTTPD_VERSION}.tar.gz \
    && mv /thttpd-${THTTPD_VERSION} /thttpd

# Compile thttpd to a static binary which we can copy around
RUN cd /thttpd \
    && ./configure \
    && make CCOPT='-O2 -s -static' thttpd

# CONFD
FROM debian:buster-slim as confd

ADD confd/confd.tar.gz /opt/confd/
RUN ARCH=$(dpkg --print-architecture) && \
    cp "/opt/confd/bin/confd-$ARCH" /opt/confd/bin/confd && \
    chmod +x /opt/confd/bin/confd && \
    rm /opt/confd/bin/confd-*

# ONE STAGE COPY ALL
FROM debian:buster-slim as copyall

COPY --from=dump1090 /tmp/dump1090/dump1090 /copy_root/usr/lib/fr24/
COPY --from=dump1090 /tmp/dump1090/public_html_merged /copy_root/usr/lib/fr24/public_html
COPY --from=piaware /tmp/piaware_builder /copy_root/piaware_builder
COPY --from=adsbexchange  /usr/local/share/adsbexchange /copy_root/usr/local/share/adsbexchange
RUN mv /copy_root/piaware_builder/piaware_*_*.deb /copy_root/piaware.deb && \
    rm -rf /copy_root/piaware_builder
COPY --from=thttpd /thttpd/thttpd /copy_root/
COPY --from=confd /opt/confd/bin/confd /copy_root/opt/confd/bin/
ADD build /copy_root/build

FROM debian:buster-slim as serve

ENV DEBIAN_VERSION buster
ENV RTL_SDR_VERSION 0.6.0

ENV FR24FEED_AMD64_VERSION 1.0.25-3
# force version 1.0.25-3 for armhf and armel because of broken version for these architectures
ENV FR24FEED_ARMHF_VERSION 1.0.25-3
ENV FR24FEED_ARMEL_VERSION 1.0.25-3

ENV PLANEFINDER_AMD64_VERSION 5.0.162
ENV PLANEFINDER_ARMHF_VERSION 5.0.161

ENV S6_OVERLAY_VERSION 3.0.0.2-2

# Services startup
ENV SERVICE_ENABLE_DUMP1090 true
ENV SERVICE_ENABLE_PIAWARE true
ENV SERVICE_ENABLE_FR24FEED true
ENV SERVICE_ENABLE_HTTP true
ENV SERVICE_ENABLE_IMPORT_OVER_NETCAT false
ENV SERVICE_ENABLE_ADSBEXCHANGE false
ENV SERVICE_ENABLE_PLANEFINDER false

LABEL maintainer="maugin.thomas@gmail.com"

# COPY ALL
COPY --from=copyall /copy_root/ /

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN arch=$(dpkg --print-architecture) && \
    if [ "$arch" == "arm64" ] ; then \
    dpkg --add-architecture armhf; \
    apt-get update && \
    apt-get install -y libc6:armhf libstdc++6:armhf libusb-1.0-0:armhf lsb-base:armhf; \
    ldconfig; \
    fi && \
    apt-get update && \
    # rtl-sdr
    apt-get install -y \
    wget \
    xz-utils \
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
    libbladerf-dev \
    # adsbexchange
    jq \
    ncurses-bin \
    zlib1g \
    python3-venv \
    curl \
    gzip \
    && \
    # planefinder
    /planefinder/pfclient --version > /dev/null 2>&1 && echo "planefinder OK" || apt install -y qemu-user-static && \
    # RTL-SDR
    cd /tmp && \
    mkdir -p /etc/modprobe.d && \
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
    rm -rf /tmp/rtl-sdr && \
    # Build & Install dependency tcl-tls from source code.
    # Install dependencies
    apt-get install -y \
    libssl-dev \
    tcl-dev \
    chrpath \
    netcat && \
    # Clone source code, build & Install tcl-tls
    cd /tmp && \
    git clone --depth 1 http://github.com/flightaware/tcltls-rebuild.git && \
    cd tcltls-rebuild && \
    ./prepare-build.sh ${DEBIAN_VERSION} && \
    cd package-${DEBIAN_VERSION} && \
    dpkg-buildpackage -b --no-sign && \
    cd ../ && \
    dpkg -i tcl-tls_*.deb && \
    rm -rf /tmp/tcltls-rebuild && \
    # DUMP1090
    mkdir -p /usr/lib/fr24/public_html/data && \
    rm /usr/lib/fr24/public_html/config.js && \
    rm /usr/lib/fr24/public_html/layers.js && \
    # PIAWARE
    cd / && \
    dpkg -i piaware.deb && \
    rm /etc/piaware.conf && \
    rm /piaware.deb && \
    # THTTPD
    find /usr/lib/fr24/public_html -type d -print0 | xargs -0 chmod 0755 && \
    find /usr/lib/fr24/public_html -type f -print0 | xargs -0 chmod 0644 && \
    # FR24FEED
    /build/fr24feed.sh && \
    # PLANEFINDER
    /build/planefinder.sh && \
    # S6 OVERLAY
    /build/s6-overlay.sh && \
    # CLEAN
    rm -rf /build && \
    apt-get purge -y \
    xz-utils \
    devscripts \
    pkg-config \
    git-core \
    cmake \
    build-essential && \
    apt autoremove -y && \
    rm -rf /var/lib/apt/lists/*

COPY /root /

EXPOSE 8754 8080 30001 30002 30003 30004 30005 30104

ENTRYPOINT ["/init"]
