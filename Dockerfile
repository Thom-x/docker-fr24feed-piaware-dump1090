FROM debian:jessie
 
RUN apt-get update && \
    apt-get install -y wget libusb-1.0-0-dev pkg-config ca-certificates git-core cmake build-essential --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
 
WORKDIR /tmp
 
RUN echo 'blacklist dvb_usb_rtl28xxu' > /etc/modprobe.d/raspi-blacklist.conf && \
    git clone git://git.osmocom.org/rtl-sdr.git && \
    mkdir rtl-sdr/build && \
    cd rtl-sdr/build && \
    cmake ../ -DINSTALL_UDEV_RULES=ON -DDETACH_KERNEL_DRIVER=ON && \
    make && \
    make install && \
    ldconfig && \
    rm -rf /tmp/rtl-sdr

WORKDIR /tmp
 
#RUN git clone git://github.com/antirez/dump1090.git && \
#RUN git clone https://github.com/Flightradar24/dump1090.git && \
RUN git clone https://github.com/mutability/dump1090 && \
	cd dump1090 && \
	make && mkdir /usr/lib/fr24 && cp dump1090 /usr/lib/fr24/ && cp -r public_html /usr/lib/fr24/

COPY config.js /usr/lib/fr24/public_html/

WORKDIR /work

RUN wget $(wget -qO- http://feed.flightradar24.com/linux | egrep amd64.tgz | awk -F\" '{print $2}') \
    && tar -xvzf *amd64.tgz

COPY fr24feed.ini /etc/

EXPOSE 8754
EXPOSE 8080
EXPOSE 30001
EXPOSE 30002
EXPOSE 30003
EXPOSE 30004
EXPOSE 30005
EXPOSE 30104

ENTRYPOINT ["/work/fr24feed_amd64/fr24feed"]
