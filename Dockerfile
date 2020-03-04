FROM debian:buster


ENV DEBIAN_VERSION buster
ENV TINI_VERSION v0.18.0
ENV RTL_SDR_VERSION 0.6.0
ENV DUMP1090_VERSION v3.8.0
ENV PIAWARE_VERSION v3.8.0

MAINTAINER maugin.thomas@gmail.com


RUN apt-get update && \
    apt-get install -y wget devscripts libusb-1.0-0-dev pkg-config ca-certificates git-core cmake build-essential --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /tmp
RUN mkdir /etc/modprobe.d && echo 'blacklist r820t' >> /etc/modprobe.d/raspi-blacklist.conf && echo 'blacklist rtl2832' >> /etc/modprobe.d/raspi-blacklist.conf && echo 'blacklist rtl2830' >> /etc/modprobe.d/raspi-blacklist.conf && echo 'blacklist dvb_usb_rtl28xxu' >> /etc/modprobe.d/raspi-blacklist.conf && \
    git clone -b ${RTL_SDR_VERSION} --depth 1 https://github.com/osmocom/rtl-sdr.git && \
    mkdir rtl-sdr/build && \
    cd rtl-sdr/build && \
    cmake ../ -DINSTALL_UDEV_RULES=ON -DDETACH_KERNEL_DRIVER=ON && \
    make && \
    make install && \
    ldconfig && \
    rm -rf /tmp/rtl-sdr

# DUMP1090
WORKDIR /tmp
RUN apt-get update && \
    apt-get install sudo build-essential debhelper librtlsdr-dev pkg-config dh-systemd libncurses5-dev libbladerf-dev -y 
RUN git clone -b ${DUMP1090_VERSION} --depth 1 https://github.com/flightaware/dump1090 && \
    cd dump1090 && \
    make && mkdir /usr/lib/fr24 && cp dump1090 /usr/lib/fr24/ && cp -r public_html /usr/lib/fr24/
COPY config.js /usr/lib/fr24/public_html/
RUN mkdir /usr/lib/fr24/public_html/data

# Uncomment if you want to add your upintheair.json file
#COPY upintheair.json /usr/lib/fr24/public_html/

# PIAWARE
WORKDIR /tmp
RUN apt-get update && \
    apt-get install sudo build-essential debhelper tcl8.6-dev autoconf python3-dev python-virtualenv libz-dev dh-systemd net-tools tclx8.4 tcllib tcl-tls itcl3 python3-venv dh-systemd init-system-helpers  libboost-system-dev libboost-program-options-dev libboost-regex-dev libboost-filesystem-dev -y 
RUN git clone -b ${PIAWARE_VERSION} --depth 1 https://github.com/flightaware/piaware_builder.git piaware_builder
WORKDIR /tmp/piaware_builder
RUN ./sensible-build.sh ${DEBIAN_VERSION} && cd package-${DEBIAN_VERSION} && dpkg-buildpackage -b && cd .. && dpkg -i piaware_*_*.deb
COPY piaware.conf /etc/

# FR24FEED
WORKDIR /fr24feed
RUN wget https://repo-feed.flightradar24.com/linux_x86_64_binaries/fr24feed_1.0.24-5_amd64.tgz \
    && tar -xvzf *amd64.tgz
COPY fr24feed.ini /etc/

RUN apt-get update && apt-get install -y supervisor
COPY manage-supervisord /usr/local/bin/manage-supervisord
RUN chmod +x /usr/local/bin/manage-supervisord
COPY prefix-log /usr/local/bin/prefix-log
RUN chmod +x /usr/local/bin/prefix-log
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Add Tini

ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

EXPOSE 8754 8080 30001 30002 30003 30004 30005 30104 

CMD ["/usr/bin/supervisord"]
