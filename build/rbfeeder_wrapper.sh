#!/usr/bin/env bash

# This wrapper file will determine how to run rbfeeder, either natively or via qemu-arm-static.
# All command line arguments passed to this script will be passed directly to rbfeeder_armhf.

# attempt to run natively
if /usr/bin/rbfeeder_armhf --no-start --version >/dev/null 2>&1; then
    export LD_PRELOAD=/usr/lib/arm-linux-gnueabihf/librbfeeder_fixcputemp.so
    /usr/bin/rbfeeder_armhf "$@"
elif qemu-arm-static /usr/bin/rbfeeder_armhf --no-start --version >/dev/null 2>&1; then
    qemu-arm-static -E LD_PRELOAD=/usr/lib/arm-linux-gnueabihf/librbfeeder_fixcputemp.so /usr/bin/rbfeeder_armhf "$@"
else
    for i in {1..5}; do
        echo "FATAL: Could not run rbfeeder natively or via qemu!" | mawk -W interactive '{printf "%c[34m[radarbox-feeder]%c[0m %s\n", 27, 27, $0}'
    done
    kill 1
    exit 1
fi
