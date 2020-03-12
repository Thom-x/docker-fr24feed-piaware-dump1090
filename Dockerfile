FROM debian:buster as dump1090

ENV DUMP1090_VERSION v3.8.0

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

WORKDIR /tmp
RUN git clone -b ${DUMP1090_VERSION} --depth 1 https://github.com/flightaware/dump1090 && \
    cd dump1090 && \
    make

FROM debian:buster as piaware

ENV DEBIAN_VERSION buster
ENV PIAWARE_VERSION v3.8.0

# PIAWARE
WORKDIR /tmp
RUN apt-get update && \
    apt-get install -y \
    sudo \
    git-core \
    wget \
    build-essential \
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

RUN git clone -b ${PIAWARE_VERSION} --depth 1 https://github.com/flightaware/piaware_builder.git piaware_builder
WORKDIR /tmp/piaware_builder
RUN ./sensible-build.sh ${DEBIAN_VERSION} && \
	cd package-${DEBIAN_VERSION} && \
	dpkg-buildpackage -b

FROM debian:buster-slim as serve

ENV RTL_SDR_VERSION 0.6.0
ENV FR24FEED_VERSION 1.0.18-5

MAINTAINER maugin.thomas@gmail.com

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
	tcl-tls \
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

# DUMP1090
RUN mkdir -p /usr/lib/fr24/public_html/data
COPY --from=dump1090 /tmp/dump1090/dump1090 /usr/lib/fr24/
COPY --from=dump1090 /tmp/dump1090/public_html /usr/lib/fr24/public_html
RUN rm /usr/lib/fr24/public_html/config.js

# PIAWARE
COPY --from=piaware /tmp/piaware_builder /tmp/piaware_builder
RUN cd /tmp/piaware_builder && dpkg -i piaware_*_*.deb && rm -rf /tmp/piaware && rm /etc/piaware.conf

# FR24FEED
WORKDIR /fr24feed
ADD https://repo-feed.flightradar24.com/linux_x86_64_binaries/fr24feed_${FR24FEED_VERSION}_amd64.tgz /fr24feed
RUN tar -xzf *amd64.tgz && rm *amd64.tgz

# CONFD
ADD https://github.com/kelseyhightower/confd/releases/download/v0.16.0/confd-0.16.0-linux-amd64 /tmp/
RUN mkdir -p /opt/confd/bin && \
    mv /tmp/confd-0.16.0-linux-amd64 /opt/confd/bin/confd && \
    chmod +x /opt/confd/bin/confd

# DECORATION
ADD https://github.com/Thom-x/Coloring/releases/download/v0.0.1/decoration /tmp/
RUN mv /tmp/decoration /bin/decoration && \
    chmod +x /bin/decoration

# S6 OVERLAY
ADD https://github.com/just-containers/s6-overlay/releases/download/v1.21.8.0/s6-overlay-amd64.tar.gz /tmp/
RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C / && rm /tmp/s6-overlay-amd64.tar.gz
COPY /root /

EXPOSE 8754 8080 30001 30002 30003 30004 30005 30104 

ENTRYPOINT ["/init"]
