# Fixup CPU Teampeature for RBFeeder

This is a simple hook library for RBFeeder to fixup the CPU temperature measurement function on non-Raspberry Pi devices.

## Implementation
When running on a Raspberry Pi, the CPU temperature is read from the `/sys/class/thermal/thermal_zone0/temp` file. However this file does not exist on some other devices, and RBFeeder will crash because the file is not found.

This library hooked `fopen` function to intercept the file open request for `/sys/class/thermal/thermal_zone0/temp` and return a fake file handle with a fixed temperature value if we are unable to open that file.

## Usage
1. Build the library by running `make` with cross compiler or on the target device.
```
$ make CC=arm-linux-gnueabihf-gcc
```

2. LD_PRELOAD the library when running RBFeeder.
```
$ LD_PRELOAD=./libfixcputemp.so ./rbfeeder
```

or if you are using qemu
```
$ qemu-arm -E LD_PRELOAD=./librbfeeder_fixcputemp.so ./rbfeeder
```
